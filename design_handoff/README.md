# Handoff: Prism Venues — iPad Dashboard (Flutter, front-end only)

This is a **design-to-code handoff spec**. Paste it into Claude Code as the source of truth.

## Overview
Prism Venues is a staff-facing iPad dashboard for venues running the Prism adaptive-audio engine. Staff change the room's "mood" (music vibe) with one tap, take over the speakers with their own audio, and admins manage schedules, venues/zones, and guardrail settings. Three roles: **Floor staff**, **Manager**, **Owner**.

## About the design files
The two HTML files bundled beside this README are **design references, not production code**:

- `Prism Venues Flow v3.1 (standalone).html` — all 32 screen frames on one pannable canvas, organized in 6 numbered sections. Open in any browser. The Dark/Light toggle in any frame's top bar actually switches the whole document's theme — use it to read both palettes.
- `Prism Venues User Flow (standalone).html` — interactive role-based flow map (filter by role, click nodes for detail).

**Fidelity: HIGH.** Colors, type, spacing, radii and copy are final. Recreate pixel-faithfully in Flutter using the tokens below. Do not redesign, add screens, or "improve" anything. Anything genuinely unspecified is in §6 — do not invent.

## Target
- **Platform:** iPad, tablet-first. Landscape is the designed orientation (frames are 860×602); portrait must reflow (see §6-A1).
- **Framework:** Flutter (Material 3 turned off / fully custom theme). Front-end only — **no backend**. All data behind repository interfaces returning mock data (the eventual stack is FastAPI + MQTT, so keep repositories async and stream-friendly, but stub everything).
- **Units:** treat design px as Flutter logical dp 1:1. The 860×602 frame maps to an 11" iPad landscape content area; use the numbers as-is with flex/expanded layout, not a global scale transform.

---

# 1. Design tokens

## 1.1 Color — Dark theme (default)
| Token | Hex/Value | Use |
|---|---|---|
| `screen` | `#16120E` | page background |
| `surface` | `#201A14` | top bar, nav bar, cards, rail, sheets |
| `tile` | `#262019` | inputs, idle chips, secondary buttons |
| `tile2` | `#342A1E` | slider tracks, toggle-off, deeper wells |
| `tint` | `#211B13` | mood-tile base under tint gradient |
| `border` | `rgba(246,236,220,.08)` | hairline borders |
| `borderStrong` | `rgba(246,236,220,.18)` | outlined buttons, sheet top border, focused-ish |
| `textPrimary` | `#F7F1E7` | headings, values |
| `textSecondary` | `#B3A794` | labels, meta |
| `textTertiary` | `#7A6F5E` | hints, disabled-ish, locked nav |
| `unfilled` | `rgba(246,236,220,.14)` | empty energy-bar segments |
| `accent` | `#C98A5E` | THE accent (copper). Primary buttons, active seg, fills, NOW badge |
| `accentSoft` | `rgba(201,138,94,.16)` | active-nav bg, pills, highlighted row bg |
| `accentText` | `#DFA277` | text/icons on accentSoft |
| `chipInk` | `#16120E` | text ON accent fills |
| `green` | `#3FB65B` | online dots, success |
| `red` | `#E5484D` | destructive only (Delete, Sign out, Remove, offline) |
| `amber` | `#F5A623` | warnings, takeover countdown |
| screenShadow | `0 24px 64px rgba(40,28,16,.30)` | frame presentation only — not needed in-app |

## 1.2 Color — Light theme
| Token | Hex/Value |
|---|---|
| `screen` `#F3EDE2` · `surface` `#FCF9F2` · `tile` `#F5EFE3` · `tile2` `#EAE1CF` · `tint` `#FBF7EF` |
| `border` `rgba(70,52,28,.10)` · `borderStrong` `rgba(70,52,28,.22)` |
| `textPrimary` `#2A2318` · `textSecondary` `#7E7260` · `textTertiary` `#A69A85` · `unfilled` `rgba(42,35,24,.12)` |
| `accent` `#B06F45` · `accentSoft` `rgba(176,111,69,.13)` · `accentText` `#9A5F3B` · `chipInk` `#FFFFFF` |
| `green` `#2FA24A` · `red` `#E5484D` · `amber` `#F5A623` |

