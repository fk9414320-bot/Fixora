# Putting Fixora online

Before you start: bookings are stored in one file (`data/db.json`). Wherever you host, that file must live on a disk
that survives restarts. Free plans usually wipe it, so every booking would disappear.

## Option A: Render (easiest, small monthly fee)
Render's free plan has no persistent disk (data is lost on each restart or sleep), so use the paid "Starter" type.
1. Put the whole `fixora-backend` folder, including your own `public/fixora.html`, on GitHub (private repo). `.env` and `data/` are already ignored.
2. On render.com choose New > Blueprint, pick the repo. It reads `render.yaml`.
3. Fill in the asked values: `ADMIN_KEY` (long random phrase), `PUBLIC_URL` (the https address Render gives you), and the SMTP/Anthropic values if you use them.
4. After the first deploy, open `https://YOUR-ADDRESS/admin`.
5. In the admin, open Reports > Download backup now and then, and keep the file safe.

## Option B: your own small server (VPS)
1. Rent the cheapest Linux VPS and install Node 20+.
2. Copy the folder, create `.env` (see `.env.example`) and add `NODE_ENV=production`, `TRUST_PROXY=1`, `PUBLIC_URL=https://yourdomain.com`.
3. Keep it running with pm2: `npm i -g pm2 && pm2 start server.js --name fixora && pm2 save && pm2 startup`
4. Put Caddy in front for free HTTPS. Caddyfile (two lines):
   ```
   yourdomain.com {
       reverse_proxy localhost:3000
   }
   ```
5. Backups: the server also keeps 14 daily copies in `data/backups/`.

## After it is online
- Technicians open `https://YOUR-ADDRESS/tech` on their phones.
- Use a long ADMIN_KEY. Wrong tries are limited, but a long key is your real protection.
- Test one booking end to end (book, assign, technician taps through, email arrives).

## Option C: Vercel (hosting) + Supabase (database)
Free tiers work. Bookings live in Supabase, so nothing is lost on redeploys.

1. **Supabase**: create a project at supabase.com. Open *SQL Editor*, paste the contents of `supabase.sql`, press Run.
2. In Supabase *Project Settings > API* copy the **Project URL** and the **service_role** key (the secret one).
3. **GitHub**: put this whole folder in a new private repo (`public/`, `api/`, `server.js`, `vercel.json`, `package.json`).
4. **Vercel**: *Add New > Project*, pick the repo, leave build settings empty. Before deploying add Environment Variables:
   `ADMIN_KEY`, `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, `PUBLIC_URL` (your vercel address), plus `SMTP_*`, `ADMIN_EMAIL`, `ANTHROPIC_API_KEY` if you use them. Deploy.
5. Open `https://your-project.vercel.app/admin`, log in with ADMIN_KEY, create technician PINs, make a test booking.
6. Moving old bookings from `data/db.json`: not automatic. Start fresh, or ask for an import script.

Notes:
- Visitor rate limits are per server instance on Vercel, so they only slow abuse; they do not stop it completely.
- Gmail SMTP may be slow or blocked from Vercel. If emails fail, check the mail status line in admin; an email API (Resend, Brevo) is the usual fix.
- Free Supabase projects pause after a week of no use; open the dashboard to resume.