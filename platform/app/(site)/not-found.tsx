import Link from "next/link";

export default function NotFound() {
  return (
    <div className="flex flex-1 flex-col items-center justify-center gap-4 px-6 py-24 text-center">
      <div className="text-5xl">🐞</div>
      <h1 className="text-3xl font-bold">404 — Not found</h1>
      <p className="max-w-md text-sm text-[var(--muted)]">
        That page or level doesn’t exist. It may have been removed or never published.
      </p>
      <div className="mt-2 flex gap-3">
        <Link
          href="/levels"
          className="rounded-lg bg-[var(--accent)] px-5 py-2 font-semibold text-black hover:opacity-90"
        >
          Browse levels
        </Link>
        <Link
          href="/"
          className="rounded-lg border border-[var(--border)] px-5 py-2 hover:border-[var(--accent)]"
        >
          Home
        </Link>
      </div>
    </div>
  );
}
