"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase";

export default function AuthPage() {
  const router = useRouter();
  const [mode, setMode] = useState<"login" | "register">("login");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [username, setUsername] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState("");

  const supabase = createClient();

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setSuccess("");
    setLoading(true);

    try {
      if (mode === "login") {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) { setError(error.message); return; }
        router.push("/");
        router.refresh();
      } else {
        const { error } = await supabase.auth.signUp({
          email,
          password,
          options: { data: { username: username || email.split("@")[0] } },
        });
        if (error) { setError(error.message); return; }
        // The profile row (with username) is created server-side by the
        // on_auth_user_created trigger — no client-side insert needed, which
        // also works when email confirmation is on (no session yet).
        setSuccess("Account created! You can now sign in.");
        setMode("login");
      }
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex flex-col items-center justify-center flex-1 px-6 py-16">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="text-5xl mb-3">🐞</div>
          <h1 className="text-2xl font-bold">
            {mode === "login" ? "Sign in to LediBug" : "Create an account"}
          </h1>
          <p className="text-sm text-[var(--muted)] mt-2">
            {mode === "login"
              ? "Track your solutions and compete on leaderboards"
              : "Join the community and share your levels"}
          </p>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          {mode === "register" && (
            <div className="flex flex-col gap-1.5">
              <label className="text-sm font-medium">Username</label>
              <input
                type="text"
                value={username}
                onChange={e => setUsername(e.target.value)}
                placeholder="your_username"
                className="bg-[var(--surface)] border border-[var(--border)] rounded-lg px-3 py-2 text-sm outline-none focus:border-[var(--accent)] transition-colors"
              />
            </div>
          )}

          <div className="flex flex-col gap-1.5">
            <label className="text-sm font-medium">Email</label>
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              required
              placeholder="you@example.com"
              className="bg-[var(--surface)] border border-[var(--border)] rounded-lg px-3 py-2 text-sm outline-none focus:border-[var(--accent)] transition-colors"
            />
          </div>

          <div className="flex flex-col gap-1.5">
            <label className="text-sm font-medium">Password</label>
            <input
              type="password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              required
              placeholder="••••••••"
              className="bg-[var(--surface)] border border-[var(--border)] rounded-lg px-3 py-2 text-sm outline-none focus:border-[var(--accent)] transition-colors"
            />
          </div>

          {error && (
            <p className="text-sm text-red-400 bg-red-400/10 border border-red-400/20 rounded-lg px-3 py-2">
              {error}
            </p>
          )}
          {success && (
            <p className="text-sm text-green-400 bg-green-400/10 border border-green-400/20 rounded-lg px-3 py-2">
              {success}
            </p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="bg-[var(--accent)] text-black font-semibold py-2.5 rounded-lg hover:opacity-90 transition-opacity disabled:opacity-50 mt-1"
          >
            {loading ? "…" : mode === "login" ? "Sign In" : "Create Account"}
          </button>
        </form>

        <p className="text-center text-sm text-[var(--muted)] mt-6">
          {mode === "login" ? "No account?" : "Already have one?"}{" "}
          <button
            onClick={() => { setMode(mode === "login" ? "register" : "login"); setError(""); setSuccess(""); }}
            className="text-[var(--accent)] hover:underline"
          >
            {mode === "login" ? "Sign up" : "Sign in"}
          </button>
        </p>
      </div>
    </div>
  );
}
