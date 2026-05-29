"use client";

import Link from "next/link";
import { useEffect } from "react";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="flex flex-1 flex-col items-center justify-center gap-4 px-6 py-24 text-center">
      <div className="text-5xl">🐞</div>
      <h1 className="text-2xl font-bold">Something went wrong</h1>
      <p className="max-w-md text-sm text-[var(--muted)]">
        An unexpected error occurred. You can try again, or head back home.
      </p>
      <div className="mt-2 flex gap-3">
        <button
          onClick={reset}
          className="rounded-lg bg-[var(--accent)] px-5 py-2 font-semibold text-black hover:opacity-90"
        >
          Try again
        </button>
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