Logo: white wordmark asset on dark, ink (`#201E1B`-recolored) asset on light. (Assets: `img/r13-white.png`, `img/r13-ink.png` inside the frames doc; export from there or request originals.)

## 1.3 Mood palette (6 moods, fixed set)
| Mood | Dot (dark) | Dot (light) | Playing gradient (150°) | BPM | Energy |
|---|---|---|---|---|---|
| Morning calm | `#2DD4A7` | `#1FA982` | `#34D3A8 → #0FA37B` | 80 | 2/5 |
| Daytime flow | `#84C44A` | `#699F35` | `#92CE58 → #5F9427` | 95 | 3/5 |
| Afternoon lift | `#F5A623` | `#E08F0E` | `#F7AE33 → #D9820E` | 110 | 4/5 |
| Evening warmth | `#E86C9E` | `#CB487E` | `#EF7FAC → #D14380` | 92 | 3/5 |
| Peak | `#F0564F` | `#D83A33` | `#F4685F → #D22F28` | 124 | 5/5 |
| Wind-down | `#9A8CF0` | `#6E5ED2` | `#A99CF4 → #6F5BE0` | 68 | 1/5 |

Idle mood-tile tint: `linear-gradient(150deg, moodColor@13%, moodColor@3%)` over `tint`, border `moodColor@22%`.

## 1.4 Typography
Fonts (google_fonts): **Newsreader** (serif; headings & mood names — mood names are *italic*) and **Hanken Grotesk** (all UI).

| Style | Font | Size/Weight | Notes |
|---|---|---|---|
| displaySerif | Newsreader | 34/700 | Sign-in "Hello!", reset headings, lh 1.05 |
| moodNameHero | Newsreader italic | 31/600 | lh 1.1 |
| screenTitle | Newsreader | 22/700 | e.g. "Open hours", "Settings" |
| dialogTitle | Newsreader | 21/700 | confirm dialogs |
| sheetTitle | Newsreader | 20/700 | bottom sheets |
| sectionH2 | Newsreader | 19/600 | "Moods" |
| moodNameTile | Newsreader italic | 19/600 | `.tname` |
| numeralHuge | Hanken | 64/800 | takeover countdown (amber) |
| numeralDial | Hanken | 58/800 | time-dial readout, ls -0.02em |
| otpDigit | Hanken | 24/800 | |
| body | Hanken | 14/400–600 | buttons 14/700 |
| bodySm | Hanken | 13–13.5/600–700 | row titles, dialog body (13.5/400 lh 1.5) |
| meta | Hanken | 11.5–12.5/400–700 | tile meta 11.5, rail names 12–12.5 |
| label | Hanken | 11/600–700 | field labels (textSecondary); nav labels 11 |
| labelCaps | Hanken | 10–11/700 | uppercase, ls .06–.12em ("NOW PLAYING", rail header) |
| micro | Hanken | 10–10.5/600–800 | pills 10/700, NOW badge 10/800, helpers 10.5 |

Floor: never below 10px.

## 1.5 Spacing scale
`2 · 4 · 6 · 8 · 9 · 10 · 12 · 14 · 16 · 18 · 20 · 22 · 30` (dp). Screen body padding **15–18**; card padding **24×22** (hero) / **13×15** (tiles) / **16** (rail, forms); list row padding **13×15**; field label margin **16 top / 8 bottom**.

## 1.6 Radii
| Use | r |
|---|---|
| pills, seg toggles, sign-in fields & buttons, sliders | 999 |
| screen corner (frame presentation only) | 20 |
| sheet top corners | 20 |
| dialogs | 18 |
| mood tiles | 16 |
| hero card, take-over btn, nav active bg | 14 |
| OTP boxes | 13 |
| settings rows, sheet action buttons, seg containers | 11–12 |
| inputs, day chips, small icon buttons | 9–10 |

## 1.7 Elevation
Flat by default (borders carry structure). Only: dialogs `0 30px 70px rgba(0,0,0,.55)`, sheets `0 -20px 60px rgba(0,0,0,.5)`, playing tile `0 12px 28px moodColor@28%`, account menu `0 22px 54px rgba(20,12,4,.5)`.

