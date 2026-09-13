# MediKiosk AI — API documentation (tRPC)

Base URL: `http://localhost:3000/api/trpc` — a tRPC v11 HTTP endpoint using the
httpBatchLink wire format with superjson. Any tRPC client (or raw URL-encoded
GET/POST) can call it. Role is sent as the `X-Role` header (`PATIENT`, `DOCTOR`,
`ADMIN`; anything else is treated as `PATIENT`). This is a **demo-only** mechanism.

Type-safe usage from this repo:

```ts
import { api } from "@/lib/api";

const visit = await utils.client.createVisit.mutate({
  fullName: "Meera Sharma",
  language: "en",
  mode: "GENERAL",
  consents: ["history_collection", "document_processing", "mock_abdm_sharing"],
  demo: false,
});
```

## Procedures

### `bootstrap` — public
Returns `{ questions: { GENERAL: Question[], AYUSH: Question[] }, mockNotices: string[] }`.

### `createVisit` — requires PATIENT or ADMIN
Input:

```ts
{
  fullName: string;
  dob?: string;            // ISO date
  gender?: string;
  phone?: string;
  language?: "en" | "hi";
  mode?: "GENERAL" | "AYUSH";
  consents?: ("history_collection" | "document_processing" | "mock_abdm_sharing")[];
  demo?: boolean;          // UI-only flag; never persisted
}
```

Returns `{ visitId, patientId, mockAbha, questions }`. `mockAbha` is a locally
generated **MOCK** identifier.

### `saveAnswer` — requires PATIENT or ADMIN
Input: `{ visitId (uuid), questionId, label, answer (min 1 char), inputMode?: "TOUCH" | "TEXT" | "VOICE" }`.
Upserts the answer (unique per visit+question), then **reruns deterministic triage**
and returns `{ priority: "NORMAL" | "URGENT", flags: { ruleId, message }[] }`.
Red-flag rules: chest-related chief complaint + breathlessness → `CHEST_BREATHLESS`;
chest-related chief complaint + sweating/dizziness → `CHEST_SWEATING`. Rules escalate
only; they never diagnose.

### `uploadDocument` — requires PATIENT or ADMIN
Input: `{ visitId (uuid), filename, size? }`.
**MOCK OCR**: stores the document with `ocrStatus: "MOCK_COMPLETE"` and canned
entities (Hemoglobin 9.2 g/dL abnormal, Blood Glucose 168 mg/dL abnormal,
Metformin 500 mg). The uploaded file's contents are never read. Returns
`{ documentId, status, extractedText, entities }`.

### `completeVisit` — requires PATIENT or ADMIN
Input: `{ visitId (uuid) }`. Builds the structured summary (chief concern, history,
triage alerts, mock document extraction, verification disclaimer), sets the visit to
`READY_FOR_REVIEW`, and returns `{ summary }`.

### `doctorQueue` — requires DOCTOR or ADMIN
No input. Returns visits with status `READY_FOR_REVIEW`/`REVIEWED`, URGENT first:
`{ id, priority, status, startedAt, fullName, gender, dob }[]`.

### `doctorCase` — requires DOCTOR or ADMIN
Input: `{ visitId (uuid) }`. Returns the full case payload
(`{ visit: { …, patient, answers, redFlags, documents.entities, summary }, audit }`)
and writes a `VIEWED_CASE` audit entry.

### `reviewSummary` — requires DOCTOR or ADMIN
Input: `{ visitId (uuid), summaryText, status: "PENDING" | "CONFIRMED" | "REJECTED" }`.
Version-bumps the summary, stamps the reviewer, and moves the visit to `REVIEWED`
(on confirm) or back to `READY_FOR_REVIEW`. Audits `SUMMARY_<STATUS>`.

### `fhirExport` — requires DOCTOR or ADMIN
Input: `{ visitId (uuid) }`. Returns a FHIR R4-shaped `Bundle`
(`Patient`, `Encounter`, per-answer `Observation`, per-document
`DocumentReference`, and `Composition` when a summary exists). **MOCK ABDM export**:
displayed in the UI only, never transmitted.

### `auditLog` — requires ADMIN
No input. Last 100 audit events, newest first.

## Error semantics

tRPC errors carry codes: `BAD_REQUEST` (zod validation), `FORBIDDEN` (role check),
`NOT_FOUND` / `INTERNAL_SERVER_ERROR`. The error formatter adds `zodError.flatten()`
for validation failures. In production builds, unexpected internal errors are masked.
