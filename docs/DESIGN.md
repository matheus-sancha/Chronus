# Chronus — Design Specification

_Cronoanálise (time-study) application for manufacturing engineers and technicians, for on-the-floor process analysis and comparison._

**Status:** in implementation — Phases 1–5 built (Foundations, Structure, Core, Analysis, Export). Phase 6 (Licensing) is **skipped on Windows** (§6); Windows operation (§10) is **complete** bar §10.8. Phases 7 (Sampling) and 8 (Cross-study comparison) are **in implementation** — their decisions are §11.
**Last updated:** 2026-07-27

This document is the shared-understanding snapshot from the design review. Every decision below was deliberately chosen (alternatives considered and rejected); the "Rationale / alternatives" notes record why so future changes are made with eyes open.

---

## 1. Vision & scope

Chronus lets a manufacturing engineer or technician stand at a machine and, one-handed, time a sequence of operations, classify them by value-added vs. waste, compute standard times via the full cronoanálise chain, and produce credible reports and exports for analysis and record-keeping. Studies can be run once (Time Study) or repeated and aggregated statistically (Sampling Study), and compared against one another and against reference standards.

**Not in scope for v1:** work sampling (random-moment activity sampling), cloud sync, user accounts, audio/voice notes, cross-project comparison, user-defined custom metadata fields, report-layout customization, macOS, Android.

---

## 2. Platforms & technology

| Decision | Choice | Rationale / alternatives |
|---|---|---|
| Target platforms | **iOS first** (priority-one), **Windows** later. No Android, no macOS. | Core value is the on-floor stopwatch (touch, handheld). "PC" = Windows (shop-floor offices are Windows shops). |
| Form factor | **Responsive across phone → tablet → desktop**; one codebase, not a second app. | Live timing is a multi-operation table (concurrent timers, per-row controls, inline edit) — a **wide-layout-first** experience the analyst drives while observing a station on a tablet/laptop, reflowing to stacked cards on a phone. (Supersedes the earlier "one-handed iPhone stopwatch" premise — see §3.5.) |
| Tech stack | **Flutter** (single codebase) | Targets iOS now + Windows later with a production-grade desktop story. Chosen over native Swift (would require rewrites for Windows) and React Native (weaker Windows target). |
| Storage engine | **SQLite via Drift** | Domain is deeply relational; reporting/comparison need aggregation queries. Media stored as **files** in the app directory, referenced by id (never DB blobs). |
| Data safety | Device iCloud/iTunes backup **+ manual `.chronus` backup bundle** (zipped DB + media, re-importable). **No cloud sync in v1.** | Local-first with no accounts means device loss = data loss; the bundle is insurance and the iOS→Windows migration path. Cloud sync would require accounts/servers, deliberately avoided. |

**`.chronus` bundle notes (built ahead of the rest of Phase 6):**
- A ZIP of `manifest.json` + `chronus.sqlite` + `media/`. The manifest carries a **bundle format** version (layout) separately from the **schema** version (rows), because the two move at different rates.
- The database snapshot comes from **`VACUUM INTO`, never a file copy** — it is transactionally consistent without closing the live database, and folds in un-checkpointed WAL content that a raw copy would silently drop.
- **Restore is total, not a merge**, and is applied by copying the bundle's tables into the running database in one transaction (via `ATTACH`) rather than swapping the file under a live connection. No restart, no window where the open handle and the file on disk disagree.
- Validation happens **before** anything is touched, so a rejected bundle always leaves the app exactly as it was. A bundle from a newer schema is refused; an older one is migrated forward on import.
- Columns are copied **explicitly, never `SELECT *`** — a table rebuilt by a migration can have a different column order than a freshly created one, and positional copying would scramble values.

---

## 3. Domain model

### 3.1 Hierarchy

```
Project
 └─ Study (Time Study | Sampling Study)
     ├─ Operation instance (snapshot from Catalog)  ← Time Study: one pass
     └─ Observation (Sampling Study only: N passes)
          └─ Operation instance (per pass)

Catalog (reusable operation definitions)  ── referenced by hidden id from instances
Template (reusable ordered sequence + default settings)
```

### 3.2 Study types

- **Time Study** — one ordered pass through operations, timed live.
- **Sampling Study** — a container of **multiple observations**; each observation is one timed pass through the same operation set, **reusing the same per-operation timing engine** (§3.5). Aggregated across passes (mean, min, max, range, std dev, coefficient of variation, % deviation vs standard).
- **"Standard vs. actual" is a comparison _view_**, shown whenever operations carry standards — **not** a separate study type.

_Alternative rejected:_ three study modes (direct / standard-vs-actual / sampling). Collapsed to two because standard-vs-actual is a view, and sampling is "run the time study K times and roll it up."

### 3.3 Operation catalog & instances

- A reusable **Catalog** of operation definitions: name, classification, subtype, **optional** standard time.
- Adding a catalog operation to a study **snapshots** its fields into a per-study **instance**, while keeping a **hidden catalog-id link**.
- Snapshot (not live reference) preserves **historical integrity**: revising a standard later must not silently mutate past studies/reports. The hidden id still enables cross-study grouping.

### 3.4 Classification taxonomy

- **Fixed top categories** (reports roll up by these — not editable): **Setup**, **Productive (Value-Added)**, **Unproductive (Waste)**.
- **Built-in waste subtypes = the full 7 wastes:** Waiting, Motion, Transportation, Over-processing, Overproduction, Inventory, Defects.
- **User-addable custom subtypes** — always _within_ one of the fixed categories, so roll-up reporting still works.

### 3.5 Timing