## 1.8 Iconography
Stroke icons, 24-grid, `stroke-width: 2` (2.2 chevrons/back, 2.6 checks), round caps/joins. Sizes: nav 20, bar/buttons 15–19, lock-mini 9. Use lucide-flutter or hand-port the SVG paths from the frames (they are inline in the HTML).

---

# 2. Screen-by-screen spec

Shared chrome first; per-screen deltas after. **All 32 frames live in the frames doc — captions below match its captions verbatim.**

## 2.0 Shared chrome (every screen after sign-in)

**TopBar** — h≈58 (12 v-pad + content), bg `surface`, bottom border 1px `border`. Row, padding `12,16`, gap 12:
- Left (flex): logo image h26. On sub-screens: back button first — 30×30, r9, bg `tile`, border `border`, chevron-left 15.
- Center (fixed): venue name 14/700 + status line 10 `textSecondary` with 6px `green` dot, gap 5 ("Marina Café" / "Main floor · online"). Sub-screens swap status for context ("Settings · Sound", "Open hours"…).
- Right (flex, end, gap 10): **Dark/Light seg** (see SegToggle) + **Avatar** 32×32 circle, initials 11/800 (PN bg `#84C44A` floor/manager-dark-ink; AR bg `#9A8CF0`). Tap → account menu: w216, r16, bg `surface`, border `borderStrong`, header row (38 avatar + name 14/700 + role 11 `textSecondary`, padding 14, bottom border) + "Sign out" row 13.5/700 `red` with log-out icon, padding 10×11, r10.

**BottomNav** — bg `surface`, top border 1px `border`, padding `9,14`, gap 4. **5 items** (Team was removed — do not add): Floor, Takeover, Schedule, Venues, Settings. Item: expanded column, icon 20 + label 11, gap 5, padding `8,4`, r14.
- Active: bg `accentSoft`, color `accentText`, label 700.
- Inactive: color `textSecondary`, label 600.
- **Locked** (role-gated): color `textTertiary`, icon 60% opacity, label prefixed with 9px lock glyph. Floor staff see Schedule/Venues/Settings locked; taps do nothing (no dialog designed).

**Theme toggle** behavior: switches the whole app theme instantly; logo swaps white↔ink. Persist choice.

## Section 00 — Sign in (all roles)

**S00-1 "Simple login — the backend lands the user in their role (Floor / Manager / Owner)"**
Full-screen `screen` bg, centered column w368: logo 44h (start-aligned, mb22) → "Hello!" 34/700 serif → "Sign in to get started" 15 `textSecondary` (mt12, mb30) → fields column gap 14: Email + Password. Field: h54, r999, bg `surface`, border 1px `border` (active field 1.5px `accent`), padding-h 20, leading icon 19 `textSecondary`, text 14.5 (password: 18/ls3 dots + trailing eye icon 18). → primary button "Sign in" h54 r999 bg `accent` text 16/700 `chipInk` mt22 → "Forgot Password" 13/600 `textSecondary` mt18 centered.
States: default shown; pressed/loading/error not designed (§6-B).

**S00-2 "Forgot password — email a verification code"** — same shell + back button 30×30 (r9, tile) above heading. "Reset your password" 34/700 serif → helper "Enter your email and we'll send you a 6-digit verification code." 15 `textSecondary` → email field (filled `priya@marinacafe.com`, accent border) → "Send verification code" h54 r999 accent → "Back to sign in" link.

**S00-3 "Enter code — 6-digit code from the email"** — heading "Enter the code", helper shows the email in 700 `textPrimary`. **OTP row**: 6 boxes, gap 9, square (flex-1, aspect 1), r13, bg `surface`; filled: border 1.5 `accent`, digit 24/800; next-empty + empties: border 1.5 `borderStrong`/`border`. → "Verify" button → "Didn't get it? **Resend code**" (13/600, link part `accent`).

**S00-4 "New password — enter and confirm"** — heading "Set a new password". Two labelled password fields (label 11/600 `textSecondary` mb7, indent 4): "New password" (accent border) / "Confirm password" (`borderStrong`). Match hint row mt12: 14px check icon + "At least 8 characters · both match" 11.5/600 `green`. → "Save new password" → returns to S00-1.

Landing after auth: Floor staff & Managers → Floor; Owners → Venues (portfolio).

