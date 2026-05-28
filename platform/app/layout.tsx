import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "LediBug — Learn to Code Through Play",
  description:
    "Solve grid puzzles by writing code. Share levels, compete on efficiency, and learn real programming concepts.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="min-h-screen flex flex-col" suppressHydrationWarning>{children}</body>
    </html>
  );
}
