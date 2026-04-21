import Link from "next/link";
import { createServerSupabaseClient } from "@/lib/supabase-server";

export const revalidate = 60;

async function getStats() {
  try {
    const supabase = await createServerSupabaseClient();
    const [{ count: levelCount }, { count: solutionCount }] = await Promise.all([
      supabase.from("levels").select("*", { count: "exact", head: true }).eq("is_published", true),
      supabase.from("solutions").select("*", { count: "exact", head: true }),
    ]);
    return { levels: levelCount ?? 0, solutions: solutionCount ?? 0 };
  } catch {
    return { levels: 0, solutions: 0 };
  }
}

export default async function HomePage() {
  const stats = await getStats();

  return (
    <div className="flex flex-col items-center justify-center flex-1 px-6 py-20 text-center">
      <div className="text-7xl mb-6">🐞</div>
      <h1 className="text-5xl font-bold mb-4 tracking-tight">LediBug</h1>
      <p className="text-xl text-[var(--muted)] max-w-xl mb-10">
        Learn to code by guiding a bug through grid puzzles. Write real programs,
        share your levels, and compete on efficiency.
      </p>

      <div className="flex flex-col sm:flex-row gap-4 mb-16">
        <Link
          href="/play"
          className="bg-[var(--accent)] text-black font-bold px-8 py-3 rounded-xl text-lg hover:opacity-90 transition-opacity"
        >
          Play Now
        </Link>
        <Link
          href="/levels"
          className="border border-[var(--border)] px-8 py-3 rounded-xl text-lg hover:border-[var(--accent)] transition-colors"
        >
          Browse Levels
        </Link>
      </div>

      {(stats.levels > 0 || stats.solutions > 0) && (
        <div className="flex gap-10 text-center">
          <div>
            <div className="text-3xl font-bold text-[var(--accent)]">{stats.levels}</div>
            <div className="text-sm text-[var(--muted)] mt-1">Community Levels</div>
          </div>
          <div>
            <div className="text-3xl font-bold text-[var(--accent)]">{stats.solutions}</div>
            <div className="text-sm text-[var(--muted)] mt-1">Solutions Submitted</div>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 mt-20 max-w-3xl w-full text-left">
        {[
          { icon: "✍️", title: "Write Real Code", body: "Use a custom language with variables, loops, and functions to control the bug." },
          { icon: "🏆", title: "Compete on Efficiency", body: "Fewest moves wins. Shortest code wins. Climb the global leaderboard." },
          { icon: "🧩", title: "Build & Share", body: "Design your own puzzle levels and publish them for the community to solve." },
        ].map(({ icon, title, body }) => (
          <div key={title} className="bg-[var(--surface)] border border-[var(--border)] rounded-xl p-5">
            <div className="text-2xl mb-3">{icon}</div>
            <h2 className="font-semibold mb-2">{title}</h2>
            <p className="text-sm text-[var(--muted)]">{body}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