## Section 01 — Floor (all roles; THE floor-staff home)

**S01-1 "Default — Prism is driving"**
Body = row: **main column** (padding 15, gap 20) + **schedule rail** (w268, fixed).
- **Hero card**: bg `surface`, border `border`, r14, padding `24,22`, row gap 20:
  - Pause button 64×64 circle bg `accent`, white pause icon 20.
  - Center (flex): "NOW PLAYING" 10/700 caps ls.06 `textSecondary`; mood row (wrap, gap 9): mood dot 11, name 31 italic serif, pill "Prism is driving" (accentSoft bg, accent text 10/700, 5px dot, padding 3×9, r999), context "mid-afternoon · ~60% full · clear" 10.5 `textSecondary`. **Noise row** mt10 gap 10: "Noise" 10/600, track h6 r999 bg `tile2` max-w260 with 62% `accent` fill + 14px white thumb, "62%" 12/700. Read-only display.
  - **Take over** button: h50, padding-h 22, r14, transparent, border 1.5 `borderStrong`, text 14/700 + headphones icon 17, gap 9.
- **Moods block**: header row mb11 — "Moods" 19 serif + "Tap to change the vibe · one tap" 11 `textSecondary`. **Grid 3×2, gap 12, tile h124.** MoodTile spec §3.
- **Schedule rail**: border-left 1px `border`, bg `surface`, padding 18. Header mb14: "TODAY'S SCHEDULE" labelCaps + "Auto" chip (10/700 `accentText` on `accentSoft`, r999, 3×9). 5 rows gap 16: time 11/700 `textSecondary` w34 + mood dot 8 + name 12. Past rows opacity .42. **Current row**: bg `accentSoft`, border 1px `accent`, r10, padding `8,9`, margin-h -3; time `accentText` 800, name 12.5/700, trailing "NOW" badge (10/800 `chipInk` on `accent`, r999, 2×7). Next row gets trailing "up next" 10 `textTertiary`.
Tap a mood tile → S01-3 confirm. Tap Take over → S02-1.

**S01-2 "Staff changed the mood & paused"** — same layout; hero shows play icon (room paused), pill swaps to "Paused by **Priya** · tap play to resume" style banner (amber-tinted pill), playing tile shows paused state (no eq animation). Resume → S01-1.

**S01-3 "Confirm before switching the vibe — no accidental changes"** — S01-1 dimmed under scrim `rgba(5,5,8,.62)` starting **below the top bar** (top bar stays visible). Centered **ConfirmDialog** (§3): icon = mood dot, title "Switch to Evening warmth?", body "The room eases over ~40s. 92 BPM · energy 3/5." Buttons: Cancel / "Switch the vibe" (accent). Confirm → S01-1 with new mood playing.

## Section 02 — Takeover (all roles; floor staff only if guardrail allows)

**S02-1 "Take over — hand the room to your own audio, or just change the vibe"**
Column, padding 15, gap 12. Two option cards (bg `surface`, border `border`, r14, padding 18): ① "Use your own audio" — icon + title 14/700 + sub 11.5 `textSecondary` "Plug in a phone, laptop, mixer, or mic. Prism goes quiet and the speakers are yours." ② "Just change the vibe" variant. Below: **"Hand back to Prism after"** label 11/600 → seg row (bg `tile`, border `border`, r11, padding 4; options flex-1, padding-v 8, r8, 11.5/700): `15 mins · [30 mins] · 1 hour · 2 hours` — selected bg `accent` `chipInk`. Helper "Returns automatically after 30 minutes." 10.5 mt9. Primary CTA starts takeover → S02-2.

**S02-2 "Active takeover — Prism is holding the room; return now or extend"**
Amber banner (bg `amber@12%`, border `amber@34%`, r13, h56): "Your audio is playing · started 2:12 pm". Centered **countdown "1:48"** 64/800 `amber`. Bottom row: "Extend" (secondary) → S02-4; "Return to Prism now" (primary accent) → S02-3.

**S02-3 "Confirm before returning to Prism — no accidental handbacks"** — ConfirmDialog over dimmed S02-2: icon rotate-ccw in accentSoft square 44 r12; title "Return to Prism now?"; body "Prism takes the room back and resumes **Afternoon lift**. Your own audio will stop playing on the speakers."; Cancel / "Return to Prism" → Floor.

