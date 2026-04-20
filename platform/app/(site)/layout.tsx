import Link from "next/link";

export default function SiteLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <nav className="border-b border-[var(--border)] bg-[var(--surface)] px-6 py-3 flex items-center gap-6">
        <Link
          href="/"
          className="text-[var(--accent)] font-bold text-xl tracking-tight"
        >
          🐞 LediBug
        </Link>
        <div className="flex items-center gap-5 text-sm text-[var(--muted)]">
          <Link href="/play" className="hover:text-[var(--text)] transition-colors">
            Play
          </Link>
          <Link href="/levels" className="hover:text-[var(--text)] transition-colors">
            Levels
          </Link>
          <Link href="/rankings" className="hover:text-[var(--text)] transition-colors">
            Rankings
          </Link>
        </div>
      </nav>

      <main className="flex-1">{children}</main>

      <footer className="border-t border-[var(--border)] py-6 text-center text-xs text-[var(--muted)]">
        LediBug — Learn to code, one bug at a time.
      </footer>
    </>
  );
}
