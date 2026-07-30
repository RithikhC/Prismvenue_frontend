# Building Prism Venues with sound, on a Mac

You have been handed this because the app needs to run on an iPad and that can
only be built on a Mac. This document assumes you know nothing about the
project. It should take about an hour, most of it waiting for downloads.

**What you are building:** an iPad dashboard for venue staff that plays adaptive
background music. Tapping a mood — "Peak", "Evening Warmth" — must change what
the speakers play. The music comes from a C++ engine (`prism-core`) embedded in
the app and reached through Dart FFI.

**Why it cannot be built on Windows:** iOS builds require Xcode, which is
macOS-only. There is no workaround.

Work through the parts in order. Each one ends in something you can verify, so
if it breaks you know exactly which step to look at.

---

## Part 0 — What you need

| | |
|---|---|
| macOS | Apple Silicon or Intel, both fine |
| Xcode | From the App Store, then open it once to accept the licence |
| Homebrew | https://brew.sh |
| Flutter | `brew install --cask flutter`, or https://docs.flutter.dev/get-started/install/macos |
| CMake + Ninja | `brew install cmake ninja` |
| Disk | ~15 GB free (Xcode is most of it) |

For Part 3 (the actual iPad) you also need a free Apple ID, and the iPad and Mac
on the same network or a USB cable.

Check Flutter is healthy before going further:

```bash
flutter doctor
```

`Xcode` and `Chrome` must be ticked. Ignore Android complaints.

---

## Part 1 — Clone the two repositories

They are separate repos and **must sit side by side**. The app's `pubspec.yaml`
refers to the engine as `../prism-core/...`, so the folder names and their
relative position matter.

```bash
mkdir -p ~/prism && cd ~/prism
git clone https://github.com/aaqibnp971/prism-core.git
git clone <the prism-venues-frontend repo URL> Prismvenue_frontend
```

Result:

```
~/prism/
├── prism-core/             ← the C++ sound engine
└── Prismvenue_frontend/    ← the Flutter app
```

The engine work lives on a branch, not `main`:

```bash
cd ~/prism/prism-core
git checkout venues/win32-build
```

> **Note the remotes.** `origin` points at `RidhwanAhamed/prism-core`, the
> upstream project. `aaqib` is the fork this work belongs in. **Never push to
> `origin`.** If you commit anything, push it to `aaqib`.

---

## Part 2 — Build the engine and prove it works

Three steps, each verifiable. Do not skip to the app — if the engine is broken,
the app will just be silent and you will not know why.

### 2a. Compile it

```bash
cd ~/prism/prism-core
cmake --preset release
cmake --build --preset release
```

Expect a few minutes. It downloads GoogleTest on the first run.

**Verify:**

```bash
ctest --preset release
```

One failure is expected and fine: `PgaeRtSafety.TenMinuteRenderRunAllocatesNothing`
was written against a Windows timing quirk. Everything else must pass. If more
than that fails, stop and report it — do not continue.

### 2b. Hear it

```bash
cd ~/prism/prism-core
./build/release/harness/prism_harness \
  --scene ~/prism/Prismvenue_frontend/assets/audio/mood_peak.json \
  --mood peak --seconds 40
```

**You should hear music from your Mac's speakers.** Try `--mood wind-down` too;
it should be noticeably sparser and darker. The six valid values are
`morning-calm daytime-flow afternoon-lift evening-warmth peak wind-down`.

It is quiet by design — the engine renders with a lot of headroom and expects the
host to set playback level. Turn your volume up rather than assuming it is broken.

If you hear nothing here, nothing later will work. Stop and report it.

### 2c. Build the loadable library

The harness links the engine statically. The app loads it at runtime, so it needs
a shared library:

```bash
cd ~/prism/prism-core
cmake -S . -B build/shared -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DPRISM_BUILD_SHARED=ON -DPRISM_BUILD_TESTS=OFF
cmake --build build/shared --target prism_core_shared
```

**Verify** — this proves Dart can drive the engine, before Flutter is involved:

```bash
cd ~/prism/prism-core/bindings/dart/prism_core_bindings
dart pub get
PRISM_CORE_LIB=~/prism/prism-core/build/shared/core/libprism_core.dylib \
PRISM_SCENES=~/prism/Prismvenue_frontend/assets/audio/mood_peak.json \
dart test
```

Both tests must pass. The second one pins a mood, renders it, and asserts the
audio actually changed.

---

## Part 3 — Run the app on your Mac first

Do this before the iPad. macOS desktop uses the same code path as iOS but is far
easier to debug, and it tells you whether the problem is the integration or the
iOS packaging.

```bash
cd ~/prism/Prismvenue_frontend
flutter pub get
```

The app needs a backend. Ask for a `.env` / API URL, or run the backend locally
(see `RUNNING.md`). Substitute the URL below.

The bindings honour a `PRISM_CORE_LIB` environment variable, which saves
embedding the library just to try it:

```bash
PRISM_CORE_LIB=~/prism/prism-core/build/shared/core/libprism_core.dylib \
flutter run -d macos --dart-define=PRISM_API_BASE_URL=http://localhost:8000/v1
```

**Verify:** sign in, go to the Floor screen, tap a mood. **You should hear the
room change.** Tap "Start takeover" — the audio should stop, so staff could use
their own source. End the takeover and it should come back.

> **Expect a short silence when the mood changes.** That is a known limitation,
> not a bug — see "Known limitations" below.

---

## Part 4 — The iPad

Only attempt this once Part 3 works.

### 4a. Build the engine as an iOS framework

