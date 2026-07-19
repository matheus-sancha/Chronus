# Chronus — Stopwatch Spike

A **throwaway prototype**, not the product. Its only job is to validate the
single riskiest assumption in the project:

> Does the live time-study stopwatch feel right in a technician's hand —
> one-handed, rapid taps, phone backgrounding — on a real, noisy floor?

See [`../../docs/DESIGN.md`](../../docs/DESIGN.md) §8.1 for why this comes
before any other build work.

## What it does

- **Preset sequence** of operations (hard-coded stand-in for catalog/template).
- **Continuous, absolute-timestamp timing** — the end of one operation is the
  exact start of the next (no gaps, no tick-drift, survives lock/backgrounding).
- **One big lap-advance button**: end current op, start the next.
- **Insert an unplanned waste** mid-run (7 wastes) without disturbing the
  remaining preset sequence.
- **Live elapsed** + a raw results list, times in the dynamic `HH:MM:SS.D`
  format from the design spec.
- A **summary** with Setup / Value-added / Waste totals and value-added ratio.

What it deliberately omits: projects, catalog, templates, persistence,
rating/allowances, sampling, reports, export, licensing. All of that comes
later, in the real app.

## Only `lib/` + pubspec are committed

To keep the repo clean, the generated platform folders and build artifacts are
git-ignored. After cloning you must regenerate them:

```sh
cd prototype/stopwatch_spike
flutter create .          # backfills android/ ios/ windows/ web/ etc.
flutter pub get
```

## Getting it onto a real device

> **Reality check:** you're developing on **Windows**. You **cannot** build a
> native iOS app for an iPhone without a **Mac + Xcode** — that's an Apple
> constraint. It does not block the spike's purpose (tap-feel), but it shapes
> how you get it onto the phone. Pick the path that fits:

**Option A — Web on the actual iPhone (fastest, no Mac needed).**
Good enough to test tap feel and button ergonomics in Safari.
```sh
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```
Then, on the iPhone (same Wi-Fi), open `http://<YOUR-PC-LAN-IP>:8080` in
Safari and **Add to Home Screen** for a fullscreen, chrome-free feel.
_Caveat:_ web backgrounding/timing differs from native — fine for ergonomics,
not for validating lock-screen/background behavior.

**Option B — Android phone as a tactile proxy.**
Flutter on Windows builds for Android directly. The product is iOS, but the
*tap ergonomics* you're testing are largely device-agnostic.
```sh
flutter run          # with an Android device connected + USB debugging on
```

**Option C — True native iOS build.**
Requires macOS + Xcode: a physical Mac, or a cloud build (e.g. Codemagic CI,
MacinCloud). Use this once you want to test real native lock/background
behavior on the iPhone.

**Windows desktop (sanity check only, not a floor test):**
```sh
flutter run -d windows
```

## What to watch for on the floor

- Can you lap **without looking** at the screen?
- Is the button big enough **with gloves / dirty hands**?
- Does inserting an unplanned waste feel **fast** mid-cycle, or fumbly?
- Is the giant elapsed readout **helpful or distracting**?
- Does timing hold up when the **screen locks** or a **call comes in**
  (native builds only)?

Write down what breaks the flow — that feedback is the whole point, and it
should reshape the design *before* the real build begins.