- **Per-operation (snapback) timing.** Each operation is an **independent timer**, started/paused/stopped/reset on its own — _not_ a single continuous cursor. This matches real cronoanálise practice: the clock is not always running, and not every instant belongs to an operation. **Dead time is counted only when explicitly attributed** to an (unproductive) operation.
- **Absolute timestamps, multi-segment.** An operation's measured time is the **sum of one or more timed segments**, each an absolute start/end epoch-millisecond pair (stored in `OperationTimeSegments`). Pause closes a segment; resume opens a new one. Absolute timestamps survive backgrounding/lock, allow post-hoc boundary editing, and avoid tick-drift.
- **Concurrency.** Multiple operations may run **simultaneously** — two operators on one assembly, or man + machine (internal-vs-external time). Therefore **total study time = wall-clock span** (first start → last stop), **never the sum** of operation times (which would double-count overlap). Simultaneous time is a first-class reporting output (Phase 4).
- **Per-operation controls:** ▶ **start** (from zero) · ⏸ **pause** (preserves elapsed; offers to log the interruption as a new _unproductive_ operation) · ⏹ **stop** (complete) · ↺ **reset** (zero & discard, confirmed).
- **Manual override.** The actual time may be **manually entered**, non-destructively: a `manualActualMs` value **shadows** the measured segment-sum (segments retained; clearing the override restores the measured value). Supports transcribing a paper study where nothing was timed live.
- **The operation list _is_ the live workspace** — add / reorder / edit / duplicate / delete operations at any time during the study, including inserting an unplanned operation mid-study (see §8.2: the build-sequence and run steps are merged into one study screen).
- A **timed / not-timed** indicator per operation (plus an in-progress state) tracks study completeness at a glance.
- **Workspace header: three figures, not one.** **Total** (wall-clock span) · **Work content** (Σ operation times) · **Expected** (Σ reference standard). Total is shown but deliberately left **uncompared**: it is a span and Expected is a sum, so their difference is meaningless the moment work overlaps or the run has gaps. Work content exists precisely so the valid sum-vs-sum comparison is on screen and the invalid one is not implied. _Showing Expected beside Total alone was rejected_ — it is the smaller change, and it invites exactly the subtraction this section says is wrong.
- **Expected sums the whole sequence**, not only the operations timed so far, so it stays a **fixed target** during a run instead of growing as work proceeds. The cost is that an operation carrying no benchmark understates it silently, so the tile discloses coverage ("5 of 7 ops") whenever any operation lacks one. _This differs from the aggregate efficiency in §3.6 on purpose_ — that sums only operations having **both** a reference and an observed time, because it answers a different question (how efficient was the work actually measured) asked after the fact rather than during the run.
- _Continuous single-cursor "one big lap button" timing rejected_ — it forces every instant onto some operation and cannot represent concurrency, pauses/interruptions, or discretely re-measured elements. (This reverses the original v1 decision, which had instead rejected snapback; the domain reality is the opposite.)

### 3.6 Reference standard & efficiency

- Each operation may carry an optional **reference standard** — a pre-existing benchmark time stored in the catalog and snapshotted onto the study operation.
- **Efficiency = reference standard ÷ observed time** (≥ 100 % = met or beat the benchmark). Reported per operation and in aggregate (Σ reference ÷ Σ observed over operations that have both).
- _The performance-rating / allowance "standard-time chain" (rating → normal → computed standard) was scrapped_ — it added ceremony without matching how these studies are actually read. Observed-vs-reference and efficiency are the deliverable.

**Pace alerts** — the reference standard is also watched live, not only reported afterwards.

- An operation carrying a standard turns **amber** as it approaches and **red** once past it, and sounds two cues distinguished by **contour** (rising on approach, falling past) — contour survives a noisy floor and a cheap speaker, where two similar beeps would not. Operations **without** a standard are never coloured and never sound.
- **Warning window = `min(30 s, 10 % of the standard)`.** The 30 s is a **cap, not a floor**, and that is the entire point. _A floor was rejected_: any operation shorter than the constant would then warn at or before its own start, and element-level cronoanálise operations are routinely under 30 s. As a cap the window is always a tenth of the operation, so it can never precede the start, while a two-hour operation still gets a tight "ready to press stop" cue rather than a distant schedule warning. **Do not flip this to a floor** without re-reading this bullet.
- **Alerts are latched** — at most two sounds per operation — and the latch clears **only on reset**, the one control that actually zeroes the clock. Two consequences follow deliberately: resuming a finished overrun is **silent** (the crossing already happened), and the first evaluation after mount records state **without sounding**, so returning from the report or relaunching never replays a crossing that occurred off-screen. At most one sound per frame, "over" outranking "approaching", so the simultaneous crossings this app exists to capture produce one alert rather than a burst.
- **Colour is not latched** and is not mutable — it reflects observed-vs-reference for running *and* finished operations, so a missed or silenced cue still leaves a trace and a finished study can be scanned for overruns at a glance.
- **Sound via `audioplayers` + generated assets**, not `SystemSound.play`. _The platform sound was rejected_: it is one fixed tone that cannot tell the two events apart, the Windows "No Sounds" scheme silences it outright, and it is a documented no-op on iOS. The assets are generated by `tool/generate_alert_sounds.dart` rather than sourced, so they stay reproducible and licence-free.
- Muting is a persisted setting (`AppSettings.alertSoundsEnabled`, schema v4, default **on** so an existing database gains the feature rather than silently opting out).

### 3.7 Templates

- **First-class entity:** an ordered list of catalog-operation references + the default study type. **No measured data, ever.**
- Instantiating a template **snapshots** the sequence into a new study.
- **"Save as template from study"** strips measurements, keeps sequence + settings.
- No built-in starter templates in v1.

### 3.8 Notes & media

- **v1 media: photos + short video.** **Audio/voice notes deferred to v2.**
- Stored as **local files** referenced by id.
- Attach at **operation-instance / study / per-observation** levels.
- Exports **embed photos**; **video is flagged as in-app-only** (cannot embed in PDF/XLSX).

### 3.9 Study header metadata

- **Name** (required), **date/time** (auto, editable), **Analyst** (defaults from settings).
- Optional: **Part/Product, Process/Operation, Machine/Workstation, Line/Cell, Operator, Shift, Work Order Number**.
- **Process Type** — editable **seeded single-select picklist**; seed values: _Machining, Cladding, Welding, Assembly & Testing, Inspection, Bending_.
- Study-level free-form notes.
- Fixed field set for v1 (no user-defined custom fields).

---

## 4. Reporting

**In-app first** (interactive views); export is a separate artifact (§5).

**Time Study**
- Summary tiles: **elapsed** (wall-clock span), **work content** (Σ operation times — counts overlap twice), **simultaneous** (time with ≥2 operations running), **unattributed** (span covered by no operation), value-added ratio, **efficiency %**. They reconcile: `elapsed = covered + unattributed`.
  - _Simultaneous is swept from the segment intervals, **not** `work − elapsed`_ — that identity holds only when the run has no gaps, and goes negative once gaps exceed overlap.
