import Link from "next/link";
import { createServerSupabaseClient } from "@/lib/supabase-server";
import type { Level } from "@/lib/supabase";

export const revalidate = 60;

async function getLevels() {
  const supabase = await createServerSupabaseClient();
  const { data } = await supabase
    .from("levels")
    .select("id, name, description, solve_count, play_count, avg_rating, is_official, profiles(username)")
    .eq("is_published", true)
    .order("solve_count", { ascending: false })
    .limit(50);
  return (data ?? []) as unknown as Level[];
}

function DifficultyBadge({ rating }: { rating: number }) {
  if (rating === 0) return <span className="text-xs text-[var(--muted)]">Unrated</span>;
  if (rating < 2.5) return <span className="text-xs bg-green-900 text-green-300 px-2 py-0.5 rounded-full">Easy</span>;
  if (rating < 3.5) return <span className="text-xs bg-yellow-900 text-yellow-300 px-2 py-0.5 rounded-full">Medium</span>;
  return <span className="text-xs bg-red-900 text-red-300 px-2 py-0.5 rounded-full">Hard</span>;
}

export default async function LevelsPage() {
  const levels = await getLevels();

  return (
    <div className="max-w-5xl mx-auto px-6 py-12">
      <div className="flex items-center justify-between mb-8">
        <h1 className="text-3xl font-bold">Community Levels</h1>
        <span className="text-[var(--muted)] text-sm">{levels.length} levels</span>
      </div>

      {levels.length === 0 ? (
        <div className="text-center py-24 text-[var(--muted)]">
          <div className="text-5xl mb-4">🧩</div>
          <p className="text-lg">No community levels yet.</p>
          <p className="text-sm mt-2">Be the first — build a level in the game and publish it!</p>
          <Link href="/play" className="inline-block mt-6 bg-[var(--accent)] text-black font-semibold px-6 py-2 rounded-lg hover:opacity-90">
            Open Game
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {levels.map((level) => (
            <Link
              key={level.id}
              href={`/levels/${level.id}`}
              className="bg-[var(--surface)] border border-[var(--border)] rounded-xl p-5 flex flex-col gap-3 hover:border-[var(--accent)] transition-colors"
            >
              <div className="flex items-start justify-between gap-2">
                <h2 className="font-semibold leading-tight line-clamp-2">{level.name}</h2>
                {level.is_official && (
                  <span className="text-xs bg-[var(--accent-dim)] text-[var(--accent)] px-2 py-0.5 rounded-full shrink-0">
                    Official
                  </span>
                )}
              </div>

              {level.description && (
                <p className="text-sm text-[var(--muted)] line-clamp-2">{level.description}</p>
              )}

              <div className="flex items-center justify-between mt-auto pt-2">
                <DifficultyBadge rating={level.avg_rating} />
                <div className="flex items-center gap-3 text-xs text-[var(--muted)]">
                  <span>✓ {level.solve_count}</span>
                  <span>▶ {level.play_count}</span>
                </div>
              </div>

              {level.profiles && (
                <div className="text-xs text-[var(--muted)] border-t border-[var(--border)] pt-2">
                  by {level.profiles.username}
                </div>
              )}
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
