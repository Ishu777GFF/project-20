import { initTRPC, TRPCError } from "@trpc/server";
import { ZodError } from "zod";
import superjson from "superjson";
import type { FetchCreateContextFnOptions } from "@trpc/server/adapters/fetch";

/**
 * Demo-only auth. The kiosk sends `X-Role: PATIENT`, the doctor console sends
 * `X-Role: DOCTOR`. This is deliberately transparent for the SIH demonstration;
 * production would replace it with OIDC + ABDM identity, consent and session handling.
 */
export type DemoRole = "PATIENT" | "DOCTOR" | "ADMIN";

export function resolveRole(headers: Headers): DemoRole {
  const raw = (headers.get("x-role") || "").toUpperCase();
  return raw === "DOCTOR" || raw === "ADMIN" ? raw : "PATIENT";
}

export async function createContext(opts: FetchCreateContextFnOptions) {
  return { role: resolveRole(opts.req.headers) };
}

export type Context = Awaited<ReturnType<typeof createContext>>;

const t = initTRPC.context<Context>().create({
  transformer: superjson,
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      message: error.code === "INTERNAL_SERVER_ERROR" && process.env.NODE_ENV === "production" ? "Something went wrong" : shape.message,
      data: {
        ...shape.data,
        zodError: error.code === "BAD_REQUEST" && error.cause instanceof ZodError ? error.cause.flatten() : null,
      },
    };
  },
});

export const router = t.router;
export const publicProcedure = t.procedure;

export const patientProcedure = t.procedure.use(({ next }) =>
  next({ ctx: { role: "PATIENT" as DemoRole } }),
);

function requireRole(ctx: Context, allowed: DemoRole[]) {
  if (!allowed.includes(ctx.role)) {
    throw new TRPCError({
      code: "FORBIDDEN",
      message: `${allowed.join(" or ")} role required in this demo`,
    });
  }
}

export const patientGuard = t.procedure.use(({ ctx, next }) => {
  requireRole(ctx, ["PATIENT", "ADMIN"]);
  return next();
});

export const doctorGuard = t.procedure.use(({ ctx, next }) => {
  requireRole(ctx, ["DOCTOR", "ADMIN"]);
  return next();
});

export const adminGuard = t.procedure.use(({ ctx, next }) => {
  requireRole(ctx, ["ADMIN"]);
  return next();
});
