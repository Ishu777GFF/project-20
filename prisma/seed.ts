import { PrismaClient } from "@prisma/client";

const db = new PrismaClient();

async function main() {
  const existing = await db.patient.count();
  if (existing > 0) {
    console.log("Database already has data; skipped seed.");
    return;
  }

  await db.user.createMany({
    data: [
      { name: "Dr. Ananya Rao", role: "DOCTOR" },
      { name: "Demo Administrator", role: "ADMIN" },
      { name: "Kiosk (public)", role: "PATIENT" },
    ],
  });

  const patient = await db.patient.create({
    data: {
      fullName: "Arjun Patel",
      dob: new Date("1987-04-08"),
      gender: "Male",
      phone: "9876543210",
      abhaId: "MOCK-ABHA-12345678",
      preferredLanguage: "en",
    },
  });

  const visit = await db.visit.create({
    data: {
      patientId: patient.id,
      mode: "GENERAL",
      status: "READY_FOR_REVIEW",
      priority: "NORMAL",
      completedAt: new Date(),
    },
  });

  await db.clinicalSummary.create({
    data: {
      visitId: visit.id,
      summaryText:
        "Chief concern: seasonal cough for 5 days. No breathlessness, chest pain, or fever reported.\n\nClinical documentation aid only — requires clinician verification.",
      status: "PENDING",
    },
  });

  await db.auditLog.create({
    data: {
      actor: "system",
      action: "SEEDED_DEMO_CASE",
      resourceType: "visit",
      resourceId: visit.id,
    },
  });

  console.log("Seeded Arjun Patel demo case.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => db.$disconnect());
