import { PrismaClient } from "@prisma/client";

const db = new PrismaClient();

/**
 * Replays the "Load urgent demo" flow (scripted 5-minute SIH demo, step 0) so the
 * doctor queue has a URGENT case before the kiosk walkthrough starts.
 */
async function main() {
  const patient = await db.patient.create({
    data: {
      fullName: "Meera Sharma",
      dob: new Date("1982-11-12"),
      gender: "Female",
      phone: "9876543210",
      abhaId: `MOCK-ABHA-${crypto.randomUUID().slice(0, 8)}`,
      preferredLanguage: "en",
    },
  });

  const visit = await db.visit.create({
    data: { patientId: patient.id, mode: "GENERAL", status: "IN_PROGRESS", priority: "NORMAL" },
  });

  for (const c of ["history_collection", "document_processing", "mock_abdm_sharing"] as const) {
    await db.consent.create({ data: { visitId: visit.id, type: c, granted: true, version: "v1.0" } });
  }

  const answers = [
    { q: "chief", label: "What is troubling you today?", a: "Severe chest pain and tightness" },
    { q: "duration", label: "When did this start?", a: "1–3 days ago" },
    { q: "severity", label: "How severe is it?", a: "Severe (7–10)" },
    { q: "breathlessness", label: "Are you having difficulty breathing?", a: "Yes" },
    { q: "sweating", label: "Any cold sweating, fainting, or dizziness?", a: "Yes" },
    { q: "history", label: "Any known illness, medicines, or allergies?", a: "Diabetes; Metformin 500 mg; no known allergies" },
  ];
  for (const x of answers) {
    await db.historyAnswer.create({
      data: {
        visitId: visit.id,
        questionId: x.q,
        label: x.label,
        answer: x.a,
        inputMode: "VOICE",
      },
    });
  }

  // Deterministic triage (same rules as src/server/triage.ts)
  const chief = answers.find((x) => x.q === "chief")!.a.toLowerCase();
  const chest = chief.includes("chest pain") || chief.includes("chest discomfort");
  const breathless = answers.find((x) => x.q === "breathlessness")!.a.toLowerCase() === "yes";
  const sweating = answers.find((x) => x.q === "sweating")!.a.toLowerCase() === "yes";
  const flags: { ruleId: string; message: string }[] = [];
  if (chest && breathless) {
    flags.push({
      ruleId: "CHEST_BREATHLESS",
      message: "Chest symptoms with breathlessness: immediate clinical assessment recommended.",
    });
  }
  if (chest && sweating) {
    flags.push({
      ruleId: "CHEST_SWEATING",
      message: "Chest symptoms with sweating/dizziness: triage staff should assess now.",
    });
  }
  for (const f of flags) {
    await db.redFlag.create({ data: { visitId: visit.id, ruleId: f.ruleId, severity: "URGENT", message: f.message } });
  }
  await db.visit.update({
    where: { id: visit.id },
    data: { priority: flags.length > 0 ? "URGENT" : "NORMAL", status: "READY_FOR_REVIEW", completedAt: new Date() },
  });

  const doc = await db.document.create({
    data: {
      visitId: visit.id,
      filename: "previous_lab_report.pdf",
      type: "lab_report",
      ocrStatus: "MOCK_COMPLETE",
      extractedText: "MOCK OCR — Hb 9.2 g/dL; Blood Glucose 168 mg/dL; Metformin 500 mg",
      entities: {
        create: [
          { entityType: "investigation", name: "Hemoglobin", value: "9.2", unit: "g/dL", abnormal: true },
          { entityType: "investigation", name: "Blood Glucose", value: "168", unit: "mg/dL", abnormal: true },
          { entityType: "medication", name: "Metformin", value: "500", unit: "mg", abnormal: false },
        ],
      },
    },
  });

  const summary = [
    "Chief concern: Severe chest pain and tightness.",
    "Structured history: " + answers.filter((x) => x.q !== "chief").map((x) => `${x.label}: ${x.a}`).join("; ") + ".",
    ...(flags.length ? [`Triage alert: ${flags.map((f) => f.message).join(" ")}`] : []),
    `Document extraction (MOCK; clinician validation required): ${doc.extractedText}`,
    "Clinical documentation aid only — no diagnosis or treatment recommendation. Requires clinician verification.",
  ].join("\n\n");
  await db.clinicalSummary.create({
    data: { visitId: visit.id, summaryText: summary, status: "PENDING" },
  });

  await db.auditLog.createMany({
    data: [
      { actor: "patient-kiosk", action: "REGISTERED_AND_CONSENTED", resourceType: "visit", resourceId: visit.id, metadata: { mode: "GENERAL" } },
      { actor: "patient-kiosk", action: "MOCK_OCR_PROCESSED", resourceType: "document", resourceId: doc.id, metadata: { filename: doc.filename } },
      { actor: "patient-kiosk", action: "SUMMARY_GENERATED", resourceType: "visit", resourceId: visit.id },
    ],
  });

  console.log(`Urgent demo visit created: ${visit.id} (priority URGENT, ${flags.length} red flags)`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => db.$disconnect());
