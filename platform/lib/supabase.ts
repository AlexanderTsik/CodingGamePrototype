import { createBrowserClient } from "@supabase/ssr";

const SUPABASE_URL = "https://sdogpbddeaevheqennbe.supabase.co";
const SUPABASE_ANON_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkb2dwYmRkZWFldmhlcWVubmJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1NTAyMDAsImV4cCI6MjA5MjEyNjIwMH0.fjo7zfbBeFqrEVH9zqSsncxpNoTIcqW4NtKZNT4UWeE";

// Browser client — safe to use in Client Components
export function createClient() {
  return createBrowserClient(SUPABASE_URL, SUPABASE_ANON_KEY);
}

// Types matching our Supabase schema
export type Level = {
  id: string;
  author_id: string;
  name: string;
  description: string | null;
  grid_data: object;
  starter_code: string;
  hint_text: string;
  is_official: boolean;
  is_published: boolean;
  play_count: number;
  solve_count: number;
  avg_rating: number;
  created_at: string;
  profiles?: { username: string } | null;
};

export type Solution = {
  id: string;
  user_id: string;
  level_id: string;
  code: string;
  move_count: number;
  code_length: number;
  time_taken: number | null;
  completed_at: string;
  profiles?: { username: string } | null;
};

export type Profile = {
  id: string;
  username: string;
  avatar_url: string | null;
  bio: string | null;
  created_at: string;
};
