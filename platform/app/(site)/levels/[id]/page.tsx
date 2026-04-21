import { createServerSupabaseClient } from "@/lib/supabase-server";
import { notFound } from "next/navigation";
import Link from "next/link";

export const revalidate = 30;

async function getLevel(id: string) {
  const supabase = await createServerSupabaseClient();
  const { data } = await supabase
    .from("levels")
    .select("*, profiles(username)")
    .eq("id", id)
    .eq("is_published", true)
    .single();
  return data;
}

type LeaderboardEntry = {
  move_count: number;
  code_length: number;
  profiles: { username: string } | null;
};

async function getLeaderboard(id: string) {
  const supabase = await createServerSupabaseClient();
  const { data } = await supabase
    .from("solutions")
    .select("move_count, code_length, profiles(username)")
    .eq("level_id", id)
    .order("move_count", { ascending: true })
    .order("code_length", { ascending: true })
    .limit(10);
  return (data ?? []) as unknown as LeaderboardEntry[];
}

export default async function LevelDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const [level, leaderboard] = await Promise.all([getLevel(id), getLeaderboard(id)]);

  if (!level) notFound();

  const levelProfiles = level.profiles as { username: string } | null;

  return (
    <div className="max-w-6xl mx-auto px-6 py-10 flex flex-col gap-8">
      {/* Header */}
      <div className="flex flex-col gap-2">
        <Link href="/levels" className="text-sm text-[var(--muted)] hover:text-[var(--text)]">
          ← Back to levels
        </Link>
        <div className="flex items-start justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold">{level.name}</h1>
            {levelProfiles && (
              <p className="text-sm text-[var(--muted)] mt-1">by {levelProfiles.username}</p>
            )}
          </div>
          <div className="flex items-center gap-3 text-sm text-[var(--muted)] shrink-0">
            <span>✓ {level.solve_count} solves</span>
            <span>▶ {level.play_count} plays</span>
          </div>
        </div>
        {level.description && (
          <p className="text-[var(--muted)]">{level.description}</p>
        )}
      </div>

      {/* Game + Leaderboard */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Embedded game */}
        <div className="lg:col-span-2">
          <div className="rounded-xl overflow-hidden border border-[var(--border)]" style={{ height: 560 }}>
            <iframe
              src={`/game/CodingGamePrototype.html?level_id=${id}`}
              className="w-full h-full border-0"
              allow="autoplay; fullscreen"
              title="LediBug Game"
            />
          </div>
        </div>

        {/* Leaderboard */}
        <div className="bg-[var(--surface)] border border-[var(--border)] rounded-xl p-5 flex flex-col gap-4">
          <h2 className="font-semibold text-lg">Leaderboard</h2>

          {leaderboard.length === 0 ? (
            <p className="text-[var(--muted)] text-sm">No solutions yet — be the first!</p>
          ) : (
            <div className="flex flex-col gap-1">
              <div className="grid grid-cols-[24px_1fr_48px_48px] gap-2 text-xs text-[var(--muted)] pb-2 border-b border-[var(--border)]">
                <span>#</span>
                <span>Player</span>
                <span className="text-right">Moves</span>
                <span className="text-right">Code</span>
              </div>
              {leaderboard.map((entry, i) => (
                <div key={i} className="grid grid-cols-[24px_1fr_48px_48px] gap-2 text-sm py-1.5">
                  <span className="text-[var(--muted)]">{i + 1}</span>
                  <span className="truncate font-medium">{entry.profiles?.username ?? "???"}</span>
                  <span className="text-right text-[var(--accent)]">{entry.move_count}</span>
                  <span className="text-right text-[var(--muted)]">{entry.code_length}</span>
                </div>
              ))}
            </div>
          )}

          <div className="mt-auto pt-4 border-t border-[var(--border)] text-xs text-[var(--muted)]">
            Ranked by fewest moves, then shortest code.
          </div>
        </div>
      </div>
    </div>
  );
}