```bash
cd ~/prism/prism-core
cmake -S . -B build/ios -G Xcode \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 \
  -DPRISM_BUILD_SHARED=ON -DPRISM_BUILD_TESTS=OFF
cmake --build build/ios --config Release -- -sdk iphoneos
```

This produces `prism_core.framework`. The CMake already sets the framework
properties iOS needs (`FRAMEWORK TRUE`, bundle identifier, versions) — see
`core/CMakeLists.txt`.

### 4b. Embed it in the app

```bash
cd ~/prism/Prismvenue_frontend
open ios/Runner.xcworkspace
```

In Xcode:

1. Select the **Runner** target → **General**
2. Under **Frameworks, Libraries, and Embedded Content**, click **+** → **Add Other…** → **Add Files…**
3. Choose the `prism_core.framework` built above
4. Set it to **Embed & Sign** — this is the step people miss, and without it the
   app launches and then crashes when it tries to load the library
5. Under **Signing & Capabilities**, pick your Apple ID team and set a unique
   bundle identifier (e.g. `com.yourname.prismvenues`)

The app resolves the framework by rpath, which is what "Embed & Sign" sets up.
No code change is needed.

### 4c. Run it

Connect the iPad, trust the Mac, then:

```bash
flutter devices          # confirm the iPad shows up
flutter run -d <ipad-id> --dart-define=PRISM_API_BASE_URL=<the API URL>
```

On the iPad, the first launch will refuse to open an untrusted developer app —
**Settings → General → VPN & Device Management → trust your certificate**, then
launch again.

**Verify:** same as Part 3 — tap a mood, hear it change; start a takeover, hear
it stop.

---

## How the integration works

Four files in `lib/engine/`, and one line in `main.dart`:

```
prism_engine.dart          the interface the app uses (start/setMood/silence/resume)
prism_engine_native.dart   real implementation — dart:ffi, chosen where it exists
prism_engine_stub.dart     no-op — chosen on web, which has no dart:ffi
engine_controller.dart     watches app state and drives the engine
```

Two decisions worth knowing, because they will look odd otherwise:

**The engine follows state; it is not called from the button.** The mood tile's
`onTap` does not touch the engine. `engine_controller.dart` listens to
`nowPlayingProvider` and `takeoverStateProvider`. A tap is not the only thing
that changes the mood — the weekly schedule does, another manager on another
iPad does — and the backend is the source of truth. Following the stream means
every one of those reaches the audio for free, and the speakers can never
disagree with what the dashboard shows.

**Web compiles to a no-op on purpose.** Flutter web has no `dart:ffi`, so
importing the bindings unconditionally would break the web build at *compile*
time. The conditional import in `prism_engine.dart` gives web a silent stub. The
app is developed and demoed in Chrome, where audio cannot exist, and ships to an
iPad, where it can — both build from one source tree. **In Chrome it is silent
and that is correct behaviour, not a bug.**

Stems ship as assets and are copied to the app-support directory on first launch,
because the engine takes a filesystem path and Flutter assets are not files on
device. `assets/audio/index.txt` doubles as the version marker: change the stems
and it re-extracts instead of playing stale audio.

---

## Known limitations

**Mood changes have a short gap.** Each mood is its own scene with its own stems,
and `prism_load_scene` is rejected after `prism_start` — scenes load once, with
all decoding up front, so the render path never touches disk. A mood change is
therefore stop → load → start, costing a brief silence while the new stems decode.

The engine's spec describes scene changes as equal-power crossfades scheduled at
loop boundaries — that is what the app's Seamless / Gentle / Lively setting is
meant to control. It needs the engine to hold more than one scene at once, which
it currently cannot (`Pgae` owns exactly one `SceneAssets`, and `mode_hint` does
not select scenes yet). **Until that lands, the Seamless setting is not honoured.**

The obvious alternative — one shared scene for all six moods, switched by pinning
the PSV — is seamless but much weaker: measured on a single scene, the loudest and
quietest moods land within ~2.6 dB, because most of what separates the six comes
from their different stem sets. The requirement is that the six must not sound
alike, so the brief gap is the better trade for now.

**Self-drive does nothing yet.** The engine's context layer only understands
study signals (app switches, idle time, task deadlines) — there is no venue
profile that reads a room. The app's "Prism is picking the vibe" copy currently
overpromises.

**The audio is dark.** The source stems carry 0.00–0.14% of their energy above
4 kHz, including the one in the "air" role. No engine setting can brighten what
was never recorded; it needs different source material.

---

## If it does not work

| Symptom | Cause |
|---|---|
| Silent in Chrome | Correct. Web cannot load native libraries. Use macOS or iPad. |
| Silent on macOS/iPad | Check `PRISM_CORE_LIB` (Part 3) or Embed & Sign (Part 4b). |
| Crash on launch, iPad | Framework not embedded — Part 4b step 4. |
| `flutter pub get` fails on `prism_core_bindings` | The two repos are not side by side. See Part 1. |
| Harness silent | Turn the volume up; it renders with deliberate headroom. |
| `ctest` fails on `PgaeRtSafety` only | Expected. See Part 2a. |
| App works, no data | Backend problem, not audio. See `RUNNING.md`. |

## Questions worth asking back

1. Does a **Stem Production Specification** exist anywhere? The engine's docs
   defer to it for stem roles, keys and loop lengths; without it those were
   improvised.
2. Is the provisional patent filed? Both prism-core repos are currently public,
   and `START-HERE.md` says nothing should be public until it is.
3. Is a **venues profile** planned for the context engine? Without one,
   self-drive cannot work.
