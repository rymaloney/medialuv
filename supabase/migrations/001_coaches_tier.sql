-- Migration: 001_coaches_tier
-- Adds paid-tier subscription columns to the coaches table,
-- a case-insensitive unique index on email, and RLS policies.
-- Idempotent: safe to run more than once.

-- ── Columns ──────────────────────────────────────────────────────────────────

alter table coaches
  add column if not exists tier text default 'free'
    check (tier in ('free', 'season', 'lifetime'));

alter table coaches
  add column if not exists upgraded_at timestamptz;

alter table coaches
  add column if not exists stripe_customer_id text;

-- ── Index ─────────────────────────────────────────────────────────────────────

create unique index if not exists coaches_email_unique
  on coaches (lower(email));

-- ── Row-Level Security ────────────────────────────────────────────────────────

alter table coaches enable row level security;

-- Authenticated users may read only their own row (matched by email from JWT).
drop policy if exists "Coaches read own row" on coaches;
create policy "Coaches read own row" on coaches
  for select
  using (auth.jwt() ->> 'email' = email);

-- No public insert / update policies.
-- The Stripe-webhook Edge Function uses the service_role key, which
-- bypasses RLS entirely -- no additional policy is needed for writes.
