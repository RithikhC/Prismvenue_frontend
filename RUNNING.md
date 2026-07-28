# Running Prism Venues end to end

Backend and frontend together, on one machine, against a real Supabase project.

- **Frontend** — this repo, `D:\ANP\Prismvenue_frontend`
- **Backend** — `D:\ANP\prismvenue-backend`

If you only want to look at the UI, skip all of this and run it on mocks:

```bash
flutter run -d chrome --dart-define=PRISM_USE_MOCKS=true
```

---

## One-time setup

### 1. Supabase project

Follow **`../prismvenue-backend/README.md` § Setup**, steps 1–6. It covers
creating the project, running the five migrations, creating the two test users,
switching the recovery email to a 6-digit code, seeding the demo venues, and
filling in `.env`.

That is the only place real credentials are entered, and they never leave the
backend. The app is told one thing: where the API lives.

### 2. Backend dependencies

```bash
cd D:\ANP\prismvenue-backend && python -m venv .venv && .venv/Scripts/python -m pip install -r requirements.txt
```

### 3. Frontend dependencies

```bash
cd D:\ANP\Prismvenue_frontend && flutter pub get
```

---

## Every time: two terminals

**Terminal 1 — backend**

```bash
cd D:\ANP\prismvenue-backend && .venv/Scripts/python -m uvicorn app.main:app --reload --port 8000
```

Wait for `database pool ready`. Confirm:

```bash
curl http://localhost:8000/health
```

You want `{"status":"ok","database":true}`. If `database` is `false`, the
`DATABASE_URL` in `.env` is wrong or the password needs URL-encoding.

**Terminal 2 — frontend**

```bash
cd D:\ANP\Prismvenue_frontend && flutter run -d chrome --web-port=8080 --dart-define=PRISM_API_BASE_URL=http://localhost:8000/v1
```

`--web-port=8080` is not optional. Flutter otherwise picks a random port each
run, and the browser will block the API calls unless that exact origin is
listed in the backend's `PRISM_CORS_ORIGINS`.

Sign in as `priya@marinacafe.com` (manager) or `arjun@marinacafe.com` (owner),
with the passwords you set in Supabase.

> On an iPad or simulator, swap `-d chrome --web-port=8080` for your device and
> replace `localhost` with your machine's LAN IP in **both** the
> `--dart-define` and `PRISM_CORS_ORIGINS`. A device cannot reach your
> laptop's `localhost`.

---

## Verification checklist

Work down it in order — each section assumes the ones above it passed. Every
item is something you can see on screen; none of it needs a debugger.

### Auth

- [ ] **Wrong password shows an error.** Sign in with a bad password. A red
      line appears under the fields. (Before this work it failed silently.)
- [ ] **Right password lands you in your role.** `priya@` → Floor screen.
      `arjun@` → Venues portfolio.
- [ ] **The venue name is real.** Top bar reads "Marina Café" — coming from the
      database, not the hardcoded mock constant it used to be. Rename the venue
      in Supabase, sign in again, and the top bar follows.
- [ ] **You stay signed in.** Reload the browser. You land back where you were
      without signing in again. (Previously a reload signed you out.)
- [ ] **Sign out sticks.** Account menu → Sign out → reload. Still signed out.
- [ ] **Password reset works end to end.** "Forgot Password" → your email →
      check the inbox for a **6-digit code**, not a link. Enter it, set a new
      password, sign in with it.
- [ ] **A wrong code is rejected.** Type `000000`. You get "That code is wrong
      or expired" and stay on the screen.

### Settings

- [ ] **Values come from the database.** Settings shows "26–70%", "Gentle",
      "Managers + floor". Change `volume_max_pct` in the Supabase table editor,
      reload the app — the row follows.
- [ ] **Changes persist.** Volume policy → drag a slider → go back → return.
      The new value is there. Reload the browser. Still there.
- [ ] **Quiet hours survive.** Note `quiet_hours_start_local` and
      `quiet_hours_cap_pct` in the `zone_guardrails` table. Toggle any setting
      in the app. Re-check those two columns — **still populated**. (The app has
      no field for them; a naive save would have nulled them.)
- [ ] **Alert delays are real minutes.** Set "Venue / zone offline" to 15 min.
      Check `offline_alert_minutes` in the table — it is `15`, not `2`.
- [ ] **"At close" is not a number.** Set "Left in takeover too long" to
      "At close". `takeover_alert_at_close` becomes `true`. Set it back to
      "2 hours" — the boolean clears and the minutes are intact.
- [ ] **Open hours round-trip.** Change everyday hours, add an exception for
      Fri & Sat. Both survive a reload.

### Venues

- [ ] **The portfolio is triaged.** As `arjun@`, Dockside (offline device) is
      first, then Marina Café (Terrace off-schedule), then Harbor House.
