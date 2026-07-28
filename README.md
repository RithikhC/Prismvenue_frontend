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
| State | Riverpod; five stream-based repository interfaces |
| Backend | **Wired.** All five repositories run against the API in `../prismvenue-backend`. Mocks are still in the tree and still back the test suite. |

## Start here

- **[RUNNING.md](RUNNING.md)** — run backend + frontend together locally, plus
  a verification checklist. Start here.
- **[INTEGRATION_PLAN.md](INTEGRATION_PLAN.md)** — what was mapped, what
  mismatched, and every decision taken to resolve it.
- **[BACKEND_INTEGRATION.md](BACKEND_INTEGRATION.md)** — the original guide to
  replacing the mocks. Still accurate about the architecture; its "Known gaps"
  section is now largely addressed.
- **[open_questions.md](open_questions.md)** — 27 places the build had to
  derive something the design didn't pin down. For the designer, but several
  affect backend work.
- **[design_handoff/](design_handoff/)** — the spec this was built against
  (`README.md`) plus the interactive frame documents. Section IDs like
  `S05-4` throughout the code refer to it.

## Running

Against the real backend — see [RUNNING.md](RUNNING.md) for the full setup:

```bash
flutter run -d chrome --web-port=8080 --dart-define=PRISM_API_BASE_URL=http://localhost:8000/v1
```

On mocks, with no backend at all:

```bash
flutter run -d chrome --dart-define=PRISM_USE_MOCKS=true
```

On mocks, sign in with any password; the role comes from the email —
`floor@…` → floor staff, `owner@…` → owner, anything else → manager. The
role changes what you can reach, so try all three.

`/_gallery` is a hidden route rendering every shared component in both
themes, for checking design fidelity.

```bash
flutter test        # 77 tests — 32 widget + 45 API/transport
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
    api/            HTTP client, token storage, the five API implementations
    mock/           in-memory implementations, seeded with Marina Café
  shared/widgets/   design-system components
  features/         one folder per section
test/           widget tests, one file per section
```
