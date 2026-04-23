# Supabase Migrations

## 001_coaches_tier

Extends the `coaches` table with subscription-tier support:

| Column | Type | Notes |
|---|---|---|
| `tier` | `text` | `'free'` (default) · `'season'` · `'lifetime'` |
| `upgraded_at` | `timestamptz` | Set by the Stripe-webhook Edge Function on upgrade |
| `stripe_customer_id` | `text` | Populated when a Stripe Customer is created |

Also adds a case-insensitive unique index on `email` and enables RLS so each authenticated user can only read their own row.

---

## Applying the migration

### Option A — Supabase Dashboard SQL Editor (quickest)

1. Open your project → **SQL Editor** → **New query**
2. 2. Paste the contents of `001_coaches_tier.sql`
   3. 3. Click **Run** (or `Cmd + Enter`)
     
      4. The migration is idempotent — running it twice is safe.
     
      5. ### Option B — Supabase CLI
     
      6. ```bash
         # Link to your project (one-time)
         supabase link --project-ref <your-project-ref>

         # Push all pending migrations
         supabase db push
         ```

         > **Tip:** `supabase db push` applies every file in `supabase/migrations/` that hasn't been recorded yet.
         >
         > ---
         >
         > ## Environment variables required by the Stripe-webhook Edge Function
         >
         > Set these in **Supabase Dashboard → Project Settings → Edge Functions → Secrets** (or in your CI/CD environment):
         >
         > | Variable | Where to get it |
         > |---|---|
         > | `STRIPE_WEBHOOK_SECRET` | Stripe Dashboard → Developers → Webhooks → your endpoint → *Signing secret* |
         > | `SUPABASE_SERVICE_ROLE_KEY` | Supabase Dashboard → Project Settings → API → *service_role* key |
         >
         > > ⚠️ The `SUPABASE_SERVICE_ROLE_KEY` bypasses RLS. Keep it server-side only — never expose it in client code or commit it to version control.
