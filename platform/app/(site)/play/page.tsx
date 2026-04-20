"use client";

import { useRef, useState, useEffect } from "react";

export default function PlayPage() {
  const containerRef = useRef<HTMLDivElement>(null);
  const [isFullscreen, setIsFullscreen] = useState(false);

  useEffect(() => {
    const onChange = () => setIsFullscreen(!!document.fullscreenElement);
    document.addEventListener("fullscreenchange", onChange);
    return () => document.removeEventListener("fullscreenchange", onChange);
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
          src="/game/CodingGamePrototype.html"
          className="w-full h-full border-0"
          allow="autoplay; fullscreen"
          title="LediBug Game"
        />
      </div>
    </div>
  );
}
