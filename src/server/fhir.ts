import { db } from "@/server/db";

export type FhirBundle = {
  mock_abdm_export: true;
  resourceType: "Bundle";
  type: "collection";
  entry: { resource: Record<string, unknown> }[];
};

/**
 * Builds a FHIR R4-compatible Bundle for a visit. This is a MOCK ABDM export:
 * nothing is transmitted anywhere, and the bundle is only shaped like a FHIR
 * document for demonstration purposes.
 */
export async function buildFhirBundle(visitId: string): Promise<FhirBundle | null> {
  const visit = await db.visit.findUnique({
    where: { id: visitId },
    include: {
      patient: true,
      answers: { orderBy: { createdAt: "asc" } },
      documents: true,
      summary: true,
    },
  });
  if (!visit) return null;

  const patientRef = { reference: `Patient/${visit.patientId}` };
  const entries: FhirBundle["entry"] = [
    {
      resource: {
        resourceType: "Patient",
        id: visit.patient.id,
        name: [{ text: visit.patient.fullName }],
        gender: visit.patient.gender?.toLowerCase(),
        birthDate: visit.patient.dob?.toISOString().slice(0, 10),
        identifier: [
          {
            system: "https://abdm.gov.in/mock",
            value: visit.patient.abhaId,
          },
        ],
      },
    },
    {
      resource: {
        resourceType: "Encounter",
        id: visit.id,
        status: "finished",
        subject: patientRef,
        class: { code: "AMB" },
      },
    },
    ...visit.answers.map((a) => ({
      resource: {
        resourceType: "Observation",
        status: "final",
        code: { text: a.label },
        valueString: a.answer,
        subject: patientRef,
      },
    })),
    ...visit.documents.map((d) => ({
      resource: {
        resourceType: "DocumentReference",
        status: "current",
        description: `Mock OCR: ${d.filename}`,
        subject: patientRef,
      },
    })),
  ];

  if (visit.summary) {
    entries.push({
      resource: {
        resourceType: "Composition",
        status: "final",
        title: "Clinical intake summary — requires clinician verification",
        subject: patientRef,
        section: [
          {
            text: { status: "generated", div: visit.summary.summaryText },
          },
        ],
      },
    });
  }

  return { mock_abdm_export: true, resourceType: "Bundle", type: "collection", entry: entries };
}