- Operation breakdown table: observed / reference standard / **efficiency %** (+ note & photo indicators).
- Category roll-up: % Setup vs. Value-Added vs. Waste (by work content).
- **Timeline: a wall-clock Gantt** — one row per operation in **planned-sequence order** (so rows line up with the breakdown table), blocks at their true timestamps. Concurrency reads as vertically aligned bars, unattributed dead time as whitespace, pauses as gaps within a row.
  - Total block width always equals the operation's **reported** time, so chart and table can never disagree: an override longer than measured extends past the evidence, one shorter trims from the end, and an operation with no segments is laid out after the clock ends.
  - Anything **not backed by a measured segment is hatched**, so an overlap involving it reads as unverified rather than observed. Hatching is diagonal lines, not a lighter tint — a tint is indistinguishable from solid in greyscale print.
  - A study with **no live timing at all keeps a relative axis** (`0:00…`) rather than inventing clock readings.
  - _Rejected: order × duration._ Laying operations end-to-end by duration made the strip's width sum to work content under an axis labelled elapsed, and hid concurrency, gaps and pauses entirely.
- Waste Pareto: time by waste subtype, ranked.

**Sampling Study**
- Per-operation statistics across observations: mean, min, max, range, std dev, coefficient of variation.
- **Sample-size adequacy** — given observed variability and chosen confidence/precision, how many observations are needed and whether you're there. (Key cronoanálise deliverable, retained.)
- Reference comparison: mean vs. reference standard + efficiency; variability/consistency flags.

**Cross-study comparison (v1)**
- Operations matched by **catalog id** (unmatched excluded).
- Compares each operation's **representative time** (Sampling → mean; Time → observed) + efficiency vs reference standard.
- Presentation: **side-by-side table** (operations × studies) + **per-operation trend over time** (ordered by date).
- **Mixed study types allowed.** **Scoped within a single Project** for v1 (cross-project later).

---

## 5. Export

Two formats, two jobs:

- **PDF = presentation artifact.** Study header metadata, report tables, charts (Pareto / roll-up / trend rendered as images), embedded photos. **Single fixed template. No branding/logo in v1.**
- **XLSX = analysis artifact.** Multi-sheet: Summary, Operations, **Segments** (one row per measured segment — the raw evidence; a paused operation appears as two rows), plus raw Observations + Statistics for sampling. Numbers, not pictures.
  - The Segments sheet carries exactly the intervals the Gantt draws and `simultaneousMs` is swept from, so **the reported overlap can be recomputed downstream** and cross-referenced against machine logs. Fabricated (manual-override) time is deliberately absent — it is not a segment.

- Exportable at **study level** and **cross-study-comparison level**, both formats.
- Destination: **iOS → native share sheet**; **Windows → save-file dialog**.
- Locale drives number/date formatting (decimal comma vs. point).

**Implementation notes (Phase 5):**
- PDF charts are drawn as **native PDF vector widgets**, not rasterized screenshots — sharper, and it keeps the builder free of any widget tree so it is unit-testable.
- **Screen and PDF render the same Gantt**, sharing tick computation (`timelineTicks`) so the two artifacts can never label the same chart differently. PDF rows are chunked with a repeated axis, so a long study breaks between rows rather than overflowing a page.
- The built-in PDF fonts cover **Latin-1** (all of en/pt-BR/es) but silently drop typographic punctuation; `pdfSafeText` folds those to ASCII on the way in. Shipping a Unicode font asset is the fix if a non-Latin-1 language is ever added.
- XLSX durations are written as **numeric decimal seconds** (formatted strings would be dead text in a spreadsheet); sheet names stay untranslated so downstream formulas survive a language change.

---

## 6. Monetization & licensing

- **One-time purchase.**
  - **Free:** 1 project, 3 studies, **no export**.
  - **Paid (Chronus Pro):** unlimited projects/studies + export.
- **iOS mechanism:** single **non-consumable StoreKit IAP** + **Restore Purchases** (Apple requires IAP; no accounts, no server). Free tier _is_ the trial — no separate trial.
- **Per-platform licensing.** No cross-platform single license in v1 (would force accounts).
- **Gating = simple local checks** (count projects/studies, block export). Acceptably bypassable for this market.

**Windows licensing is dropped, not deferred (2026-07-26).** The Windows audience is internal — colleagues at one company, handed a zip — and is expected to stay that way. So there is no free/paid split on Windows, no gating code, no license key and no Microsoft Store IAP: everything in this section applies to iOS only. _This is a stronger statement than "deferred" on purpose_ — a deferred decision invites someone to pick it up, and building gating for an audience that will never be charged is pure cost. §9's open item stays open indefinitely rather than being resolved.

The knock-on effect is that **Phase 6 of §8.2 largely evaporates on Windows**: its backup bundle was built early and its StoreKit half does not apply, so the phase is skipped rather than reordered.

---

## 7. Localization & presentation

- **Languages at launch: pt-BR + English + Spanish.** Full i18n from day one (Flutter `intl` / ARB; no hard-coded strings). Locale drives number/date formatting.
- **Time storage:** integer **milliseconds** (from timestamps — exact).
- **Entry/display units:** **seconds** (default) + **decimal minutes**. (Centesimal minute not needed.)
- **Reports** use a **dynamic `HH:MM:SS.D`** format — tenths of a second, collapsing leading empty units (e.g. `4.3`, `1:15.2`, `1:02:05.4`).

---

## 8. Build sequence & release plan

### 8.1 Validate before building (the core bet)

The single most-unvalidated assumption is the **live timing interaction**: **can an analyst observing a station capture per-operation times accurately — including _concurrent_ operations (two operators, or man + machine), pauses/interruptions, resets and corrections — on the device actually in hand, without fumbling?** Validate this _first_, cheaply:

1. **Functional timing spike** — a mini study-workspace **in Flutter** (the real stack, so timing code carries forward) exercising **only**: the per-operation segment engine, concurrent timers, pause → log-interruption, reset, manual override, and inline add/reorder. Test on a **real study** on the device the analyst will really use.
2. **Low-fi Figma clickable flow** — catalog → study workspace → reports — to validate information architecture before building those screens.

