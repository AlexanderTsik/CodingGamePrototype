import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

// Publishable anon credentials (same as lib/supabase*.ts).
const SUPABASE_URL = "https://sdogpbddeaevheqennbe.supabase.co";
const SUPABASE_ANON_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkb2dwYmRkZWFldmhlcWVubmJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1NTAyMDAsImV4cCI6MjA5MjEyNjIwMH0.fjo7zfbBeFqrEVH9zqSsncxpNoTIcqW4NtKZNT4UWeE";

// Refreshes the Supabase auth session on each navigation so Server Components
// see a valid session. The @supabase/ssr pattern requires this — without it,
// server-rendered auth state goes stale once the access token expires.
export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabase = createServerClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) =>
          response.cookies.set(name, value, options)
        );
      },
    },
  });

  // IMPORTANT: do not run code between createServerClient and getUser() —
  // getUser() is what refreshes the token and writes the updated cookies.
  await supabase.auth.getUser();

  return response;
}

export const config = {
  // Run on all routes except static assets and the embedded game files.
  matcher: ["/((?!_next/static|_next/image|favicon.ico|game).*)"],
};
