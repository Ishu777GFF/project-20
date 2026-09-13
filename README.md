# MediKiosk AI — T3 Stack (Next.js + tRPC + Prisma + PostgreSQL)

> Demonstration prototype for **SIH26047 Patient Case-Taking Software**. A clinical
> intake and documentation aid — **not** a diagnostic or treatment system.

This is the T3 Stack port of the MediKiosk AI prototype: **Next.js 15 (App Router) +
React 19 + tRPC v11 + Prisma 6 + Tailwind CSS 4 + PostgreSQL**. End-to-end type
safety: the doctor console consumes the exact TypeScript types the server returns.

## Stack

| Layer | Choice |
|---|---|
| Frontend | Next.js 15 App Router, React 19, Tailwind CSS 4 |
| API | tRPC v11 (App Router catch-all handler at `/api/trpc`) |
| Validation | zod on every procedure input |
| DB | PostgreSQL via Prisma 6 (`prisma/schema.prisma`) |
| Transport | superjson over httpBatchLink |

## Run locally

1. **PostgreSQL** — use an existing 15+ install and create a `medikiosk` database, or:

   ```bash
   npm run db:up   # docker run … postgres:16 on localhost:5432
   ```

2. **Configure** — copy `.env.example` to `.env.local` and adjust `DATABASE_URL`:

   ```
   DATABASE_URL="postgresql://postgres:postgres@localhost:5432/medikiosk"
   ```

3. **Install, migrate, seed, run:**

   ```bash
   npm install
   npm run db:migrate     # prisma migrate dev (applies prisma/migrations)
   npm run db:seed        # Arjun Patel routine case (skips if data exists)
   npm run db:demo        # optional: pre-load the urgent Meera Sharma case
   npm run dev
   ```

   Open **http://localhost:3000**.

Useful extras:

```bash
npm run typecheck       # tsc --noEmit
npm run build           # prisma generate && next build
npm run db:studio       # Prisma Studio data browser
npm run db:reset        # reset DB and re-apply migrations + seed
```

## What is implemented

- **Kiosk flow** — Hindi/English language switch, consent capture, registration,
  General / AYUSH pathway selection, adaptive bilingual question flow, voice capture
  (browser Speech Recognition when available), touch-first choice buttons, document
  upload step, summary generation.
- **Doctor console** — priority queue (URGENT first), case workspace with editable
  clinical summary, confirm / reject actions, structured history, document entities,
  FHIR bundle viewer, audit timeline.
- **Deterministic triage** — rule-based red flags (`CHEST_BREATHLESS`,
  `CHEST_SWEATING`) recalculated on every saved answer. Never diagnoses; only
  escalates to `URGENT` for human assessment.
- **Persistence** — Prisma models: `User`, `Patient`, `Visit`, `Consent`,
  `HistoryAnswer`, `Document`, `DocumentEntity`, `RedFlag`, `ClinicalSummary`,
  `AuditLog`.
- **Role-based access** — demo `X-Role` header mapped through tRPC middleware:
  patient endpoints require `PATIENT`/`ADMIN`, doctor endpoints `DOCTOR`/`ADMIN`,
  the audit feed is `ADMIN`-only.

## Clearly-labelled mocks

Everything below is a **prototype mock**, labelled `MOCK` in the UI and API:

- **ABHA ID** — generated locally (`MOCK-ABHA-…`); no identity verification.
- **OCR / entity extraction** — every upload returns the same canned result
  (Hb 9.2 g/dL, Glucose 168 mg/dL, Metformin 500 mg); the file contents are not read.
- **ABDM integration / FHIR export** — a FHIR R4-shaped `Bundle` is built in-memory
  for display; nothing is transmitted to any gateway.
- **Role auth** — the `X-Role` header is client-chosen for transparency.
- **Voice** — browser Speech Recognition when available; no server-side ASR.

## API surface (tRPC procedures)

All endpoints live under `/api/trpc` (batched JSON-RPC). Procedure map:

| Procedure | Guard | Purpose |
|---|---|---|
| `bootstrap` | public | question bank + mock notices |
| `createVisit` | PATIENT | register patient + consents + visit |
| `saveAnswer` | PATIENT | upsert answer, rerun deterministic triage |
| `uploadDocument` | PATIENT | MOCK OCR + entity extraction |
| `completeVisit` | PATIENT | generate structured summary, enter queue |
| `doctorQueue` | DOCTOR | priority-ordered review queue |
| `doctorCase` | DOCTOR | full case workspace payload + audit |
| `reviewSummary` | DOCTOR | edit + confirm/reject, versioned |
| `fhirExport` | DOCTOR | FHIR R4 bundle (mock ABDM) |
| `auditLog` | ADMIN | global audit feed (last 100 events) |

## Data model

See `prisma/schema.prisma`. Migrations are committed under `prisma/migrations/`.
Reset anytime with `npm run db:reset`.

## 5-minute SIH demo script

1. Landing → **Patient kiosk** → pick **English** → tick consent → **Load urgent demo**
   (this replays the scripted Meera Sharma chest-pain case with voice-tagged answers).
2. In the intake step, show the Hindi toggle and the voice/touch question flow.
3. Note the red **URGENT** escalation appearing immediately after the
   breathlessness/sweating answers — deterministic rules, no diagnosis.
4. On the upload step, process any file and show the labelled **MOCK OCR** result.
5. **Generate summary** → **Open doctor console** → open the urgent case → edit one
   sentence → **Confirm clinical summary** (audit timeline updates).
6. Click **FHIR export (MOCK ABDM)** to show the `Patient`, `Encounter`,
   `Observation`, `DocumentReference`, and `Composition` resources.

## Production path (out of prototype scope)

Replace the demo role header with OIDC/ABDM authentication, move to managed
PostgreSQL with a real migration policy, integrate an evaluated OCR pipeline with
human validation, use approved ABDM sandbox/production consent workflows for the
FHIR sender, and put clinical rules under governance with local clinical ownership.
