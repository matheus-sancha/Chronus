# Chronus — Design Specification

_Cronoanálise (time-study) application for manufacturing engineers and technicians, for on-the-floor process analysis and comparison._

**Status:** in implementation — Phases 1–2 built; Phase 3 (Core) in progress.
**Last updated:** 2026-07-20

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
- _Continuous single-cursor "one big lap button" timing rejected_ — it forces every instant onto some operation and cannot represent concurrency, pauses/interruptions, or discretely re-measured elements. (This reverses the original v1 decision, which had instead rejected snapback; the domain reality is the opposite.)

### 3.6 Standard-time chain (full, in v1)

```
Observed time
  × performance Rating %   (default 100)     → Normal time
  × (1 + Allowance %)      (default 0)        → Computed Standard time
```

- Rating is per-observation/per-operation; Allowance is study-level with **optional per-category override**. Both optional with sensible defaults.
- **Two distinct "standard times":**
  1. **Reference standard** — pre-existing benchmark stored in the catalog (the "standard" in standard-vs-actual).
  2. **Computed standard** — the study's output from the chain above.
  The comparison view shows both.

### 3.7 Templates

- **First-class entity:** an ordered list of catalog-operation references + default study settings (type, allowance %). **No measured data, ever.**
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
- Operation breakdown table: observed / rating / normal / computed-standard / reference-standard / % deviation.
- Category roll-up: % Setup vs. Value-Added vs. Waste.
- Waste Pareto: time by waste subtype, ranked.
- Summary card: total cycle time, value-added ratio, computed standard time.

**Sampling Study**
- Per-operation statistics across observations: mean, min, max, range, std dev, coefficient of variation.
- **Sample-size adequacy** — given observed variability and chosen confidence/precision, how many observations are needed and whether you're there. (Key cronoanálise deliverable, retained.)
- Standard comparison: mean vs. reference and computed standard; variability/consistency flags.

**Cross-study comparison (v1)**
- Operations matched by **catalog id** (unmatched excluded).
- Compares each operation's **representative time** (Sampling → mean/computed standard; Time → observed/computed standard) + % deviation vs reference standard.
- Presentation: **side-by-side table** (operations × studies) + **per-operation trend over time** (ordered by date).
- **Mixed study types allowed.** **Scoped within a single Project** for v1 (cross-project later).

---

## 5. Export

Two formats, two jobs:

- **PDF = presentation artifact.** Study header metadata, report tables, charts (Pareto / roll-up / trend rendered as images), embedded photos. **Single fixed template. No branding/logo in v1.**
- **XLSX = analysis artifact.** Multi-sheet: Summary, Operation Breakdown, raw Observations (sampling), Statistics. Numbers, not pictures.

- Exportable at **study level** and **cross-study-comparison level**, both formats.
- Destination: **iOS → native share sheet**; **Windows → save-file dialog**.
- Locale drives number/date formatting (decimal comma vs. point).

---

## 6. Monetization & licensing

- **One-time purchase.**
  - **Free:** 1 project, 3 studies, **no export**.
  - **Paid (Chronus Pro):** unlimited projects/studies + export.
- **iOS mechanism:** single **non-consumable StoreKit IAP** + **Restore Purchases** (Apple requires IAP; no accounts, no server). Free tier _is_ the trial — no separate trial.
- **Per-platform licensing.** Windows mechanism deferred (Microsoft Store IAP or own license key — decided when Windows is built). No cross-platform single license in v1 (would force accounts).
- **Gating = simple local checks** (count projects/studies, block export). Acceptably bypassable for this market.

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
4. **Analysis** — standard-time chain (rating/allowances) + Time Study reports, incl. **simultaneous-time** breakdown from concurrent timers.
5. **Export** — PDF + XLSX.
6. **Licensing** — StoreKit IAP + gating + backup bundle.
7. **Sampling Study** — repeat engine + statistics + sample-size adequacy.
8. **Cross-study comparison.**
9. **Polish** — video, iPad layouts, finalize pt/en/es.

### 8.3 Release

- **First public App Store release = FULL v1** (all phases 1–9 complete: Time Study + Sampling + Cross-study comparison + export + licensing + three languages).
- Release happens only **after** the stopwatch spike and Figma flow have validated the concept and the full build is done.

---

## 9. Open items (deferred, not blocking)

- Windows licensing mechanism (Microsoft Store IAP vs. own key) — decide when Windows work begins.
- Whether to ship starter/built-in templates once real usage is observed.
- Audio/voice notes (v2).
- Cross-project comparison (post-v1).
- Cloud sync / accounts (explicitly out; revisit only if demanded).
