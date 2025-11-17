
# Features to build

OAuth login for web app using Wagtail/Ninja API end point.  User data persistence in Django DB.  Google OAuth start. 

Backend Wagtail/Ninja entry point python code - /features/f1/backend/wt/api.py

Frontend Next.js entry point typescript code - /features/f1/frontend/web/app/

Google oath registered URI - http://localhost:3000/api/auth/callback/google

## Feature 1: Next.js / Auth.js → Django token exchange
### Motivation / Summary

Let the Next.js front end perform OAuth sign-in via Auth.js (NextAuth), maintain a stateless session (JWT cookie), and then exchange the OAuth identity for a Django-issued API token to call the Django + Wagtail backend RPC/Ninja APIs. This isolates identity on the front end and persists user “truth” in Django.

Goals / Success Criteria
	•	After sign-in, users receive a Django-issued access token (HttpOnly cookie) that is used for all API calls to Django Ninja endpoints.
	•	The Next.js app remains stateless w.r.t session unless desired (no DB session store).
	•	The setup works in your dev environment and in Cloud Run / GCP production.
	•	Refresh / rotation of tokens (if applicable) is secure and robust.
	•	You can support multiple OAuth / OIDC providers (e.g. Google now; later Microsoft, GitHub).

### Documentation and examples

https://next-auth.js.org/configuration/providers/oauth
https://next-auth.js.org/configuration/callbacks 
https://next-auth.js.org/configuration/events
https://next-auth.js.org/configuration/nextjs
https://next-auth.js.org/configuration/pages
https://next-auth.js.org/providers/google
https://next-auth.js.org/getting-started/typescript
https://github.com/nextauthjs/next-auth-example
/examples/google.ts
https://next-auth.js.org/v3/adapters/models    
https://developers.google.com/identity/protocols/oauth2
https://next-auth.js.org/providers/google
https://django-ninja.dev/guides/authentication/
https://docs.djangoproject.com/en/5.2/topics/auth/default/#django.contrib.auth.views.LoginView.authentication_form


### Minimum code sketch 
Minimal code sketches (just the glue)

Next.js (Auth.js config)
/app/api/auth/[...nextauth]/route.ts

import NextAuth from "next-auth";
import Google from "next-auth/providers/google";

const handler = NextAuth({
  session: { strategy: "jwt" },
  providers: [
    Google({ clientId: process.env.GOOGLE_ID!, clientSecret: process.env.GOOGLE_SECRET! })
  ],
  callbacks: {
    async jwt({ token, account, profile }) {
      // On first login, attach provider identity for the exchange
      if (account?.provider && account.id_token) {
        token.provider = account.provider;
        token.id_token = account.id_token;   // OIDC ID token (when available)
      }
      if (profile?.sub) token.sub = profile.sub;
      if (profile?.email) token.email = profile.email;
      return token;
    },
    async session({ session, token }) {
      session.user.sub = token.sub as string;
      session.user.email = token.email as string;
      session.provider = token.provider as string | undefined;
      // Do NOT expose id_token to the browser unless you must
      return session;
    },
  },
});
export { handler as GET, handler as POST };

Next.js exchange route
### Next.js exchange route

```javascript
// /app/api/exchange/route.ts
import { NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { cookies } from "next/headers";

export async function POST(req: NextApiRequest, res: NextApiResponse) {
  const session = await getServerSession({ req });
  if (!session?.user?.email) return NextResponse.json({ error: "Unauthenticated" }, { status: 401 });

  // Server-only: pull the ID token from the Auth.js JWT via a server call if you stored it server-side
  const idToken = /* retrieve securely (e.g., server token store) */ null;

  const res = await fetch(process.env.DJANGO_URL + "/api/auth/exchange", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    // Send only what Django needs to verify:
    body: JSON.stringify({
      provider: session.provider,
      subject: session.user.sub,
      email: session.user.email,
      id_token: idToken, // if available
    }),
  });

  if (!res.ok) return NextResponse.json({ error: "Exchange failed" }, { status: 401 });
  const { access, expires_in } = await res.json();

  // Set HTTP-only cookie for Django access
  const cookieOptions = {
    httpOnly: true,
    sameSite: "lax",
    secure: true,
    maxAge: expires_in
  };
  res.setHeader("Set-Cookie", `django_access=${access};${Object.entries(cookieOptions).map(([key, value]) => `${key}=${value}`).join(";")}`);
  return NextResponse.json({ ok: true });
}
```