> **Note (2026-07-20):** the original core bet was "does a _one-handed, one-big-button lap stopwatch_ feel right." Domain review with the practitioner rejected that model — real time studies are per-operation, concurrent, and pausable (see §3.5) — so the first lap-stopwatch spike validated the **wrong** model and is superseded.

### 8.2 Phased build (each phase leaves the app runnable)

1. **Foundations** — Flutter project, Drift schema, i18n scaffold, navigation, settings.
2. **Structure** — Projects/Studies CRUD, operation Catalog, sequencing, Templates.
3. **Core** — the **study workspace** (one merged screen): per-operation timing engine (multi-segment, concurrency, pause/interruption, reset, manual override), inline add / reorder / edit / duplicate / delete, notes + photos. Retires the separate sequence screen.
4. **Analysis** — Time Study report: observed-vs-reference, **efficiency**, category roll-up, **timeline**, waste Pareto, incl. elapsed-vs-simultaneous totals from concurrent timers.
5. **Export** — PDF + XLSX.
6. ~~**Licensing** — StoreKit IAP + gating + backup bundle.~~ **Skipped on Windows** (§6): the backup bundle shipped early, and the rest is iOS-only work that cannot be done without an Apple Developer account.
6b. **Windows operation** (inserted 2026-07-26, §10) — build identity, diagnostics log, feedback channel, abandoned-run recovery, automatic snapshots, window geometry, keyboard timing. **Complete**, bar the optional backup folder in §10.8.
7. **Sampling Study** — repeat engine + statistics + sample-size adequacy. Decisions in **§11**.
8. **Cross-study comparison.** Decisions in **§11**; ships in the same drop as 7 (§11.11).
9. **Polish** — video, iPad layouts, finalize pt/en/es.

**Why 6b comes before 7.** Sampling Study is "run the Time Study K times" (§3.2) — it is built directly on the study workspace and reuses its timing engine. Real use had not touched that workspace when this order was written, so building Sampling first risks building it twice: any interaction change that the first real studies force would then land in two places instead of one. Hardening the workspace, and being able to *hear* about it, comes first. _Continuing straight to Phase 7 was rejected_ for that reason, not for lack of demand — Sampling is the most-asked-for missing feature.

### 8.3 Release

- **First public App Store release = FULL v1** (all phases 1–9 complete: Time Study + Sampling + Cross-study comparison + export + licensing + three languages).
- Release happens only **after** the stopwatch spike and Figma flow have validated the concept and the full build is done.

---

## 9. Open items (deferred, not blocking)

- ~~Windows licensing mechanism~~ — **closed by dropping it** (§6). Windows is internal-only.
- Whether to ship starter/built-in templates once real usage is observed. (The catalog is **empty on first run** — only the 7 wastes and the Process Type picklist are seeded — so a new user must author every operation before timing anything.)
- Audio/voice notes (v2).
- Cross-project comparison (post-v1).
- Cloud sync / accounts (explicitly out; revisit only if demanded).
- **Validating §8.1's core bet with words-only feedback.** The unvalidated assumption is whether an analyst *fumbles*; a written report cannot show that. The in-app feedback channel (§10) is the only signal carrying it, which is thinner than watching someone work.
- **Stale drops.** Nothing tells a user a newer zip exists. Tolerable only at this scale, because drops can be announced by hand.

---

## 10. Windows operation

_Added 2026-07-26, ahead of the first handout to colleagues (2026-07-27)._

Everything above is about what the app computes. This section is about a build that leaves on a zip and is used where nobody is watching — the failure modes are different, and the plan had nothing to say about them because it was written iOS-first.

The governing fact: **feedback arrives as words, from people running real studies alone.** Words carry no stack trace and no version number.

### 10.1 Build identity

- The build is named by a **date label** in one constant (`kBuildLabel`, `lib/src/app/build_info.dart`), shown in Settings so a user can read it aloud, and **parsed by `tool/package_windows.ps1`** for the zip name — so the string on screen and the name on disk cannot disagree. A second drop the same day gets a letter suffix (`2026-07-27b`).
- Each packaged commit gets a **`previa/<label>` git tag**, which is what turns a reported date back into code. The script **refuses to package** when the tag already exists, or when the working tree is dirty (`-AllowExistingTag` / `-AllowDirty` to override): both would make the label a lie.
- _Rejected: `package_info_plus` + pubspec semver._ `1.0.0+1` deliberately does not yet mean what §8.3 means by v1. _Rejected: `--dart-define` stamping._ Dev runs go anonymous, no test can pin the value, and forgetting the flag once produces an unidentifiable zip.

### 10.2 Diagnostics log

`log.txt` in the app data directory, offered to the user as a single file via **Settings → Save diagnostics**, named `chronus-log-<label>-<machine>.txt` so files arriving from several colleagues are not all called `log.txt`.

- **Three error hooks, not one.** `FlutterError.onError`, `PlatformDispatcher.onError`, **and a Riverpod `ProviderObserver`**. The third is the important one: ten screens render a failed provider as `Center(child: Text('$error'))`, so the failure class users are most likely to hit never touches the framework handler.
- **Session header** (build, host, OS, locale) plus a `db` line from the database's own `beforeOpen` carrying schema version and whether this launch created or upgraded it. "Fresh install or upgrade?" answers a surprising share of reports on its own.
- **Thin breadcrumbs:** route changes and `timer.start/pause/stop/lap/reset/override`, carrying **ids only, never text the user typed**. That keeps the file something a colleague can forward without wondering what else is in it, and still enough to reconstruct a run's shape — including the concurrency and pauses that are hardest to describe in words. `timer.reset` and `timer.override` are logged precisely because they destroy or fabricate evidence.
- **Appended immediately, never buffered**, because the lines worth having are the ones written just before a crash. **Trimmed at startup** past ~1 MB, cutting only at session boundaries. _Resetting the log at launch was rejected_: after a crash the user relaunches, so a reset destroys exactly the session that mattered. _Rejected: one file per session_ — the user is then asked to choose, and will send the clean one.
- **Never throws.** Every failure inside the logger is swallowed; a logger that can take the app down is worse than none.

