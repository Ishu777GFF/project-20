-- Local account credentials for the MediKiosk prototype.
-- Passwords are stored as salted hashes, never as plaintext.
ALTER TABLE "users" ADD COLUMN "access_code" TEXT;
ALTER TABLE "users" ADD COLUMN "password_hash" TEXT;
ALTER TABLE "patients" ADD COLUMN "access_code" TEXT;
ALTER TABLE "patients" ADD COLUMN "password_hash" TEXT;

CREATE UNIQUE INDEX "users_access_code_key" ON "users"("access_code");
CREATE UNIQUE INDEX "patients_access_code_key" ON "patients"("access_code");
