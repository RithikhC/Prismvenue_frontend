# Prism Venues — frontend

Flutter app for Prism's venue staff: see what the room is playing, take the
speakers over for a moment, plan the week's vibes, triage zones across an
estate, and set the guardrails Prism operates inside.

Built for **iPad landscape** (portrait reflows), dark theme by default.

## Status

Feature-complete against the design handoff and running on in-memory mock
data. `flutter analyze` is clean and the 32 widget tests pass.

| | |
|---|---|
| Screens | All six sections — auth, floor, takeover, schedule, venues, settings |
| State | Riverpod; five stream-based repository interfaces behind mock implementations |
| Backend | Not wired — see the integration guide below |

## Start here

- **[BACKEND_INTEGRATION.md](BACKEND_INTEGRATION.md)** — how to replace the
  mocks with a real API. Start here if that's your job.
- **[open_questions.md](open_questions.md)** — 27 places the build had to
  derive something the design didn't pin down. For the designer, but several
  affect backend work.
- **[design_handoff/](design_handoff/)** — the spec this was built against
  (`README.md`) plus the interactive frame documents. Section IDs like
  `S05-4` throughout the code refer to it.

## Running

```bash
flutter pub get
flutter run
```

Sign in with any password; the mock derives the role from the email —
`floor@…` → floor staff, `owner@…` → owner, anything else → manager. The
role changes what you can reach, so try all three.

`/_gallery` is a hidden route rendering every shared component in both
themes, for checking design fidelity.

```bash
flutter test        # 32 widget tests
flutter analyze
```

## Layout

```
lib/
  app/          router (+ role gating), session, shell
  theme/        palette, moods, typography, dimens
  data/
    models/         plain data classes
    repositories/   abstract interfaces  ← the backend seam
    mock/           in-memory implementations, seeded with Marina Café
  shared/widgets/   design-system components
  features/         one folder per section
test/           widget tests, one file per section
```