### 10.3 Feedback channel

A text field in **Settings** and in the **study workspace's overflow menu**, appending stamped entries to `feedback.txt`, which rides along inside the saved diagnostics file.

- In the workspace because **friction is felt during a run and forgotten by the time anyone opens Settings**. Timing is database-backed, so opening the dialog mid-run stops nothing.
- One file to ask for, and nothing lost if the user never gets around to messaging anyone that day. _Rejected: clipboard-only_ (exists until the next Ctrl+C) and _`mailto:`_ (needs a configured mail client, and cannot attach the log).

### 10.4 Abandoned runs

§3.5's absolute timestamps mean an open segment keeps counting from its original start. That is right for backgrounding on iOS. On Windows **closing the window is how you leave**, so an operation started at 16:40 and abandoned reads sixteen hours the next morning — and the fiction is indistinguishable from measurement: it flows into the report, the wall-clock span, the simultaneous sweep, the Gantt and the XLSX Segments sheet **unhatched**, because it is a real segment.

- At launch, open segments raise a **non-dismissible prompt** naming how many operations and since when. Not a silent repair: only the analyst knows whether a long machine cycle is legitimately still running.
- The recovery action **deletes the open segment**. §5 already settled the principle — "fabricated time is deliberately absent; it is not a segment" — and a segment whose end was never observed is fabricated by that same standard. _Closing it at `now` and flagging it was rejected_: it persists the fiction as evidence, and a flag cleared without looking (or an export taken before looking) puts a sixteen-hour interval in the Segments sheet indistinguishable from real measurement.
- Other segments of the same operation survive, so an operation paused twice then abandoned keeps what really was measured; one left with none returns to pending, and the analyst re-times it or enters a manual override.

### 10.5 Automatic snapshots

`app_directory.dart` is explicit that on Windows the manual `.chronus` bundle is the *only* safety net — and it requires a colleague to remember, in Settings, to do a thing with no immediate benefit. Nobody will. So there are now **two nets aimed at two different failures**:

| | `.chronus` bundle | Automatic snapshot |
|---|---|---|
| Protects against | losing the machine | **us** — a bug or bad migration |
| Contents | rows **+ photos** | rows only |
| Trigger | the user, deliberately | silent, once a day at launch |
| Leaves the PC | yes, that's the point | no |

- **Database-only, on purpose.** Photos are immutable once written and no migration touches them, so they are not at risk from the failure this protects against — and copying the photo library three times over would cost orders of magnitude more disk to guard something safe. 132 KB per snapshot today; three kept.
- **`VACUUM INTO`, as with the bundle** (§2): transactionally consistent against a live database, folds in un-checkpointed WAL content, and emits a single file with **no `-wal` sidecar to go stale beside it**.
- **Silent.** No prompt, no nag, never blocking a launch, and it cannot fail one — whether it ran goes to the diagnostics log, so a data-loss report can be answered with "there is a copy from yesterday" instead of a guess. _A "you haven't backed up in 14 days" banner was rejected_: it is the same ask the user is already ignoring, only louder, and it makes them responsible for our bugs.
- **Restore leaves `media/` alone** — deliberately asymmetric with the bundle's `_replaceMedia`, which deletes the media directory outright. A snapshot holds no photos, so wiping media would destroy the user's entire library to roll back some rows. Left alone, the files on disk are a superset of what the restored rows reference: a photo added since the snapshot becomes unreferenced clutter, one deleted since renders as a broken thumbnail. Both are strictly better than losing the library.
- **Restoring never consumes the snapshot** — a copy is what gets migrated and read, because `_migrateToCurrentSchema` opens the file writably and a restore point must survive being used.
- **Ordering comes from the timestamp in the file name, never mtime.** Copying a folder resets modification times, and users do move this directory between PCs; mtime ordering would then prune the wrong files or decide a snapshot was not due when it was. The name is the only record of when a snapshot was really taken. It also means a stray `.sqlite` dropped in the folder is ignored rather than offered as a restore point.
- **Exposed as a guarded list** in Settings → Data, with the same confirmation as a bundle restore. _Leaving them invisible was rejected_: recovery would then mean walking someone through replacing `chronus.sqlite` in `%APPDATA%` **and** remembering to delete the `-wal` and `-shm` sidecars, where a stale `-wal` beside a replaced database can corrupt it. One button removes that footgun.

### 10.6 Window geometry

Windows does not remember a window's size, position or maximised state for an application — the app must. Without this, every launch opened at the hardcoded 1280×720 at (10, 10) from `windows/runner/main.cpp` and began with a manual maximise, several times a day.

- Stored as a small **json file beside the database**, not in `AppSettings`: window chrome is not domain state, and it would otherwise mean a schema migration whenever a field is added. Values are **type-tested, not cast** — the file is plain text in a folder the readme tells users to open, so a hand-edited value has to be rejected rather than thrown on.
- **The maximised flag and the frame are independent.** A maximised window's bounds *are* the screen, so storing those would mean unmaximising later restores to the whole screen and the layout is quietly lost. The last unmaximised frame is kept in memory and **seeded at startup**, because a user whose very first action is to maximise has no stored frame yet — and an earlier version, lacking that seed, saved nothing at all in exactly that case.
- **Restored bounds are checked against the current displays.** A laptop undocked from a second monitor would otherwise open a window nobody can reach, which is indistinguishable from the app failing to launch. Only a title bar's worth of overlap is required, so a window straddling two screens or hanging off an edge is still honoured — users park windows like that deliberately.
- **Minimum size 900×600**, below which the timing table cannot lay out its columns.
- **`waitUntilReadyToShow` is called without its callback.** It invokes that callback *without awaiting it*, so anything asynchronous inside races the caller; the geometry work is awaited inline instead.
- **`win32_window.cpp`'s `Show()` uses `SW_SHOW`, not the template's `SW_SHOWNORMAL`.** The window is created hidden and revealed from the first-frame callback, which is what avoids both a flash and an empty window — but `SW_SHOWNORMAL` *un-maximises*, so it silently cancelled the restore. This is a deliberate deviation from the Flutter template; the reason is recorded at the call site.

### 10.7 Keyboard timing

