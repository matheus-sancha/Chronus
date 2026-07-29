# Chronus

Cronoanálise (time-study) app for manufacturing engineers and technicians — for
on-the-floor process analysis and comparison.

An analyst stands at a machine, times a sequence of operations, classifies them
as setup / value-added / waste, and produces reports and exports for
record-keeping. Timing is **per-operation and concurrent**: each operation is an
independent, pausable timer, so two operators on one assembly (or man + machine)
can be captured at once.

Local-first: no accounts, no cloud sync, no server.

## Status

**Phases 1–8 of 9 complete** (Foundations, Structure, Core, Analysis, Export,
Windows operation, Sampling Study, cross-study comparison).

Phase 6 (Licensing) is **skipped** — Windows is internal-only, so there is
nothing to gate. Windows operation ([`docs/DESIGN.md`](docs/DESIGN.md) §10) was
inserted in its place: build identity, a diagnostics log, an in-app feedback
channel, recovery for runs left timing, automatic database snapshots, remembered
window geometry, and keyboard timing. Sampling studies run in passes, with
statistics, sample-size adequacy and their own exports; studies can be compared
against each other ([`docs/DESIGN.md`](docs/DESIGN.md) §11).

**Phase 9 (Polish) is next** — video attachments, iPad layouts, and finalizing
pt/en/es. Also unbuilt: the optional backup folder in
[`docs/DESIGN.md`](docs/DESIGN.md) §10.8.

Distributed internally as a Windows zip. The first public App Store release is
deliberately gated on the full v1 — see [`docs/DESIGN.md`](docs/DESIGN.md) §8.3.

## Platforms

| Platform | State |
|---|---|
| Windows | Built and distributed to users today |
| iOS | Project scaffolded; needs an Apple Developer account to ship |
| Android / macOS / web | Out of scope by design |

Web is not merely unbuilt: the data layer uses `dart:io` and native SQLite in
ten files, so it would be a port, not a build flag.

## Getting started

```bash
flutter pub get
flutter run -d windows
```

Requires the Flutter SDK matching `environment.sdk` in `pubspec.yaml`
(Dart ^3.12.2; developed against Flutter 3.44.6).

## Common tasks

```bash
flutter analyze
flutter test                                  # 240 tests

dart run build_runner build --delete-conflicting-outputs   # Drift + Riverpod
flutter gen-l10n                                           # ARB -> AppLocalizations
```

Generated output (`*.g.dart` and `lib/src/l10n/generated/`) **is committed on
purpose**, so CI needs no code-generation step.

## Packaging a release

```powershell
.\tool\package_windows.ps1
```

Builds, stages, and zips a folder employees can unzip and run — no installer, no
store, no code signing. It bundles the three Visual C++ runtime DLLs, which
Flutter links dynamically and which are *not* part of the build output, so
without them the app fails to start on a PC that has never had Visual Studio
installed.

iOS builds go through [`codemagic.yaml`](codemagic.yaml) on a macOS runner,
since this project is developed on Windows. Three placeholders in that file
need filling once an Apple Developer account exists.

## Where data lives

| | |
|---|---|
| Windows | `%APPDATA%\com.matheussancha\chronus` |
| iOS | App documents directory (so iCloud backs it up) |

Windows deliberately avoids the documents directory: OneDrive's Known Folder
Move redirects it into a sync root, and a sync client uploading a live SQLite
file and its `-wal` sidecar mid-write can corrupt the database. See
[`lib/src/data/app_directory.dart`](lib/src/data/app_directory.dart).

Two safety nets, aimed at two different failures
([`docs/DESIGN.md`](docs/DESIGN.md) §10.5). Settings → Back up writes a
`.chronus` bundle (zipped database + media) that restores on any machine — that
one covers losing the PC, and the user has to ask for it. Separately, a silent
database snapshot is taken once a day at launch and three are kept; those cover
our own bugs and never leave the machine. Both restore from Settings → Data.

## Documentation

| Document | What |
|---|---|
| [`docs/DESIGN.md`](docs/DESIGN.md) | Design spec — every decision with its rationale and the alternatives rejected |
| [`docs/MANUAL-pt.md`](docs/MANUAL-pt.md) · [`-en`](docs/MANUAL-en.md) | User manual, illustrated |
| `docs/MANUAL-*.html` | Self-contained manuals that ship in the zip |

Read [`docs/DESIGN.md`](docs/DESIGN.md) before changing behaviour. It records why
things are the way they are, so changes get made with eyes open.

## Layout

```
lib/src/
  app/         routing, theme, shell
  common/      shared widgets and formatting
  data/        Drift database, schema, storage paths
  features/    projects · catalog · templates · studies · analysis
               export · media · backup · diagnostics · settings
               (each: data/ -> application/ -> presentation/)
  l10n/        ARB files (pt-BR, en, es) + generated localizations
```

## Dev tools

Not named `*_test.dart`, so a normal `flutter test` skips them — they assert
nothing, they render.

```bash
flutter test test/sample_export.dart    # PDF/XLSX over a realistic study
flutter test test/sample_gantt.dart     # timeline Gantt to PNGs
flutter test test/manual_screens.dart   # manual screenshots from real widgets
dart run tool/build_manual_html.dart    # manuals -> self-contained HTML
dart run tool/generate_alert_sounds.dart # regenerate assets/sounds/*.wav
```

The alert sounds are committed, so the generator runs only when they need
changing — it exists so they stay reproducible and licence-free rather than
being mystery binaries.

`test/live_backup_check.dart` round-trips a **copy** of a real app directory
through a `.chronus` bundle; see the header for usage.

## Localization

pt-BR, English and Spanish from day one — no hard-coded strings. Locale drives
number and date formatting (decimal comma vs. point). Add strings to all three
ARB files under `lib/src/l10n/`, then run `flutter gen-l10n`.