**S02-4 "Extend — your audio keeps playing, Prism just waits longer"** — BottomSheet: title "Extend takeover", duration seg (same values), confirm "Extend". → S02-2 with updated countdown.

## Section 03 — Schedule (Manager + Owner)

**S03-1 "Self-drive — Prism reads the room, no fixed schedule"** — centered empty-state card (bg `surface`, border, r14): "Prism is self-driving" 17/700 + descriptive sub. Switch "Custom plan" → S03-2.
**S03-2 "Custom weekly plan — dayparts & moods, add any time"** — week header with date range + chevrons + "+ Add" accent button; day columns/daypart rows, each row: time range 11/700, mood dot+name, tap → S03-5. Toggle back to Self-drive.
**S03-3 "Jump to another week — tap the date to open the calendar"** — calendar popover; month grid, today ringed, selected filled accent.
**S03-4 "Add a daypart — pick day, time & mood"** — BottomSheet: day chips row, time fields, mood picker grid (6 tiles small), "Add daypart".
**S03-5 "Edit a daypart — same controls, plus Delete"** — same + full-width "Delete daypart" text button `red` at bottom.

## Section 04 — Venues

**S04-1 "Manager — operate one venue: catch zone problems & fix from the list"** (M+O) — venue header + zone rows (bg `surface`, r12, padding 13×15): zone name 13.5/600, status sub 11 (`red` if offline / amber if off-schedule with countdown), trailing quick-fix ("Return to Auto" 12/700 `accent` text-button) or chevron → zone detail (S05-5).
**S04-2 "Owner — triage the portfolio: problems shout, healthy venues whisper"** (O only) — sort chip "Needs attention"; venue rows: 32 initial-avatar, name 13.5/700, sub "1 zone · Peak" 11, problem rows carry red/amber status + "Return to Auto"; healthy rows quiet (no % values — deliberately removed). Row tap → S04-1 for that venue. "+ Venue" → S04-3.
**S04-3 "Add a venue — owner onboards a new location into the estate"** — form screen: Venue name, Home address (two-col), Open hours (from S05-6 pattern), zone chips + "+ Add zone" → S04-4. CTA "Add venue".
**S04-4 "Add a zone — name it, pick its player & hours"** — BottomSheet, **Zone name field only** ("Back patio", accent border) + helper "A zone is one area with its own speakers. Prism drives each zone on its own." Cancel / "Add zone" (flex 1:2).

## Section 05 — Guardrails & settings (Manager + Owner)