The on-floor premise is **eyes on the machine, not on the screen**. An analyst watching a station cannot spare attention for a mouse, so the common case — a straight sequential run — is one key pressed repeatedly.

| Key | Does |
|---|---|
| `Space` | Lap: stop the running operation, start the next, gaplessly |
| `↑` `↓` | Pick a row |
| `Enter` | Start / pause the picked row |
| `S` | Stop the picked row |
| `Esc` | Clear the picked row |
| `F1` | The shortcuts sheet |

- **`Space` drives the existing `stopAndStartNext`**, which closes one operation and opens the next at the *same instant*, so a run has no gap. With nothing running it starts the first operation never timed.
- **With two or more running, `Space` does nothing but say so.** Lapping is a sequential-flow action and "the current operation" has no meaning under the concurrency this app exists to capture; guessing means stopping the wrong operator's timer, which destroys evidence that cannot be recovered. Refusing is the only rule that can never do that — and it is what makes the blind press safe, because the one case that needs looking at the screen is the one case it declines to guess. _Acting on the most recently started was rejected_: under man + machine the machine timer is usually started second and runs longest, so a blind lap would repeatedly target the operation you least want to stop.
- **The rule is a pure function** (`lapActionFor` in `timing_model.dart`) returning a sealed result, so it is tested without a widget. "Do nothing" is two distinct outcomes — nothing *left* to start, versus a refusal to guess — because they mean different things to the analyst and only one says the run is over.
- **Row selection is tracked in the widget, not Flutter's focus tree, and the row controls are wrapped in `ExcludeFocus`.** `WidgetsApp` maps Space and Enter to activating the focused button, so a ▶ that kept focus after a click would turn the lap key into "press ▶ again" — silently restarting an operation instead of advancing the run. The bindings live on a `Shortcuts` widget *inside* the workspace, which is what makes them win: shortcuts resolve from the focused node upwards, so being nearer than `WidgetsApp` decides it. There is a test that clicks ▶ and then presses Space specifically to hold this.
- The cost of that choice is that `reset` and the row menu are mouse-only. Accepted: everything on the timing path has a key.
- **The workspace autofocuses**, so keys work on arrival — an analyst should not have to click into the table first. Clicking a row also picks it, so mouse and keyboard agree on what "the picked row" means.
- **`F1` only, no `?`.** Typing `?` needs Shift plus a key that moves between layouts — on a Brazilian ABNT2 keyboard it is not where a US layout puts it — and a shortcut that silently does nothing on the keyboards these users actually have is worse than none. The **keyboard icon in the app bar** is what makes the sheet discoverable, and the sheet explains *why* Space goes inert under concurrency, since that behaviour reads as a bug until you know it is a refusal.

### 10.8 Planned next (not yet built)

- **Optional backup folder.** Snapshots (§10.5) cover our own bugs, but not a dead disk — and nothing yet covers that without the user acting. A path setting (a mapped network drive, or a synced folder) that the `.chronus` bundle is written to automatically would. A *closed* bundle in a synced folder is safe; the OneDrive warning in `app_directory.dart` is about the live database and its `-wal`, not a finished zip.

---

## 11. Sampling Study & cross-study comparison

_Added 2026-07-27, from the design review that preceded implementation of Phases 7 and 8._

§3.2 and §4 say what a Sampling Study **is**; `sampling_statistics.dart` computes what it **means**. This section is the part in between — the decisions that turn "run the Time Study K times" into a thing that can be built, and cross-study comparison into a thing that can be trusted.

> The statistics layer shipped ahead of this section and cites **"§10.9"** in two places (`tables.dart`, `sampling_statistics.dart`). That section never existed; the references are to this one, and are corrected.

### 11.1 The pass

A Sampling Study opens on a **list of passes**, not on the timing workspace. Each row is one observation — index, time, how many operations it timed, whether it is excluded — and opening one pushes the **existing workspace, unchanged**.

- **The workspace is not modified by Phase 7 at all.** It knows about one observation and does not know that others exist: no pass switcher, no rollover, no new keyboard semantics, and `lapActionFor`'s three outcomes (§10.7) keep their current meanings. This is the whole reason the pass lives on its own screen — the workspace is the one screen with real use behind it, and the riskiest step of this phase (§11.10) becomes a mechanical re-key with no behaviour change.
- _Rejected: an active-pass switcher inside the workspace._ It is the smaller number of taps and the worse blast radius; it puts pass state into the screen that must not regress.
- _Rejected: `Space` rolling over into the next pass._ It reads as the purest form of §10.7 — the entire study as one repeated keypress — but it converts `NothingToStart`, a defined no-op, into a row-creating mutation, so a stray press at the end of a run silently opens an empty pass.
- **The cost is accepted and named:** a pass boundary is a back-navigation and a tap, at the moment the analyst has least attention to spare, on the screen §10.7 exists to keep them off. It is **two interactions × K passes**. This is pure UI with no schema behind it, so a "finish pass & start next" action stays cheap to add if real use asks for it — which is why the decision was deferred rather than taken now.

**An observation is created with the study, never lazily.** The invariant is that **a study always has at least one pass**: a Time Study has exactly one forever, a Sampling Study grows more.

- Everything downstream loses its nullable-observation branch — workspace, report, Gantt, export. `_ensureObservation` disappears rather than being generalised.
- `discardRun` changes from **deleting the observation** to **clearing its instances and segments**. Better regardless: `sequenceIndex` survives, so throwing away a bad run does not renumber anything.
- Existing observations are inserted at **`sequenceIndex: 0`**, so the v6 backfill uses 0 and the label is `sequenceIndex + 1`. Getting this wrong would collide with the `{studyId, sequenceIndex}` unique key on the next pass created.

### 11.2 Sequence edits across passes

`StudyOperations` is per-study and shared by every pass (by design — `tables.dart`). Editing it mid-study therefore reaches backwards into passes already timed.

