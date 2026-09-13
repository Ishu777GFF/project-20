import { z } from "zod";
import { db } from "@/server/db";
import { audit } from "@/server/audit";
import { runTriage } from "@/server/triage";
import { buildFhirBundle } from "@/server/fhir";
import { questions } from "@/server/questions";
import { patientAccessCode } from "@/server/auth";
import { router, publicProcedure, patientGuard, doctorGuard, adminGuard } from "@/server/trpc";

const KIOSK_ACTOR = "patient-kiosk";
const DOCTOR_NAME = "Dr. Ananya Rao";

export const appRouter = router({
  bootstrap: publicProcedure.query(() => ({
    questions,
    mockNotices: [
      "Voice transcript uses browser speech recognition when available.",
      "OCR/entity extraction and ABDM transport are prototype mocks.",
    ],
  })),

  patientRegister: publicProcedure
    .input(z.object({ fullName: z.string().trim().min(2), phone: z.string().trim().min(10), dob: z.string().date(), gender: z.string().min(1), language: z.enum(["en", "hi"]).default("en") }))
    .mutation(async ({ input }) => {
      const baseCode = patientAccessCode(input.fullName, input.dob);
      let accessCode = baseCode;
      let suffix = 2;
      while (await db.patient.findUnique({ where: { accessCode } })) accessCode = `${baseCode}${suffix++}`;
      const patient = await db.patient.create({
        data: {
          fullName: input.fullName,
          phone: input.phone,
          dob: new Date(input.dob),
          gender: input.gender,
          abhaId: `MOCK-ABHA-${crypto.randomUUID().slice(0, 8)}`,
          accessCode,
          preferredLanguage: input.language,
        },
      });
      await audit("patient-account", "PATIENT_ACCOUNT_CREATED", "patient", patient.id, { accessCode });
      return { fullName: patient.fullName, accessCode };
    }),

  patientLogin: publicProcedure
    .input(z.object({ accessCode: z.string().trim().min(3) }))
    .mutation(async ({ input }) => {
      const patient = await db.patient.findUnique({
        where: { accessCode: input.accessCode.toUpperCase() },
        include: { visits: { include: { summary: true, redFlags: true }, orderBy: { startedAt: "desc" }, take: 20 } },
      });
      if (!patient) throw new Error("Patient access code is incorrect.");
      await audit("patient-account", "PATIENT_SIGNED_IN", "patient", patient.id);
      return patient;
    }),

  patientUpdate: publicProcedure
    .input(z.object({ patientId: z.string().uuid(), fullName: z.string().trim().min(2), dob: z.string().date(), gender: z.string().min(1), phone: z.string().trim().min(10) }))
    .mutation(async ({ input }) => {
      const patient = await db.patient.update({
        where: { id: input.patientId },
        data: { fullName: input.fullName, dob: new Date(input.dob), gender: input.gender, phone: input.phone },
      });
      await audit("patient-account", "PATIENT_PROFILE_UPDATED", "patient", patient.id);
      return patient;
    }),

  patientAddDocument: publicProcedure
    .input(z.object({ patientId: z.string().uuid(), filename: z.string().min(1), size: z.number().optional() }))
    .mutation(async ({ input }) => {
      // A report must belong to a visit. Reuse the latest active visit or create a draft record.
      let visit = await db.visit.findFirst({ where: { patientId: input.patientId, status: "IN_PROGRESS" }, orderBy: { startedAt: "desc" } });
      if (!visit) visit = await db.visit.create({ data: { patientId: input.patientId, mode: "GENERAL", status: "IN_PROGRESS" } });
      const document = await db.document.create({
        data: {
          visitId: visit.id, filename: input.filename, type: "previous_report", ocrStatus: "MOCK_COMPLETE",
          extractedText: "MOCK OCR - Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg",
          entities: { create: [
            { entityType: "investigation", name: "Hemoglobin", value: "9.2", unit: "g/dL", abnormal: true },
            { entityType: "investigation", name: "Blood Glucose", value: "168", unit: "mg/dL", abnormal: true },
            { entityType: "medication", name: "Metformin", value: "500", unit: "mg", abnormal: false },
          ] },
        }, include: { entities: true },
      });
      await audit("patient-account", "PREVIOUS_REPORT_ADDED", "document", document.id, { patientId: input.patientId, filename: input.filename, size: input.size });
      return { visitId: visit.id, document };
    }),

  createVisit: patientGuard
    .input(
      z.object({
        fullName: z.string().min(1),
        dob: z.string().optional(),
        gender: z.string().optional(),
        phone: z.string().optional(),
        language: z.enum(["en", "hi"]).default("en"),
        mode: z.enum(["GENERAL", "AYUSH"]).default("GENERAL"),
        patientId: z.string().uuid().optional(),
        consents: z.array(z.enum(["history_collection", "document_processing", "mock_abdm_sharing"])).default([]),
        // UI-only flag: replays the scripted urgent demo answers on the client. Never persisted.
        demo: z.boolean().default(false),
      }),
    )
    .mutation(async ({ input }) => {
      const patient = input.patientId
        ? await db.patient.update({
            where: { id: input.patientId },
            data: { fullName: input.fullName, dob: input.dob ? new Date(input.dob) : null, gender: input.gender ?? null, phone: input.phone ?? null, preferredLanguage: input.language },
          })
        : await db.patient.create({
            data: { fullName: input.fullName, dob: input.dob ? new Date(input.dob) : null, gender: input.gender ?? null, phone: input.phone ?? null, abhaId: `MOCK-ABHA-${crypto.randomUUID().slice(0, 8)}`, preferredLanguage: input.language },
          });
      const visit = await db.visit.create({
        data: { patientId: patient.id, mode: input.mode, status: "IN_PROGRESS", priority: "NORMAL" },
      });
      for (const type of input.consents) {
        await db.consent.create({ data: { visitId: visit.id, type, granted: true, version: "v1.0" } });
      }
      await audit(KIOSK_ACTOR, "REGISTERED_AND_CONSENTED", "visit", visit.id, {
        mode: input.mode,
        consents: input.consents,
      });
      return {
        visitId: visit.id,
        patientId: patient.id,
        mockAbha: patient.abhaId,
        questions: questions[input.mode],
      };
    }),

  saveAnswer: patientGuard
    .input(
      z.object({
        visitId: z.string().uuid(),
        questionId: z.string(),
        label: z.string(),
        answer: z.string().min(1),
        inputMode: z.enum(["TOUCH", "TEXT", "VOICE"]).default("TOUCH"),
      }),
    )
    .mutation(async ({ input }) => {
      const visit = await db.visit.findUnique({ where: { id: input.visitId } });
      if (!visit) throw new Error("Visit not found");
      await db.historyAnswer.upsert({
        where: { visitId_questionId: { visitId: input.visitId, questionId: input.questionId } },
        create: {
          visitId: input.visitId,
          questionId: input.questionId,
          label: input.label,
          answer: input.answer,
          inputMode: input.inputMode,
        },
        update: { label: input.label, answer: input.answer, inputMode: input.inputMode },
      });
      const triage = await runTriage(input.visitId);
      await audit(KIOSK_ACTOR, "ANSWER_RECORDED", "visit", input.visitId, {
        question: input.questionId,
        input: input.inputMode,
      });
      return triage;
    }),

  uploadDocument: patientGuard
    .input(z.object({ visitId: z.string().uuid(), filename: z.string().min(1), size: z.number().optional() }))
    .mutation(async ({ input }) => {
      // MOCK OCR: real deployments would run an evaluated OCR pipeline + human validation.
      const extractedText = "MOCK OCR — Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg";
      const doc = await db.document.create({
        data: {
          visitId: input.visitId,
          filename: input.filename,
          type: "lab_report",
          ocrStatus: "MOCK_COMPLETE",
          extractedText,
          entities: {
            create: [
              { entityType: "investigation", name: "Hemoglobin", value: "9.2", unit: "g/dL", abnormal: true },
              { entityType: "investigation", name: "Blood Glucose", value: "168", unit: "mg/dL", abnormal: true },
              { entityType: "medication", name: "Metformin", value: "500", unit: "mg", abnormal: false },
            ],
          },
        },
        include: { entities: true },
      });
      await audit(KIOSK_ACTOR, "MOCK_OCR_PROCESSED", "document", doc.id, { filename: input.filename });
      return {
        documentId: doc.id,
        status: doc.ocrStatus,
        extractedText,
        entities: doc.entities.map((e) => ({
          name: e.name,
          value: e.value,
          unit: e.unit,
          abnormal: e.abnormal,
        })),
      };
    }),

  completeVisit: patientGuard.input(z.object({ visitId: z.string().uuid() })).mutation(async ({ input }) => {
    const visit = await db.visit.findUnique({
      where: { id: input.visitId },
      include: { answers: { orderBy: { createdAt: "asc" } }, redFlags: true, documents: true },
    });
    if (!visit) throw new Error("Visit not found");
    const chief = visit.answers.find((x) => x.questionId === "chief")?.answer ?? "Not recorded";
    const rest = visit.answers.filter((x) => x.questionId !== "chief");
    const lines = [
      `Chief concern: ${chief}.`,
      `Structured history: ${rest.map((x) => `${x.label}: ${x.answer}`).join("; ")}.`,
      ...(visit.redFlags.length
        ? [`Triage alert: ${visit.redFlags.map((f) => f.message).join(" ")}`]
        : []),
      ...(visit.documents[0]
        ? [`Document extraction (MOCK; clinician validation required): ${visit.documents[0].extractedText}`]
        : []),
      "Clinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.",
    ];
    const summary = lines.join("\n\n");
    await db.$transaction([
      db.visit.update({ where: { id: visit.id }, data: { status: "READY_FOR_REVIEW", completedAt: new Date() } }),
      db.clinicalSummary.upsert({
        where: { visitId: visit.id },
        create: { visitId: visit.id, summaryText: summary, status: "PENDING" },
        update: { summaryText: summary, status: "PENDING", reviewer: null },
      }),
    ]);
    await audit(KIOSK_ACTOR, "SUMMARY_GENERATED", "visit", visit.id);
    return { summary };
  }),

  doctorQueue: doctorGuard.query(async () => {
    const visits = await db.visit.findMany({
      where: { status: { in: ["READY_FOR_REVIEW", "REVIEWED"] } },
      include: { patient: true },
      orderBy: { startedAt: "desc" },
    });
    // URGENT first, then newest — explicit in code rather than relying on enum sort order.
    return visits
      .sort((a, b) => (a.priority === b.priority ? 0 : a.priority === "URGENT" ? -1 : 1))
      .map((v) => ({
      id: v.id,
      priority: v.priority,
      status: v.status,
      startedAt: v.startedAt,
      fullName: v.patient.fullName,
      gender: v.patient.gender,
      dob: v.patient.dob,
    }));
  }),

  doctorCase: doctorGuard.input(z.object({ visitId: z.string().uuid() })).query(async ({ input }) => {
    const visit = await db.visit.findUnique({
      where: { id: input.visitId },
      include: {
        patient: true,
        answers: { orderBy: { createdAt: "asc" } },
        redFlags: true,
        documents: { include: { entities: true } },
        summary: true,
      },
    });
    if (!visit) throw new Error("Case not found");
    const events = await db.auditLog.findMany({
      where: { resourceId: visit.id },
      orderBy: { createdAt: "desc" },
      take: 50,
    });
    await audit(DOCTOR_NAME, "VIEWED_CASE", "visit", visit.id);
    return { visit, audit: events };
  }),

  reviewSummary: doctorGuard
    .input(
      z.object({
        visitId: z.string().uuid(),
        summaryText: z.string().min(1),
        status: z.enum(["PENDING", "CONFIRMED", "REJECTED"]),
      }),
    )
    .mutation(async ({ input }) => {
      await db.clinicalSummary.update({
        where: { visitId: input.visitId },
        data: {
          summaryText: input.summaryText,
          status: input.status,
          version: { increment: 1 },
          reviewer: DOCTOR_NAME,
        },
      });
      await db.visit.update({
        where: { id: input.visitId },
        data: { status: input.status === "CONFIRMED" ? "REVIEWED" : "READY_FOR_REVIEW" },
      });
      await audit(DOCTOR_NAME, `SUMMARY_${input.status}`, "visit", input.visitId);
      return { ok: true };
    }),

  fhirExport: doctorGuard.input(z.object({ visitId: z.string().uuid() })).query(async ({ input }) => {
    const bundle = await buildFhirBundle(input.visitId);
    if (!bundle) throw new Error("Visit not found");
    return bundle;
  }),

  auditLog: adminGuard.query(async () => {
    return db.auditLog.findMany({ orderBy: { createdAt: "desc" }, take: 100 });
  }),
});

export type AppRouter = typeof appRouter;