- [ ] **Offline is real.** In Supabase, set `devices.online = true` for
      Dockside's Bar zone. Reload — Dockside stops being red and moves down.
- [ ] **The quick-fix works.** Marina Café → Terrace's amber row →
      "Return to Auto". The row goes quiet. `zone_state.desired_mode` for that
      zone is now `auto`, and `desired_revision` went up by one.
- [ ] **Adding a venue works.** As `arjun@`, "+ Venue" → name, address, a zone
      → Add. It appears in the portfolio and in the `venues` table.
- [ ] **Managers cannot add venues.** As `priya@`, `/venues` is her single
      venue and there is no "+ Venue" button.
- [ ] **Removing a zone works.** Zone detail → "Remove zone". It disappears.
      In the database the row is *archived*, not deleted — recoverable, since
      no confirm dialog was ever designed.

### Schedule

- [ ] **The rail highlights the right row.** Floor screen's schedule rail marks
      the block covering the current time in Dubai (the venue's timezone), not
      your own.
- [ ] **The weekly plan loads** with five blocks per day, labelled "7 – 11 am",
      "11 am – 2 pm", and so on.
- [ ] **Times are a picker now, not free text.** Schedule → tap a daypart. The
      Time row has "Starts" and "Ends" fields that open the hour dial — the
      same dial as open hours.
- [ ] **Adding a daypart works.** Add one at 3pm–5pm. Its label reads
      "3 – 5 pm" — generated by the server from the hours you picked.
- [ ] **Self-drive ⇄ custom persists** across a reload.

### Playback

- [ ] **The hero shows the real mood.** Change `zone_state.desired_mood_id` in
      Supabase, reload — the hero card and mood grid follow.
- [ ] **Changing the vibe sticks.** Tap a mood tile → confirm. The hero updates.
      Check `zone_state`: `desired_mood_id` changed and `desired_revision` went
      up. The zone now shows as off-schedule on the Venues screen — a nudge is
      the middle rung of the control model.
- [ ] **Pause and resume.** Pause the room; the pill reads "Paused by Priya".
      Resume. If you had nudged a mood first, resuming keeps that mood rather
      than snapping back to auto.
- [ ] **Takeover counts down.** Start a 15-minute takeover. The banner counts
      down every second. Watch the browser's network tab — **no message per
      second from the server**; the app ticks locally.
- [ ] **Extend adds.** With ~14 minutes left, extend by 15. You get ~29, not 15.
- [ ] **Only one takeover at a time.** With one running, open the app in a
      second browser tab and try to start another. You get "Someone is already
      using the speakers here."
- [ ] **Handing back works.** "Return to Prism" → the zone is back on auto.

### Security

- [ ] **Tenant isolation holds.** Paste
      `../prismvenue-backend/tests/rls_cross_tenant.sql` into the Supabase SQL
      editor and run it. It should print `ALL RLS CHECKS PASSED`. This is the
      important one — it proves the database itself refuses cross-tenant reads
      and writes, rather than trusting the API to filter correctly.
- [ ] **No secret reached the app.** Search this repo for your Supabase keys:

      ```bash
      grep -ri "service_role\|supabase.co\|eyJ" lib/
      ```

      Nothing should match. The app only ever knows `PRISM_API_BASE_URL`.

### Regression

- [ ] `flutter analyze` — clean
- [ ] `flutter test` — 77 pass
- [ ] `cd ../prismvenue-backend && .venv/Scripts/python -m pytest -q` — 116 pass

---

## When something is wrong

| What you see | Usually means |
|---|---|
| Everything is blank / default values | The app cannot reach the API. Check terminal 1, and that the port in `--dart-define` matches. |
| Browser console shows a CORS error | The frontend's origin is not in `PRISM_CORS_ORIGINS`. Pin `--web-port=8080`. |
| `/health` says `"database": false` | `DATABASE_URL` is wrong, or the password needs URL-encoding (`@ : / ? # [ ] %`). |
| Sign-in returns 401 with correct credentials | The user exists in Supabase but has no `staff_profiles` row or role — re-run `seed_dev.sql`. |
| Every screen is empty but sign-in worked | RLS is denying everything. Usually migration 004 did not run, or the connection is using the transaction pooler (port 6543) which drops `SET LOCAL`. Use the session pooler or a direct connection. |
| The reset email contains a link, not a code | Backend README § Setup step 4 — the template needs `{{ .Token }}`. |
| Takeover always says "pending", never "applying" | Expected. `devices.online` is false and there is no device layer yet. Flip it manually in Supabase to exercise the online path. |
| Noise meter reads 0, hero context line is blank | Expected. Nothing writes telemetry — see the backend README's "Known gaps". |
