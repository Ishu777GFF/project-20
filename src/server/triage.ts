import { db } from "@/server/db";

export interface TriageResult {
  priority: "NORMAL" | "URGENT";
  flags: { ruleId: string; message: string }[];
}

/**
 * Deterministic, rule-based red-flag triage. No LLM, no diagnosis — the rules
 * only ever *escalate* a case for immediate human clinical assessment.
 */
export async function runTriage(visitId: string): Promise<TriageResult> {
  const answers = await db.historyAnswer.findMany({
    where: { visitId },
    select: { questionId: true, answer: true },
  });
  const a = Object.fromEntries(
    answers.map((x) => [x.questionId, x.answer.toLowerCase()]),
  );
  const chief = a.chief ?? "";
  const chest =
    chief.includes("chest pain") ||
    chief.includes("chest discomfort") ||
    chief.includes("सीने");

  const flags: { ruleId: string; message: string }[] = [];
  if (chest && a.breathlessness === "yes") {
    flags.push({
      ruleId: "CHEST_BREATHLESS",
      message:
        "Chest symptoms with breathlessness: immediate clinical assessment recommended.",
    });
  }
  if (chest && a.sweating === "yes") {
    flags.push({
      ruleId: "CHEST_SWEATING",
      message:
        "Chest symptoms with sweating/dizziness: triage staff should assess now.",
    });
  }

  await db.$transaction([
    db.redFlag.deleteMany({ where: { visitId } }),
    ...flags.map((f) =>
      db.redFlag.create({
        data: { visitId, ruleId: f.ruleId, severity: "URGENT", message: f.message },
      }),
    ),
    db.visit.update({
      where: { id: visitId },
      data: { priority: flags.length > 0 ? "URGENT" : "NORMAL" },
    }),
  ]);

  return { priority: flags.length > 0 ? "URGENT" : "NORMAL", flags };
}
