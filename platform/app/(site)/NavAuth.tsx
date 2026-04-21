"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";
import type { AuthChangeEvent, Session, User } from "@supabase/supabase-js";

export default function NavAuth() {
  const router = useRouter();
  const supabase = createClient();
  const [user, setUser] = useState<User | null>(null);
  const [username, setUsername] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      const { data } = await supabase.auth.getUser();
      setUser(data.user ?? null);
      if (data.user) fetchUsername(data.user.id);
    })();

    const { data: listener } = supabase.auth.onAuthStateChange((_event: AuthChangeEvent, session: Session | null) => {
      setUser(session?.user ?? null);
      if (session?.user) fetchUsername(session.user.id);
      else setUsername(null);
    });

    return () => listener.subscription.unsubscribe();
  }, []);

  async function fetchUsername(uid: string) {
    const { data } = await supabase.from("profiles").select("username").eq("id", uid).single();
    setUsername(data?.username ?? null);
  }

  async function signOut() {
    await supabase.auth.signOut();
    router.push("/");
    router.refresh();
  }

  if (!user) {
    return (
      <Link
        href="/auth"
        className="text-sm border border-[var(--border)] px-3 py-1.5 rounded-lg hover:border-[var(--accent)] hover:text-[var(--accent)] transition-colors"
      >
        Sign In
      </Link>
    );
  }

  return (
    <div className="flex items-center gap-3 text-sm">
      <span className="text-[var(--muted)]">
        👤 <span className="text-[var(--text)] font-medium">{username ?? user.email}</span>
      </span>
      <button
        onClick={signOut}
        className="border border-[var(--border)] px-3 py-1.5 rounded-lg hover:border-[var(--muted)] transition-colors text-[var(--muted)]"
      >
        Sign Out
      </button>
    </div>
  );
}