**S05-1 "Settings — Sound & Access guardrails (scrolls for more)"** — title "Settings" 22 serif + "Marina Café · you're a manager" sub. Grouped list (group label = labelCaps with icon): **Sound** → rows "Volume policy" (value "26–70%"), "Transition smoothness" ("Gentle"); **Access** → "Who can take over" ("Managers + floor"); **Place** → "Zones & open hours" ("2 · 7am–1?pm"); **Alerts** → offline / takeover-too-long rows; **Appearance** row. Row: bg `surface`, border, r12, padding 13×15; title 13.5/600, sub 11 `textSecondary`, value 12.5/600 `textSecondary`, chevron 15. Rows open S05-2…S05-9.
**S05-2 "Volume policy — the output band, daypart curve & floor-staff leeway"** — title + "This zone" scope chip (single option). Sliders: "Quietest it can go" 26% / "Loudest it can go" 70% (track h6 r999 `tile2`, fill accent, thumb 14 white); helper "Auto and staff stay inside this band…". "Quiet hours" row with toggle ("After 10:00 pm · cap at 55%"). **"Floor staff can"** seg: View only / [Nudge ±10%] / Full band. Helper "A floor nudge eases back to the curve after 2 hours."
**S05-3 "Transition smoothness — how slowly Prism eases between vibes"** — radio cards: Seamless (~60s) / **Gentle (~35s, selected — accent border + check)** / Lively (~8s); footer note. Selected card: bg `accentSoft`-tinted, border `accent`.
**S05-4 "Who can take over — dropdown: Manager / Manager + Floor"** — row + dropdown menu (surface, r12, options with check). This gates floor-staff takeover.
**S05-5 "Zone detail — name, hours, player, vibe, volume, remove"** — zone form + "Remove zone" `red`.
**S05-6 "Open hours — one default, only the exceptions stand out"** — title "Open hours"; seg **"Everyday timings"** (single full-width option, accent); default row "Every day · 7am–11pm" → S05-11; exceptions list + "+ Add exception" → S05-9.
**S05-7 "Venue / zone offline — dropdown: 2 / 5 / 15 / 30 min"** & **S05-8 "Left in takeover too long — dropdown: 1h / 2h / 4h / At close"** — alert rows with dropdown menus.
**S05-9 "Appearance — top-bar dropdown: Dark / Light / System device"** — dropdown anchored to the top-bar seg.
**S05-10 "Add an exception — pick days, hours & repeat"** — BottomSheet: title + sub "Different hours for some days — everything else keeps the default."; **Which days** — 7 chips Mon–Sun (gap 6, flex-1, padding-v 10, r10, 12/700; selected = accent bg/border + chipInk; Fri & Sat selected); **Hours** — Opens "7:00 am" (borderStrong + accent clock icon) / Closes "1:00 am" fields, helper "Tap a time to set it on the dial."; **"Closed all day"** row with toggle (42×24, knob 18; off = `tile2`) + sub "e.g. a public holiday"; **Repeat** seg: Just this once / [Every week]; Cancel / "Add exception" (1:2).
**S05-11 "Everyday hours — set the default open & close time"** — BottomSheet: sub "The default for Mon–Sun. Add exceptions for days that differ."; Opens 7:00 am / Closes 11:00 pm fields (16/800); helper "…open 16 hours."; Cancel / "Save hours".
**S05-12 "Set the time — drag the dial to the hour"** — BottomSheet: header "Opening time" + AM/[PM]-style seg (AM selected; padding 6×14, r999); readout **"7:00" 58/800 + "AM" 22/700 `textSecondary`**; slider: track h6 r999 `tile2`, fill 29% accent, thumb 26 white with 4px accent ring + shadow; tick labels below (12 am · 6 am · Noon · 6 pm · 12 am) 10.5/600 `textTertiary`; quick chips 7:00 (selected: accentSoft bg, accent border, accentText) · 8:00 · 9:00 · 10:00 (gap 7, padding-v 9, r9); Cancel / "Set 7:00 AM".

---

# 3. Reusable component inventory