Django (Ninja): exchange endpoint

```markdown
# auth/api.py
from ninja import NinjaAPI, Schema
from django.contrib.auth import get_user_model
from ninja.errors import HttpError
from .tokens import issue_access_token  # wrap SimpleJWT or ninja-jwt

api = NinjaAPI()

class ExchangeIn(Schema):
    """Validate provider assertion"""
    provider: str
    subject: str | None = None  # Subject (sub) from the provider assertion"""

Use django-ninja-jwt for the token exchange endpoint

## Feature 2: User persistence

With Auth.js “JWT session” you keep the session itself stateless (no session rows in a Next.js DB), while you persist real user data in your backend DB (Django). Here’s the recipe and why it works.

The model (mental + data)
	•	Session (stateless): Auth.js stores an encrypted/signed JWT in an HttpOnly cookie. No DB lookup is needed to read the session.  ￼
	•	User/profile (stateful): You persist user accounts and profiles in Django (e.g., User, Profile, SocialAccount). The JWT session only carries minimal identity claims so your app can call Django and “exchange” for a Django API token.  ￼

JWTs are just compact, signed claim containers (RFC 7519)—perfect for carrying a few fields without a session table.  ￼

Step-by-step: “JWT session” + persistent user data

1) Configure Auth.js to use JWT sessions

// /app/api/auth/[...nextauth]/route.ts
import NextAuth from "next-auth"
import Google from "next-auth/providers/google"

const handler = NextAuth({
  session: { strategy: "jwt" }, // stateless sessions
  secret: process.env.AUTH_SECRET, // or NEXTAUTH_SECRET
  providers: [Google({ clientId: process.env.GOOGLE_ID!, clientSecret: process.env.GOOGLE_SECRET! })],
})
export { handler as GET, handler as POST }

	•	strategy: "jwt" = cookie holds an encrypted JWT; no adapter or session table is required.
	•	Set AUTH_SECRET/NEXTAUTH_SECRET so the JWT can be verified/rotated correctly.  ￼

2) Add callbacks to embed just what you need

Use JWT and session callbacks to attach the provider identity you’ll later send to Django (e.g., provider, sub, maybe an ID token while it’s fresh).

// still in NextAuth config
callbacks: {
  async jwt({ token, account, profile }) {
    if (account?.provider) token.provider = account.provider
    if (account?.id_token) token.id_token = account.id_token       // OIDC ID Token (if issued)
    if (profile?.sub) token.sub = profile.sub
    if (profile?.email) token.email = profile.email
    return token
  },
  async session({ session, token }) {
    // expose minimal identity to your app (avoid putting id_token into session)
    session.user.sub = token.sub as string
    session.user.email = token.email as string
    session.provider = token.provider as string | undefined
    return session
  },
}

Callbacks are the official hook to shape session/JWT contents.  ￼

3) Read the JWT session on server routes

Use Auth.js helpers to read the session/JWT in server code (API routes, server actions, middleware).
	•	getServerSession() (v4) / auth() (v5 API) to get the session,
	•	or getToken() to read the raw JWT.  ￼

4) Exchange into a Django API token (your persistence boundary)

After sign-in, call a Next.js server route like /api/exchange that:
	1.	Reads the Auth.js session/JWT,
	2.	Posts the minimal identity (provider, sub, optionally id_token) to Django.
Django verifies the provider identity and upserts your real user rows (User/Profile/SocialAccount) in your DB, then returns a short-lived Django access JWT (and optional refresh).
This keeps long-term truth in Django, with a stateless session on the Next.js side. (You already have these Django pieces from your Option-A plan.)  ￼

5) Keep the Django token server-side

Have the /api/exchange route set the Django access token as an HttpOnly cookie (separate from the Auth.js cookie). Your browser/API calls then include that token to hit Ninja endpoints. (Auth.js session ≠ Django API token.)

Persistence details & best practices
	•	What to store where
	•	Auth.js JWT: only minimal claims (e.g., sub, provider, email), short maxAge.
	•	Django DB: full user record, profile, provider link. This is your durable store.
	•	Rotation & expiry
	•	If you keep provider access tokens for background calls, rotate them using the official Refresh Token Rotation pattern in your JWT callback (Auth.js shows an example). Don’t bloat the session JWT with lots of provider data unless you must.  ￼
	•	Revocation
	•	JWT sessions are not instantly revocable server-side. Mitigate with short lifetimes, periodic rotation, or a blocklist if you truly need forced logout-everywhere. (Auth.js docs call this trade-off out for JWT sessions.)  ￼
	•	Security knobs
	•	Use HttpOnly, Secure, SameSite cookies.
	•	Set the proper secret (AUTH_SECRET/NEXTAUTH_SECRET).  ￼

Minimal “glue” example for the exchange

Next.js route (reads Auth.js session, calls Django, sets Django token cookie):

// /app/api/exchange/route.ts
import { NextResponse } from "next/server"
import { getToken } from "next-auth/jwt"  // or getServerSession()

export async function POST(req: Request) {
  const jwt = await getToken({ req, secret: process.env.AUTH_SECRET })
  if (!jwt?.sub || !jwt?.provider) return NextResponse.json({ error: "unauthenticated" }, { status: 401 })

  const res = await fetch(process.env.DJANGO_URL + "/api/auth/exchange", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      provider: jwt.provider,
      sub: jwt.sub,
      email: jwt.email,
      id_token: jwt.id_token, // if present; prefer server-side use only
    }),
  })

  if (!res.ok) return NextResponse.json({ error: "exchange_failed" }, { status: 401 })
  const { access, expires_in } = await res.json()

  const rsp = NextResponse.json({ ok: true })
  rsp.cookies.set("django_access", access, { httpOnly: true, secure: true, sameSite: "lax", maxAge: expires_in })
  return rsp
}

getToken()/getServerSession() are the recommended ways to read the Auth.js JWT/session server-side.  ￼

⸻

TL;DR
	•	Use session: { strategy: "jwt" } to keep Next.js sessions stateless and lightweight.  ￼
	•	Persist actual user data in Django’s DB during the exchange step.
	•	Read the JWT session via getServerSession() / getToken() and forward only the needed claims to Django.  ￼
	•	Handle token rotation (if you store provider tokens) in the Auth.js JWT callback.  ￼

### Documentation and examples
https://eadwincode.github.io/django-ninja-jwt/getting_started/?utm_source=chatgpt.com#usage
https://eadwincode.github.io/django-ninja-jwt/auth_integration/
https://eadwincode.github.io/django-ninja-jwt/settings/
https://eadwincode.github.io/django-ninja-jwt/customizing_token_claims/
Ninja-JWT Source code repo https://github.com/eadwinCode/django-ninja-jwt
https://docs.wagtail.org/en/6.4/advanced_topics/customization/custom_user_models.html#custom-user-models

## Table definition
 CREATE TABLE verification_token (
    identifier TEXT NOT NULL,
    expires TIMESTAMPTZ NOT NULL,
    token TEXT NOT NULL,
    PRIMARY KEY (identifier, token)
  );

  CREATE TABLE accounts (
    id SERIAL,
    "userId" INTEGER NOT NULL,
    type VARCHAR(255) NOT NULL,
    provider VARCHAR(255) NOT NULL,
    "providerAccountId" VARCHAR(255) NOT NULL,
    refresh_token TEXT,
    access_token TEXT,
    expires_at BIGINT,
    id_token TEXT,
    scope TEXT,
    session_state TEXT,
    token_type TEXT,
    PRIMARY KEY (id)
  );

  CREATE TABLE sessions (
    id SERIAL,
    "userId" INTEGER NOT NULL,
    expires TIMESTAMPTZ NOT NULL,
    "sessionToken" VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
  );

  CREATE TABLE users (
    id SERIAL,
    name VARCHAR(255),
    email VARCHAR(255),
    "emailVerified" TIMESTAMPTZ,
    image TEXT,
    PRIMARY KEY (id)
  );

  Table Purposes

  - users - Stores user account information (id, name, email, etc.)
  - accounts - Links users to OAuth/social provider accounts (Google, GitHub, etc.)
  - sessions - Manages active user sessions with expiration
  - verification_token - Handles email verification and password reset tokens
  - Follow Django/Wagtail best practices


