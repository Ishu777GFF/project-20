import { db } from "@/server/db";
import type { Prisma } from "@prisma/client";

export async function audit(
  actor: string,
  action: string,
  resourceType: string,
  resourceId: string,
  metadata: Record<string, unknown> = {},
) {
  await db.auditLog.create({
    data: {
      actor,
      action,
      resourceType,
      resourceId,
      metadata: metadata as Prisma.InputJsonValue,
    },
  });
}