- **It stays editable.** §3.5 is explicit that the operation list *is* the live workspace and that an unplanned operation can be inserted mid-study; a ten-pass run across a shift will certainly hit one. _Freezing the sequence after pass 1 was rejected_ for that reason: an interruption in pass 6 would then have nowhere to be recorded, and its time would land in `unattributed` where §3.5 says attributed dead time belongs.
- **A hole is just a smaller n.** `statisticsFor` already takes whatever times exist, so an operation added at pass 4 has n=2 while its neighbours have n=5. The report **shows n per operation** so partial coverage is visible rather than inferred — the same disclosure §3.5 makes with "5 of 7 ops" on the Expected tile.
- **Deleting an operation warns with the number of passes that lose measurements.** `remove` hard-deletes and cascades through every observation, so during pass 5 it destroys passes 1–4's evidence for that row. Silent is not acceptable for that.
- **An operation flagged `isUnplanned` is shown with statistics but excluded from the study-level verdict** (§11.5). An interruption timed once would otherwise pin the study at "not adequate" forever, for a row that is not part of the standard sequence.
- _Rejected: a per-pass sequence._ It matches the mental model of independent passes and contradicts the schema. It also makes matching rows across passes a problem with no good key — `catalogOperationId` is null for custom and unplanned operations, `name` is editable, `orderIndex` shifts.

### 11.3 Exclusion — readings and passes

Cronoanálise discards anomalous readings before computing a mean, and nothing in the app could express that. Two levels now can, on one principle: **exclusion is non-destructive, reversible, attributed, and never automatic.**

