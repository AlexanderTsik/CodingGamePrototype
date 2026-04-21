import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Godot 4 web exports require SharedArrayBuffer, which needs these two headers
  // on every response that originates from the game path.
  async headers() {
    return [
      {
        source: "/game/:path*",
        headers: [
          { key: "Cross-Origin-Embedder-Policy", value: "require-corp" },
          { key: "Cross-Origin-Opener-Policy",   value: "same-origin"  },
        ],
      },
      // The /play page itself also needs to be cross-origin isolated so the
      // iframe inherits the correct context.
      {
        source: "/play",
        headers: [
          { key: "Cross-Origin-Embedder-Policy", value: "require-corp" },
          { key: "Cross-Origin-Opener-Policy",   value: "same-origin"  },
        ],
      },
    ];
  },
};

export default nextConfig;
