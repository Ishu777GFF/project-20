import type { Metadata } from "next";
import { Providers } from "@/lib/providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "CareSetu — SIH26047 Prototype",
  description:
    "Patient case-taking software prototype: multilingual kiosk intake, deterministic triage, doctor verification. Demo only — not a diagnostic system.",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