| Component | Where | Props / variants | Spec |
|---|---|---|---|
| `PrismTopBar` | all post-auth | `{title, subtitle, showBack, avatar, onAvatarTap}` | §2.0 |
| `PrismBottomNav` | all post-auth | `{active, lockedTabs[]}` | §2.0; 5 fixed tabs |
| `SegToggle` | theme, durations, repeat, AM/PM, scope | `{options[], selected, pill(bool)}` | container bg `tile` border `border` r999(pill)/11 padding 3–4; item padding 5×12→9×0 flex, 11–12/700; selected bg `accent` `chipInk` |
| `MoodTile` | Floor, mood pickers | `{mood, state: idle\|playing\|paused}` | h124 r16 padding 13×15; idle: tint gradient+22% border, dot 11 + `EnergyBars`; playing: gradient pair, white text, `EqBars` + "Playing" chip (white@25% bg); name 19 italic serif bottom-anchored, meta 11.5 |
| `EnergyBars` | tiles | `{energy 1-5, color}` | 5 bars 3×10 r2 gap2; filled=mood color, rest `unfilled` |
| `EqBars` | playing tile | `{color}` | 4 bars 3×14 r2 gap2.5, scaleY .3↔1, 0.8s ease-in-out alternate, delays −.1/−.45/−.7/−.25s |
| `NoiseMeter` | Floor hero | `{value%}` read-only | h6 r999 `tile2`, accent fill, 14 white thumb, 12/700 value |
| `TakeOverButton` | Floor | — | h50 r14 outline 1.5 `borderStrong`, 14/700 + 17 icon |
| `StatusPill` | hero, banners | `{text, tone: accent\|amber\|green}` | r999 padding 3–5×9–11, 10–11/700, tone@16% bg |
| `ScheduleRail` | Floor | `{entries[], nowIndex}` | §2 S01-1 |
| `PrimaryButton` / `SecondaryButton` | sheets, dialogs, auth | `{label, expanded}` | h46 (54 auth) r12 (999 auth); accent+`chipInk` / `tile`+border+`textSecondary`; 14/700 (16 auth) |
| `PrismField` | auth, sheets | `{label?, value, focused, leading?, trailing?}` | auth: h54 r999; sheets: r10 padding 10×13 text 13, focused border 1.5 `accent`, label 11/600 mb7–8 |
| `OtpBoxes` | S00-3 | `{length 6, value}` | §2 S00-3 |
| `DayChips` | exceptions, dayparts | `{selected[]}` | §2 S05-10 |
| `PrismToggle` | quiet hours, closed-all-day | `{on}` | 42×24 r999; on bg `accent`, off `tile2`; knob 18 white |
| `SettingsRow` | settings, alerts | `{title, sub?, value?, chevron\|toggle\|dropdown}` | §2 S05-1 |
| `PrismBottomSheet` | add/edit flows | `{title, sub?, children, cancelLabel, primaryLabel}` | scrim `rgba(5,5,8,.6)` below top bar; sheet r20 top, bg `surface`, top border `borderStrong`, padding 20×20×18, handle 38×4 r99 centered mb16, title 20 serif, sub 11.5; footer gap 10, Cancel flex1 / primary flex2 |
| `ConfirmDialog` | vibe switch, return-to-Prism | `{icon, title, body, confirmLabel}` | w400 r18 bg `surface` border `borderStrong` padding 22 centered; icon well 44 r12 `accentSoft`; title 21 serif; body 13.5 lh1.5 `textSecondary`; two buttons h46 flex1 gap10 |
| `TimeDialSheet` | S05-12 | `{initial, onSet}` | §2 S05-12 |
| `AccountMenu` | top bar | `{user}` | §2.0 |
| `VenueRow` / `ZoneRow` | venues | `{status: ok\|offline\|offSchedule, quickFix?}` | §2 S04 |
| `DropdownMenu` | settings | `{options, selected}` | surface, r12, border `borderStrong`, option rows h≈40 with trailing check on selected |

---

# 4. Navigation map

Routes (go_router):
```
/signin            S00-1        /reset/email   S00-2
/reset/code        S00-3        /reset/new     S00-4
/floor             S01-1..3     /takeover      S02-1..4
/schedule          S03-1..5     /venues        S04-2 (owner) | S04-1 (manager)
/venues/:id        S04-1        /venues/add    S04-3
/settings          S05-1        (sheets & dialogs = modal routes on their parent)
```

Role gating (enforce in router redirect + locked nav):
- **floor**: `/floor`, `/takeover` only. Schedule/Venues/Settings tabs render locked.
- **manager**: everything except `/venues` portfolio view & `/venues/add` (their `/venues` IS their single venue, S04-1).
- **owner**: everything; lands on `/venues` (portfolio).

Edges (from the flow doc — labels = triggers):
- signin → floor (Floor/Manager) · signin → venues-portfolio (Owner) · signin → reset/email ("Forgot Password") → code ("Send verification code") → new ("Verify") → signin ("Save new password").
- floor: tile tap → confirm-vibe (dialog) → floor · "Take over" → takeover · paused-state ⇄ default · bottom-nav cross-links to schedule/venues/settings.
- takeover: start → active · active → extend (sheet) → active · active → confirm-return (dialog) → floor.
- schedule: self-drive ⇄ custom · custom → jump-week / add-daypart / edit-daypart (modals, all return to custom).
- venues: portfolio → venue (drill-in) · portfolio → add-venue → add-zone (sheet) · venue → zone-detail.
- settings home → volume / transitions / who-can-take-over / zone-detail / open-hours / offline-alert / takeover-alert / appearance. open-hours → everyday-hours & add-exception; both → set-time. **who-can-take-over gates the floor role's takeover access.**
- Back/cancel: every sheet/dialog → Cancel or scrim-tap dismisses to parent, no state change. Sub-screens use the top-bar back chevron. System back (portrait swipe) = same as back chevron.

Transitions: none designed — use instant or ≤200ms fade/slide-up for sheets (flag: §6-B6). The eq-bars animation is the only designed motion (plus 0.8s alternate loop).

