import { createServerSupabaseClient } from "@/lib/supabase";

export const revalidate = 300;

async function getTopSolvers() {
  const supabase = await createServerSupabaseClient();
  const { data } = await supabase
    .from("solutions")
    .select("user_id, profiles(username)")
    .limit(1000);

  if (!data) return [];

  // Count unique levels solved per user
  const counts: Record<string, { username: string; count: number }> = {};
  for (const row of data) {
    const uid = row.user_id;
    const prof = row.profiles as unknown as { username: string } | null;
    const name = prof?.username ?? "???";
    if (!counts[uid]) counts[uid] = { username: name, count: 0 };
    counts[uid].count++;
  }

  return Object.values(counts)
    .sort((a, b) => b.count - a.count)
    .slice(0, 50);
}

export default async function RankingsPage() {
  const solvers = await getTopSolvers();

  return (
    <div className="max-w-2xl mx-auto px-6 py-12">
      <h1 className="text-3xl font-bold mb-2">Global Rankings</h1>
      <p className="text-[var(--muted)] mb-8">Most levels solved overall.</p>

      {solvers.length === 0 ? (
        <div className="text-center py-20 text-[var(--muted)]">
          <div className="text-5xl mb-4">🏆</div>
          <p>No solutions yet. Start playing to claim the top spot!</p>
        </div>
      ) : (
        <div className="bg-[var(--surface)] border border-[var(--border)] rounded-xl overflow-hidden">
          <div className="grid grid-cols-[40px_1fr_80px] gap-4 px-5 py-3 text-xs text-[var(--muted)] border-b border-[var(--border)]">
            <span>Rank</span>
            <span>Player</span>
            <span className="text-right">Solved</span>
          </div>
          {solvers.map((solver, i) => (
            <div
              key={solver.username}
              className={`grid grid-cols-[40px_1fr_80px] gap-4 px-5 py-3.5 text-sm border-b border-[var(--border)] last:border-0 ${
                i < 3 ? "bg-[var(--accent-dim)]/20" : ""
              }`}
            >
              <span className="font-mono text-[var(--muted)]">
                {i === 0 ? "🥇" : i === 1 ? "🥈" : i === 2 ? "🥉" : `#${i + 1}`}
              </span>
              <span className="font-medium">{solver.username}</span>
              <span className="text-right text-[var(--accent)] font-semibold">
                {solver.count}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
