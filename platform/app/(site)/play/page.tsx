"use client";

import { useRef, useState, useEffect } from "react";
import { createClient } from "@/lib/supabase";

export default function PlayPage() {
  const containerRef = useRef<HTMLDivElement>(null);
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const [isFullscreen, setIsFullscreen] = useState(false);

  useEffect(() => {
    const onChange = () => setIsFullscreen(!!document.fullscreenElement);
    document.addEventListener("fullscreenchange", onChange);
    return () => document.removeEventListener("fullscreenchange", onChange);
  }, []);

  // Single-sign-on bridge with the game iframe. The platform stores its session
  // in cookies and the game in its own localStorage, so they can't see each
  // other — we reconcile them over postMessage (see scripts/network/auth_bridge.gd).
  useEffect(() => {
    const supabase = createClient();

    // Push the platform's current session down into the game.
    async function pushSession(target: Window) {
      const { data: { session } } = await supabase.auth.getSession();
      let payload: Record<string, string>;
      if (session) {
        const { data: prof } = await supabase
          .from("profiles")
          .select("username")
          .eq("id", session.user.id)
          .single();
        payload = {
          access_token: session.access_token,
          refresh_token: session.refresh_token,
          user_id: session.user.id,
          username: prof?.username ?? session.user.email ?? "",
        };
      } else {
        payload = { event: "logout" };
      }
      target.postMessage({ type: "ledibug:auth", payload }, window.location.origin);
    }

    // Mirror a game-side login/logout back into the platform's Supabase session.
    let syncing = false;
    async function applyFromGame(payload: Record<string, string>) {
      syncing = true;
      try {
        if (payload.event === "logout" || !payload.access_token) {
          await supabase.auth.signOut();
        } else {
          await supabase.auth.setSession({
            access_token: payload.access_token,
            refresh_token: payload.refresh_token,
          });
        }
      } finally {
        syncing = false;
      }
    }

    function onMessage(e: MessageEvent) {
      if (e.origin !== window.location.origin) return; // same-origin game only
      const d = e.data;
      if (!d || typeof d !== "object") return;
      if (d.type === "ledibug:ready") {
        if (iframeRef.current?.contentWindow) pushSession(iframeRef.current.contentWindow);
      } else if (d.type === "ledibug:auth") {
        applyFromGame(d.payload ?? {});
      }
    }
    window.addEventListener("message", onMessage);

    // Re-push whenever the platform's auth changes (login, logout, token refresh),
    // unless that change was one we just applied from the game.
    const { data: sub } = supabase.auth.onAuthStateChange(() => {
      if (syncing) return;
      if (iframeRef.current?.contentWindow) pushSession(iframeRef.current.contentWindow);
    });

    return () => {
      window.removeEventListener("message", onMessage);
      sub.subscription.unsubscribe();
    };
  }, []);

  const toggleFullscreen = () => {
    if (document.fullscreenElement) {
      document.exitFullscreen();
    } else {
      containerRef.current?.requestFullscreen();
    }
  };

  return (
    <div className="flex flex-col" style={{ height: "calc(100svh - 53px)" }}>
      {/* Toolbar */}
      <div className="flex items-center justify-between px-4 py-2 bg-[var(--surface)] border-b border-[var(--border)]">
        <div className="flex items-center gap-2 text-sm text-[var(--muted)]">
          <span className="text-base">🐞</span>
          <span className="font-medium text-[var(--text)]">LediBug</span>
          <span>— Tutorial Levels</span>
        </div>
        <button
          onClick={toggleFullscreen}
          className="flex items-center gap-2 text-xs px-3 py-1.5 rounded-lg border border-[var(--border)] hover:border-[var(--accent)] hover:text-[var(--accent)] transition-colors"
        >
          {isFullscreen ? (
            <>
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M8 3v3a2 2 0 0 1-2 2H3m18 0h-3a2 2 0 0 1-2-2V3m0 18v-3a2 2 0 0 1 2-2h3M3 16h3a2 2 0 0 1 2 2v3"/>
              </svg>
              Exit Fullscreen
            </>
          ) : (
            <>
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"/>
              </svg>
              Fullscreen
            </>
          )}
        </button>
      </div>

      {/* Game container */}
      <div ref={containerRef} className="flex-1 relative bg-black">
        <iframe
          ref={iframeRef}
          src="/game/CodingGamePrototype.html"
          className="w-full h-full border-0"
          allow="autoplay; fullscreen"
          title="LediBug Game"
        />
      </div>
    </div>
  );
}