---

# 5. Suggested Flutter structure

```
lib/
  main.dart                      // MaterialApp.router, theme mode state
  app/
    router.dart                  // go_router + role redirect guards
    roles.dart                   // enum Role {floor, manager, owner}
  theme/
    palette.dart                 // PrismPalette (dark+light) — §1.1/1.2 tokens
    moods.dart                   // Mood model + 6-mood table §1.3
    typography.dart              // TextStyles §1.4 (google_fonts)
    dimens.dart                  // spacing/radii §1.5–1.6
  data/
    models/ (venue.dart zone.dart mood.dart schedule_entry.dart user.dart
             takeover_state.dart guardrails.dart)
    repositories/                // abstract: AuthRepo, VenueRepo, ScheduleRepo,
                                 // PlaybackRepo (streams now-playing/noise), SettingsRepo
    mock/                        // in-memory impls, seeded with Marina Café data
                                 // (values exactly as in the frames)
  shared/widgets/                // §3 components, one file each
  features/
    auth/      (sign_in_screen.dart reset_email_screen.dart reset_code_screen.dart
                reset_password_screen.dart)
    floor/     (floor_screen.dart widgets/hero_card.dart mood_grid.dart
                schedule_rail.dart confirm_vibe_dialog.dart)
    takeover/  (takeover_screen.dart active_takeover_screen.dart
                extend_sheet.dart confirm_return_dialog.dart)
    schedule/  (schedule_screen.dart week_picker.dart daypart_sheet.dart)
    venues/    (portfolio_screen.dart venue_screen.dart add_venue_screen.dart
                add_zone_sheet.dart)
    settings/  (settings_screen.dart volume_policy_screen.dart transitions_screen.dart
                open_hours_screen.dart exception_sheet.dart everyday_hours_sheet.dart
                time_dial_sheet.dart zone_detail_screen.dart)
```
State: Riverpod (`themeModeProvider`, `sessionProvider(role)`, `nowPlayingProvider` (Stream, mock ticks), `takeoverCountdownProvider`, per-feature notifiers). No network. Fonts via `google_fonts: Newsreader + Hanken Grotesk`.

---

# 6. Assumptions & open questions

**A. Assumptions made (safe derivations — flag if wrong)**
1. **Portrait** is not drawn. Assumption: keep the same structure; on Floor, the schedule rail moves below the mood grid as a horizontal strip (or collapses behind a "Today" chip). All other screens are single-column and reflow naturally.
2. Pressed states: 92% scale or +6% darken on filled buttons; `tile2` flash on rows. Not designed.
3. Disabled: 40% opacity. Not designed.
4. The 860×602 frame = 1:1 dp at ~iPad 11" landscape minus safe areas.
5. Locked nav taps are inert (no toast/dialog designed).
6. Noise meter is display-only (thumb is decorative).
7. Countdown format `m:ss`; extend adds the chosen duration.

**B. Open questions (NOT designed — do not invent silently)**
1. Loading, empty, and error states — none exist in the frames (e.g. failed sign-in, wrong OTP, offline app state, empty schedule).
2. Exact iPad models/breakpoints to support; min window width for the rail.
3. Time-dial minute granularity (frames show whole hours + :00 quick chips only).
4. "Just change the vibe" card on S02-1 — same confirm flow as Floor, or inline picker?
5. Owner portfolio sort options beyond "Needs attention".
6. Screen-transition motion (none designed; eq-bars is the only designed animation).
7. Account menu contents beyond Sign out (profile? venue switcher for owners?).
8. System theme option (S05-9 lists Dark/Light/System; toggle in the bar shows only Dark/Light).
9. Password rules beyond "at least 8 characters".
10. What "Full band" grants floor staff on the volume seg — full slider UI or just wider nudge?
11. Zone "player" pairing flow (player field was removed from Add-a-zone; zone-detail still references a player).
12. Copy for offline/alert notification surfaces (alerts route to WhatsApp per the stack doc — out of front-end scope?).

**C. Out of scope (per stack doc)**: audio engine, FastAPI/Supabase/EMQX wiring, fleet/console. Keep repository interfaces async + stream-based so the real backend slots in.
