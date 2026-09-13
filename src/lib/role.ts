/**
 * Demo-only role selection. The UI picks which demo persona is "logged in":
 * the kiosk speaks as PATIENT, the doctor console as DOCTOR. A real
 * deployment would replace this with OIDC + ABDM identity handling.
 */
export type DemoRole = "PATIENT" | "DOCTOR" | "ADMIN";

let currentRole: DemoRole = "PATIENT";

export function setDemoRole(role: DemoRole) {
  currentRole = role;
}

export function demoRoleHeader(): Record<string, string> {
  return { "X-Role": currentRole };
}