- **A reading** (an `OperationInstance`) carries an exclusion stamp and an optional reason. **A pass** (an `Observation`) carries the same, and excludes all of its readings at once — that is what an analyst actually decides when a whole run was rubbish because the line was starved, and it is cheaper than looping the reading-level flag over every row.
- Excluded readings stay in the database, stay in **that pass's own Time Study report** (the pass really did take that long), and stay in the **XLSX Segments sheet** — they are real evidence. They are out of the aggregate mean, deviation, CV and sample-size verdict, and **both counts are always stated** ("n 5 of 6").
- **The app may flag, it may not act.** Readings beyond ±3s can be surfaced as candidates; the exclusion is always the analyst's. This is §10.4's reasoning exactly — only the analyst knows whether a long cycle was legitimate.
- _Rejected: automatic ±3s trimming_, the classic textbook rule. At these sample sizes it does not work: a single outlier inflates the deviation enough to bring itself back inside the bound, so with n=5 the rule most often excludes nothing, and when it does fire it silently changes numbers the analyst never agreed to.
- _Rejected: no exclusion in v1._ The workarounds are both worse than the problem — deleting a pass throws away every other operation's good reading in it, and a manual override invents a number, which §5 and §10.4 both go out of their way to refuse.
- **Passes are excluded, not deleted.** Hard delete is available only for a pass with **no timing at all** — one opened by mistake, and never the study's last, since §11.1's invariant is what lets everything downstream drop its null branch. Both guards live in the repository rather than in the menu, so a second caller cannot route around them; the menu shows the action **disabled rather than hidden**, because "where did delete go?" is worse than being told that a pass with measurements is excluded instead.
- `sequenceIndex` is never renumbered and never reused, so "Pass 4" in an exported file or a written note means the same pass forever (§3.3's historical integrity, applied to passes). A gap in the list is labelled, not silent. The next index therefore comes from a **counter on the study** (`nextPassIndex`), not from `MAX(sequenceIndex) + 1` — that would hand a deleted pass's number straight back to the next one, which is the same rule failing in the one case it exists for.

### 11.4 Manual overrides in the statistics

**An overridden time counts, and is marked.**

§5 keeps fabricated time out of the **Segments sheet** because that sheet answers *what intervals were measured*. Statistics answer a different question — *what was the reported time* — and `observedMs` has been override-or-sum everywhere since Phase 4 (`timing_model.dart`). Excluding overrides would give a study transcribed from paper **no statistics at all**, killing the use case §3.5 names explicitly.

The obligation that comes with counting them is disclosure: each overridden reading is marked and the count is stated, exactly as §4 hatches unmeasured Gantt blocks so an overlap reads as unverified rather than observed. _Rejected: counting them silently_ — a report handed to someone else could then not tell a measured mean from a typed one, and a standard deviation over typed numbers is meaningless in a way the reader has no way to detect.

### 11.5 Sample-size adequacy at study level

Criteria are per-study (§10.9 → here; `Studies.confidenceLevel` / `relativePrecision`, schema v5); `requiredPasses` returns a verdict per operation. The study-level answer is that **the worst included operation governs, and is named.**

Passes are taken through the whole sequence — you cannot add passes for one operation alone — so the binding constraint is the maximum required across operations. Naming it turns the verdict into an instruction ("four more passes; Inspect is what needs them") rather than a grade.

Three cases are kept distinct because they mean different things:

| Case | Reported as |
|---|---|
| Included operation short of its required n | **not adequate**, with the shortfall |
| Included operation with n < 2 | **not yet determinable** — no spread to extrapolate from |
| Operation never timed in any pass | **coverage**, not failure — incomplete ≠ inadequate |
| Operation flagged `isUnplanned` | excluded from the verdict (§11.2) |

- _Rejected: no study-level verdict._ "Is this study done?" is the question the report is opened to answer, and every reader would take the maximum in their head anyway.
- _Rejected: a count ("6 of 7 adequate")._ It reads as partial credit for something that is not partial — at ±5 %, an operation short of its n has a mean that is not trustworthy to ±5 %, and averaging that into a percentage hides precisely the operation the analyst needs to go re-time.

### 11.6 Reports

**The study's report is aggregate only.** Criteria and verdict, per-operation statistics, the readings matrix (operations × passes, carrying the excluded and manual marks), mean vs reference standard and efficiency, and category roll-up + waste Pareto computed **on means**.

**It has no Gantt, no elapsed, no simultaneous and no unattributed** — those are per-pass measurements of one run, and summing or averaging them across passes produces figures that do not describe anything. §4's reconciliation `elapsed = covered + unattributed` holds within a pass and nowhere else.

**Each pass row in the list opens `time_study_report_screen` verbatim**, because a single pass *is* a time study. One screen per concept, no tabs, no duplicated navigation — and the per-pass Gantt is how an analyst explains an outlier (what ran alongside it, where it paused) **before** deciding to exclude it under §11.3.

- _Rejected: one tabbed report, Summary plus a tab per pass._ It duplicates navigation the pass list already provides, and a ten-pass study is eleven tabs.
- _Rejected: aggregate only, with no per-pass report._ The data is there and already renders, and it is the evidence behind every exclusion decision.

### 11.7 Export

**One workbook, flat — one row per fact.** Sheet names stay fixed identifiers (§5), and the study-level export carries every pass:

| Sheet | Grain |
|---|---|
| `Summary` | study header, criteria, verdict, governing operation |
| `Statistics` | one row per operation — n, mean, min, max, range, s, CV, required n |
| `Observations` | one row per **pass × operation** — reading, excluded flag, manual flag |
| `Segments` | as §5, gaining a leading **Pass** column |

Carrying the excluded and manual flags into `Observations` is what extends §5's guarantee to the aggregate: the reported overlap was already recomputable downstream, and now **the reported mean is too** — a spreadsheet can filter out the excluded rows and arrive at our number.

The PDF leads with the aggregate sections and follows with a **per-pass appendix** — each pass's summary and Gantt, reusing Phase 5's chunked-row renderer.

- _Rejected: aggregate only, with per-pass export left as a separate action._ A ten-pass study is then eleven files to hand to anyone, and the raw segments never sit alongside the statistics they support.
- _Rejected: sheets per pass_ (`Operations_P1`, `Segments_P1`, …). Twenty-two sheets for ten passes, and every formula written against one pass has to be rewritten for each of the others.

### 11.8 The catalog link

Cross-study matching is by `catalogOperationId` (§4), and §3.3 promises that "the hidden id still enables cross-study grouping". It did not: the column is a foreign key with `onDelete: setNull`, and `delete` in the catalog repository is a hard delete — so **tidying the catalog silently unmatched every past study**, with nothing said and no way to notice.

**The id becomes a snapshot value: plain text, no foreign key.**

§3.3 already snapshots name, category and reference standard onto `StudyOperations` precisely so later catalog edits cannot mutate history. The id was the one field left as a live reference, and that was the inconsistency. As a value the grouping key is immutable, and comparison groups by it directly; the join to the catalog was only ever needed for a display name, which is already snapshotted.

**This lands in v6 with the rest, not at Phase 8** — every study created in between would otherwise accumulate the live foreign key.

- _Rejected: soft-deleting the catalog (an archived flag)._ It keeps the join and adds an archived state to every catalog query and screen, while protecting only studies made after the change; anything that does delete a row still nulls history.
- _Rejected: refusing deletion when referenced._ The database enforces the guarantee, and the catalog becomes append-only in practice — a typo created and used once can never be cleaned up.

### 11.9 Cross-study comparison

§4 settles the shape (matched by catalog id, side-by-side table + per-operation trend, mixed types allowed, within one project). Two things it left implicit, both resolved the same way — **disclose, do not silently normalise**:

- **Every representative time carries its n**, and the trend chart marks a single reading distinctly from a mean. A Sampling mean over six passes and one press of a stopwatch are otherwise the same number in the same column, and "Weld seam improved 6 % since March" reads as a finding when March was one reading.
- **"Unmatched excluded" becomes a stated count**, naming the operations dropped for having no catalog link (custom or unplanned). A comparison that quietly omits a third of the work content is worse than one that admits it — and this is the artifact most likely to be read by someone who ran neither study.

_Deferred, not rejected: a t-based confidence band on the trend._ The machinery exists — statistics give s and n, `studentT` is already tabulated — and it would make "did this actually get faster" answerable rather than eyeballed, since two means whose intervals overlap have not been shown to differ. It costs a second render path in the PDF vector chart builder, and is worth revisiting once the comparison is in real use.

### 11.10 Schema v6

One migration, carrying five changes:

1. **`Observations`** gains an exclusion stamp + reason (§11.3).
2. **`OperationInstances`** gains an exclusion stamp + reason (§11.3).
3. **`Studies`** gains `nextPassIndex`, the pass counter (§11.3).
4. **`StudyOperations` is rebuilt** to drop the foreign key on `catalogOperationId` (§11.8).
5. **Backfill** one observation at `sequenceIndex: 0` for every study that has none (§11.1), then seed every study's counter past whatever it now has.

The fourth makes this the **riskiest migration so far** — the first that rebuilds a table rather than adding to one. §2's warning applies directly: columns are copied **explicitly, never `SELECT *`**, because a table rebuilt by a migration can have a different column order than a freshly created one. Drift's `alterTable` does that, and also holds `legacy_alter_table` across the rename — without which SQLite rewrites `OperationInstances`' own foreign key to follow the table being renamed out of the way, leaving it pointing at something about to be dropped. There is a test that asserts `PRAGMA foreign_key_check` is clean afterwards.

The ordering is deliberate: additive steps first, so a failure in the rebuild leaves the least behind, and the backfill last, so it runs against final tables — and the counter is seeded after the backfill, or a study that gained pass 0 there would hand out `0` again on the first **New pass**.

**The `operation_instances` columns are added only `from >= 3`.** The 2→3 step rebuilds that table with `m.createTable`, which builds it from the *current* Dart definition — so on a v1/v2 database it already arrives carrying them, and adding them again fails the whole upgrade. This applies to any future column on `OperationInstances` or `OperationTimeSegments`; `Observations` needs no such guard, because no migration step creates it. This was found by the v1→v6 test, not by reading.

§10.5's automatic snapshots are the net, and the diagnostics `db` line already records whether a launch upgraded the schema, so a report arriving in words can still be diagnosed.

### 11.11 Build order

**7a** re-key the timing layer from `studyId` to `observationId` · **7b** pass list + v6 · **7c** sampling report · **7d** sampling export · **8** cross-study comparison.

7a is mechanical and touches everything; it stays its own step, with no behaviour change to justify, which §11.1's decision is what makes possible.

**One drop, after both phases.** Comparison is arguably what makes sampling worth doing — the point of a settled mean is having something to compare it against — so the two ship as one coherent release rather than handing colleagues an intermediate build. _The cost is named:_ the v6 migration then arrives alongside whatever Phase 8 adds, so a fault in either is harder to attribute, which is why the migration test above is not optional. _Rejected: dropping 7a+7b early_ to expose the migration on its own — it would hand colleagues a build where a sampling study can be run in passes and still not be reported on, which is the dead end that exists today.
