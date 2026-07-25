# Backend integration guide

This Flutter app is feature-complete against the design spec and runs today
on in-memory mock data. **Nothing in the UI needs to change to put it on a
real backend.** Every screen reads and writes through five abstract
repository interfaces; the mocks that implement them are swapped for your
implementations at one place in `main.dart`.

This guide is what you need to do that swap, in the order it makes sense to
do it.

---

## 1. How the app is wired

```
Screens (lib/features/…)
        ↓ read/watch
Riverpod providers (declared next to each interface)
        ↓ call
Repository interfaces (lib/data/repositories/*.dart)   ← the contract
        ↓ implemented by
Mock repos (lib/data/mock/*.dart)                      ← replace these
```

Five interfaces, each in `lib/data/repositories/`:

| Interface | Owns | Live streams? |
|---|---|---|
| `AuthRepo` | sign-in, password reset | no |
| `PlaybackRepo` | now-playing, noise, takeover | yes — 3 streams |
| `ScheduleRepo` | today's rail, weekly plan, self-drive⇄custom | yes — 3 streams |
| `VenueRepo` | venues, zones, quick-fix | yes — 2 streams |
| `SettingsRepo` | guardrails, open hours | yes — 2 streams |

Read the interface files first — they are short and every method carries a
doc comment naming the screen it serves (e.g. "S02-4: extend ADDS the chosen
duration"). Cross-reference `design_handoff/README.md` for those IDs.

---

## 2. The swap

Each interface ships with a provider that constructs the mock:

```dart
// lib/data/repositories/venue_repo.dart
final venueRepoProvider = Provider<VenueRepo>((ref) {
  final repo = MockVenueRepo();
  ref.onDispose(repo.dispose);
  return repo;
});
```

Write `ApiVenueRepo implements VenueRepo`, then override the provider at the
app root. Nothing else changes:

```dart
// lib/main.dart
void main() {
  runApp(ProviderScope(
    overrides: [
      authRepoProvider.overrideWithValue(ApiAuthRepo(client)),
      venueRepoProvider.overrideWith((ref) {
        final repo = ApiVenueRepo(client);
        ref.onDispose(repo.dispose);
        return repo;
      }),
      // …one per interface
    ],
    child: const PrismVenuesApp(),
  ));
}
```

You can migrate **one interface at a time** — override `VenueRepo` against
your API while the other four stay on mocks. That is the recommended path.

---

## 3. Contracts you must honour

These are not stylistic preferences; the UI breaks if they are violated.

**Every `watch*()` stream must emit its current value immediately on
subscribe, then emit again on every change.** The screens render from the
latest stream value, so a stream that only pushes future deltas leaves the UI
on fallback values forever. The mocks show the pattern:

```dart
Stream<Guardrails> watchGuardrails() async* {
  yield _guardrails;            // current value, immediately
  yield* _controller.stream;    // then every change
}
```

**Streams must tolerate multiple and repeated subscriptions.** The providers
are `autoDispose`, so navigating away and back resubscribes. Use broadcast
streams (or a per-listener replay), never a single-subscription stream.

**Mutations are fire-and-forget from the UI's perspective.** `setMood()`,
`addDaypart()`, `returnZoneToAuto()` etc. return `Future<void>`; the UI does
*not* apply the change locally. The new state must come back through the
corresponding `watch*()` stream or the screen will not update. Round-tripping
through your realtime channel is fine and preferred.

**Mood IDs are a fixed set of exactly six strings.** They key into the
client-side table in `lib/theme/moods.dart` (name, colour, energy). An
unknown ID from the server will not render. The six:

```
morning-calm   daytime-flow   afternoon-lift   evening-warmth   peak   wind-down
```

**`Role` drives all navigation and gating.** `User.role` is
`floor | manager | owner` and the router redirects on it (floor staff cannot
reach Schedule/Venues/Settings; owner lands on the portfolio). Whatever your
auth returns must map cleanly onto those three.

---

## 4. Interface-by-interface

### AuthRepo — `lib/data/repositories/auth_repo.dart`

```dart
Future<User> signIn(String email, String password);
Future<void> sendResetCode(String email);
Future<void> verifyResetCode(String email, String code);
Future<void> saveNewPassword(String email, String password);
```

`signIn` returns the `User` (id, name, role, initials, avatarColor); the
sign-in screen then puts it in `sessionProvider`. The mock accepts any
credentials and picks a role from the email string.

> **Gap to close: there is no token handling anywhere in the app.** No token
> storage, no auth header, no refresh, and `sessionProvider` is in-memory so
> a restart signs the user out. You will need to add token persistence
> (`flutter_secure_storage` or similar) and rehydrate the session on launch.
> This is the one area where you will touch app code outside the repos —
> `lib/app/session.dart` is the file.

> Failed sign-in and wrong-OTP have **no designed UI** (§6-B1). Today these
> methods never throw. Decide with the designer what a thrown error should
> render before you make them throw.

### PlaybackRepo — `lib/data/repositories/playback_repo.dart`

```dart
Stream<PlaybackState> watchNowPlaying();   // mood, paused, pausedBy, contextLine
Stream<int> watchNoise();                  // 0–100
Future<void> setMood(String moodId);
Future<void> pause({required String by});  // `by` = first name, shown in the pill
Future<void> resume();

Stream<TakeoverState> watchTakeover();     // active, startedAt, remaining
Future<void> startTakeover({required Duration handBackAfter});
Future<void> extendTakeover(Duration by);  // ADDS to remaining, not replaces
Future<void> endTakeover();
```

This is your MQTT/realtime surface. Two notes:

- **The takeover countdown ticks every second** — `takeoverCountdownProvider`
  reads `TakeoverState.remaining` and the UI renders `m:ss`. Do **not** push a
  message per second from the server. Send `startedAt` + an end time once, and
  have your `ApiPlaybackRepo` tick locally between server events. When
  `remaining` hits zero the app calls `endTakeover()` itself, so the server
  should treat auto-return as idempotent.
- `PlaybackState.contextLine` is a **pre-formatted display string** ("mid-afternoon ·
  ~60% full · clear") rendered verbatim. Either generate it server-side or
  agree on structured fields and change the one widget that shows it.

### ScheduleRepo — `lib/data/repositories/schedule_repo.dart`

```dart
Stream<TodaySchedule> watchToday();        // entries + nowIndex + auto flag
Stream<ScheduleMode> watchMode();          // selfDrive | custom
Future<void> setMode(ScheduleMode mode);
Stream<List<Daypart>> watchWeekPlan();     // all 7 days, flat list
Future<void> addDaypart(Daypart daypart);  // server assigns the real id
Future<void> updateDaypart(Daypart daypart);
Future<void> deleteDaypart(String id);
```

`TodaySchedule.nowIndex` marks the highlighted "NOW" row on the Floor rail —
server-computed is simplest since it depends on real time and the venue's
timezone. `Daypart.dayIndex` is `0 = Monday … 6 = Sunday`.

### VenueRepo — `lib/data/repositories/venue_repo.dart`

```dart
Stream<List<Venue>> watchVenues();         // owner portfolio
Stream<Venue?> watchVenue(String id);      // null for unknown id
Future<void> returnZoneToAuto(String venueId, String zoneId);
Future<void> addVenue({required String name, required String address,
                       required List<String> zoneNames});
Future<void> removeZone(String zoneId);
```

`ZoneStatus` is `auto | offSchedule | offline` and drives the whole triage
treatment (quiet row / amber + quick-fix / red). The mock sorts the portfolio
"needs attention first" **client-side**; decide whether that ordering becomes
a server concern — if the server sorts, the client will render whatever order
it receives.

### SettingsRepo — `lib/data/repositories/settings_repo.dart`

```dart
Stream<Guardrails> watchGuardrails();
Future<void> updateGuardrails(Guardrails next);   // whole object
Stream<OpenHours> watchOpenHours();
Future<void> setEverydayHours({required int openHour, required int closeHour});
Future<void> addException(HoursException exception);
```

`updateGuardrails` sends the **entire** object for any single change — you may
want a PATCH-per-field API behind it to avoid lost updates between concurrent
managers.

> **Recommended change:** `Guardrails.offlineAlertIndex` and
> `takeoverAlertIndex` are *indices into client-side string arrays*
> (`['2 min','5 min','15 min','30 min']`). Storing an index means adding an
> option later silently reinterprets stored data. Persist the real value
> (e.g. minutes as an int) and map to the index in your repo implementation.

`Guardrails.takeoverAccess` is load-bearing: setting it to `managers` locks
floor staff out of takeover, enforced in the router redirect and the nav bar.

---

## 5. Display strings vs structured data

Several model fields are **pre-formatted strings the UI renders verbatim**,
because the frames specified text and not data. Agree early on whether the
server produces them or you restructure the (small number of) widgets:

| Field | Example | Where |
|---|---|---|
| `PlaybackState.contextLine` | `mid-afternoon · ~60% full · clear` | Floor hero |
| `ScheduleEntry.timeLabel` | `2:00` | Floor rail |
| `Daypart.rangeLabel` | `2 – 6 pm` | Schedule grid |
| `Zone.statusDetail` | `Off schedule · auto in 42 min` | Venue/portfolio rows |
| `Venue.hoursLabel` | `Every day · 7am–11pm` | Add-venue form |

Everything else (`openHour`/`closeHour` ints, `HoursException.days` as
`Set<int>` with 0=Mon, durations, percentages) is already structured.

---

## 6. Suggested order of work

1. **`SettingsRepo`** — smallest surface, no realtime, immediately visible in
   the Settings screens. Good shakedown of the swap mechanism.
2. **`VenueRepo`** — plain CRUD plus a status field; proves your stream setup
   on two screens.
3. **`AuthRepo` + token/session persistence** — the only piece that touches
   app code outside the repos.
4. **`ScheduleRepo`** — CRUD plus the server-computed `nowIndex`.
5. **`PlaybackRepo`** — last, because it is the realtime/MQTT one and the
   takeover clock needs the most care.

After each step: `flutter analyze && flutter test`. The suite is 32 widget
tests and passes green today, so a regression is unambiguous.

---

## 7. Running it

```bash
flutter pub get
flutter run          # -d chrome, or an iPad simulator — designed for iPad landscape
```

Sign in with any password. The mock picks the role from the email:
`floor@…` → floor staff · `owner@…` → owner · anything else → manager.
Visit `/_gallery` for a hidden screen rendering every shared component in
both themes side by side — useful for checking your changes didn't disturb
the design system.

Tests override repos exactly the way `main.dart` will:

```dart
ProviderContainer(overrides: [
  playbackRepoProvider.overrideWith((ref) => MockPlaybackRepo(tickNoise: false)),
]);
```

Keep the mocks in the tree — the test suite depends on them, and they double
as executable documentation of the expected data shapes.

---

## 8. Known gaps

- **No loading, empty, or error states exist** (§6-B1 — none were designed).
  Screens read `provider.value ?? <fallback>`, so a slow or failed request
  currently renders a fallback rather than a spinner or an error. This needs
  design input before the app faces real network latency; it is the single
  biggest thing standing between this build and production.
- **`open_questions.md` lists 27 flagged derivations.** Several affect you
  directly — how zone-detail edits persist (no save affordance is designed),
  the zone↔player pairing flow, and what "Full band" grants floor staff.
- **Out of scope per the handoff (§6-C):** audio engine, FastAPI/Supabase/EMQX
  wiring, fleet console. The repository interfaces are the agreed seam.
