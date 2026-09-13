export function patientAccessCode(fullName: string, dob: string) {
  const firstName = fullName.trim().split(/\s+/)[0]?.replace(/[^a-zA-Z]/g, "").toUpperCase() || "PATIENT";
  const day = dob.split("-")[2] || "00";
  return `PT-${firstName}${day}`;
}
