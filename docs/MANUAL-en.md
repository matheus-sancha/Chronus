# Chronus — User Manual

**Time-study (cronoanálise) application for manufacturing engineers and technicians.**

Internal preview · Covers the Windows build · [Versão em português](MANUAL-pt.md)

---

## Contents

1. [What Chronus is for](#1-what-chronus-is-for)
2. [Installing and starting](#2-installing-and-starting)
3. [How the app is organised](#3-how-the-app-is-organised)
4. [Projects](#4-projects)
5. [The operation catalog](#5-the-operation-catalog)
6. [The study workspace](#6-the-study-workspace)
7. [Worked example: one bracket cycle](#7-worked-example-one-bracket-cycle)
8. [The report](#8-the-report)
9. [Reading the timeline](#9-reading-the-timeline)
10. [Why the numbers do not add up](#10-why-the-numbers-do-not-add-up)
11. [Notes and photos](#11-notes-and-photos)
12. [Exporting](#12-exporting)
13. [Settings, backup and restore](#13-settings-backup-and-restore)
14. [Not built yet](#14-not-built-yet)
15. [Troubleshooting](#15-troubleshooting)

---

## 1. What Chronus is for

Chronus lets you stand at a machine, time a sequence of operations, classify each one as setup, value-added or waste, and produce a report you can defend in a meeting.

It is built for the way time studies actually run on a shop floor:

- **The clock is not always running.** Not every instant belongs to an operation. Dead time is only counted when you explicitly attribute it to something.
- **Operations overlap.** Two operators on one assembly, or a machine running while the operator waits. Chronus treats concurrency as normal, not as an error.
- **You correct as you go.** Operations get added mid-study, times get entered by hand when you forget to press start, and a measurement gets thrown away and redone.

Everything is stored on the computer you run it on. There is no login, no sync, and no server.

---

## 2. Installing and starting

1. Unzip the whole folder anywhere, e.g. `C:\Chronus`. There is no installer.
2. Run `chronus.exe`.
3. The first time, Windows may show **"Windows protected your PC"**. Click **More info → Run anyway**. This appears because the program is not yet code-signed.

Keep every file in the folder together — `chronus.exe` will not start on its own.

**Where your data lives.** Not in the program folder. It is kept in:

```
%APPDATA%\com.matheussancha\chronus
```

Paste that into the File Explorer address bar to open it. Because your data is stored outside the program folder, you can unzip a newer version over the old one without losing anything.

---

## 3. How the app is organised

```
Project
 └─ Study
     └─ Operations (timed individually)

Catalog  — reusable operation definitions, shared across all studies
Template — a reusable ordered sequence of operations
```

- A **Project** groups related studies — usually a cell, a line, or a product family.
- A **Study** is one timed pass through a sequence of operations.
- An **Operation** inside a study is a *copy* taken from the catalog at the moment you added it. Editing the catalog later will **not** change studies you have already run. That is deliberate: a report from March must not silently change because someone revised a standard in July.

### Classification

Every operation falls into one of three fixed categories. Reports roll up by these, so they cannot be edited:

| Category | Meaning |
|---|---|
| **Setup** | Preparation — fixturing, tool offsets, changeover |
| **Productive** | Value-added — the work the customer pays for |
| **Unproductive** | Waste — everything else |

Unproductive operations also carry a **subtype**, drawn from the seven wastes: Waiting, Motion, Transportation, Over-processing, Overproduction, Inventory, Defects. You can add your own subtypes, but always inside one of the three categories above, so roll-up reporting keeps working.

### Reference standard

Any operation can carry an optional **reference standard** — a benchmark time you already have. When present, Chronus reports:

**Efficiency = reference standard ÷ observed time**

At or above 100 % means you met or beat the benchmark.

---

## 4. Projects

The opening screen. Create a project with the **+** button, then open it to add studies.

![Projects screen](manual/images/projects-en.png)

Use the row menu to rename or delete. Deleting a project deletes its studies with it.

---

## 5. The operation catalog

The catalog is your reusable library of operation definitions. Build it once and each new study becomes a matter of picking from a list instead of retyping.

![Catalog screen](manual/images/catalog-en.png)

Each entry carries a **name**, a **category** (and subtype, if unproductive), and an optional **reference standard**. The chips at the top filter by category. The **+** button adds an entry; the **⋮** menu on each row edits or deletes it.

The second line of each row shows `Category · reference standard`. An entry with no reference standard simply shows the category.

---

## 6. The study workspace

This is the screen you drive during a study. It is a single list — you build the sequence, time it, and correct it all in the same place.

![Study workspace](manual/images/workspace-en.png)

| | |
|---|---|
| **1** | **Report** — opens the analysis for this study |
| **2** | **Total** — wall-clock span, from the first start to the last stop |
| **3** | **Timed progress** — how many operations have a time yet |
| **4** | **Drag handle** — hold and drag to reorder the sequence |
| **5** | **Reference time** — the benchmark, if this operation has one |
| **6** | **State glyph** — colour is the category (amber setup, green productive, red unproductive); the mark shows whether it has been timed |
| **7** | **Observed time** — what was actually measured |
| **8** | **Start** — begins timing this operation, from zero |
| **9** | **Note and photo indicators** — appear once a row has either |
| **10** | **Reset** — discards this operation's time and returns it to zero (asks first) |
| **11** | **Row menu** — edit, duplicate, delete, enter a time by hand, add a note or photo |
| **12** | **manual** — flags a time that was typed in rather than measured |
| **13** | **Add operation** — pick from the catalog, or create one on the spot |

### Timing controls

Each operation has its **own independent timer**. There is no single master stopwatch.

- **▶ Start** — begins timing, from zero.
- **⏸ Pause** — stops the clock but keeps the elapsed time. Resuming opens a new segment. Chronus also offers to log the interruption as a separate unproductive operation, which is usually what you want.
- **⏹ Stop** — marks the operation complete.
- **↺ Reset** — throws the measurement away and returns the row to zero. It asks for confirmation.

Because each timer is independent, you can **run several at once**. Start the machine cycle, then start "operator waiting" alongside it — both run, and the overlap is measured and reported.

### Timing more than one operation at a time

This is the case Chronus exists for. Say the machine runs for 90 seconds and the operator stands idle for 50 of them:

1. Press **▶** on *Finish mill*.
2. Press **▶** on *Wait for coolant recovery* as well. Both are now running.
3. Press **⏹** on the wait when the operator resumes.
4. Press **⏹** on the mill when the cycle ends.

Both times are recorded in full, and the 50 seconds they share is reported as **Simultaneous**.

### Entering a time by hand

If you forgot to press start, or you are transcribing a paper study, use **Enter actual time** from the row menu (**11**).

A hand-entered time **shadows** the measurement rather than erasing it — any segments you did record are kept underneath. Clear the manual value and the measured time comes back. Rows carrying one are tagged **manual** (**12**), and the report draws them hatched so nobody mistakes them for measured evidence.

---

## 7. Worked example: one bracket cycle

Every screenshot in this manual comes from the same study, so you can follow it end to end. It is a bracket machining cycle on a Haas VF-2, and it is deliberately messy — it contains every awkward case you will hit in real work.

**Setting up**

1. From **Projects**, create *Cell 4 — bracket line*, and open it.
2. Add a study, name it *Cell 4 — bracket A baseline*. The analyst is filled in from Settings.
3. Fill in the header: part, machine, operator, shift, work order. All optional, all printed on the report.
4. Press **Add operation** (**13**) seven times, picking each from the catalog.

**Running it**

5. **▶** *Load billet into fixture*, **⏹** at 42.0 s. The reference standard is 40.0 s — slightly over.
6. **▶** *Rough mill — face*, **⏹** at 1:46.0.
7. **▶** *Finish mill — pocket*. Mid-cut the operator stops to clear chips: **⏸**, then **▶** again 20 s later. The two segments total 2:08.0.
8. While the mill is still running, **▶** *Wait for coolant recovery* — the operator is idle waiting for the pump. **⏹** at 50.0 s. **This ran at the same time as the finish mill.**
9. Nothing happens for half a minute — nobody presses anything. That gap becomes **unattributed** time.
10. **▶** *Deburr edges*, **⏹** at 50.0 s.
11. *Inspect — CMM check*: the timer was never started. Row menu → **Enter actual time** → `1:30`. It gets tagged **manual**.
12. *Stage for next cell*: never timed at all, entered as 45.0 s by hand.

**Reading it**

13. Press the **Report** button (**1**). Everything in §8 follows from these twelve steps.

---

## 8. The report

Read-only. Timing happens in the workspace; this screen only presents it.

![Report screen](manual/images/report-en.png)

| | |
|---|---|
| **1** | **Export** — PDF or XLSX (see §12) |
| **2** | **Total elapsed** — wall-clock span, first start to last stop. Here **6:30.0** |
| **3** | **Work content** — the sum of every operation's time. Here **8:31.0** |
| **4** | **Simultaneous** — time with two or more operations running at once. Here **30.0 s** |
| **5** | **Unattributed** — time inside the span that no operation covers. Here **36.0 s** |
| **6** | **Value-added ratio** — productive share of work content. Here **82.0 %** |
| **7** | **Efficiency** — Σ reference ÷ Σ observed, over operations that have both. Here **153 %** |
| **8** | **Category breakdown** — setup / productive / unproductive, by work content |
| **9** | **Timeline** — the wall-clock Gantt (see §9) |
| **10** | **Waste Pareto** — waste time by subtype, ranked worst first |
| **11** | **Operations** — observed, reference, efficiency, notes and photo count per row |

In the operations table, efficiency is coloured: green at or above 100 %, red below. *Load billet* shows **95 %** in red — 42.0 s observed against a 40.0 s standard.

---

## 9. Reading the timeline

The timeline is a **real wall-clock Gantt**. The horizontal axis is the actual time of day, not a sequence. Rows stay in planned order so they line up with the operations table.

![Timeline detail](manual/images/gantt-en.png)

| | |
|---|---|
| **1** | **Wall-clock axis** — real clock readings. A study with no live timing at all keeps a relative `0:00…` axis instead |
| **2** | **A gap inside a row** — the operation was paused and resumed |
| **3** | **Two rows overlapping in time** — concurrency. The coolant wait ran during the finish mill |
| **4** | **Whitespace between bars** — unattributed dead time, covered by no operation |
| **5** | **Solid fill** — backed by a real measured segment |
| **6** | **Hatched fill** — reported but *not* measured, i.e. a hand-entered time |

The hatching matters. A bar's total width always equals the operation's **reported** time, so the chart can never disagree with the table. But an override longer than what was measured extends past the evidence, and that extension is drawn hatched. When you see an overlap involving hatching, read it as *unverified*, not observed.

Hatching is diagonal lines rather than a lighter shade on purpose — a lighter shade is indistinguishable from solid once the report is printed in black and white.

---

## 10. Why the numbers do not add up

This is the single most common question, and the numbers are not wrong.

**Total elapsed (6:30.0) is smaller than work content (8:31.0).**

Work content is the plain sum of every operation's time. When two operations run at once, that sum counts the shared stretch twice. Elapsed is the real span on the clock, which counts it once. So:

> Work content **counts overlap twice**. Total elapsed **never does**.

Never add operation times together to get "how long the job took" — that is what **Total elapsed** is for.

The two totals reconcile like this:

```
Total elapsed = covered time + unattributed time
      6:30.0  =     5:54.0   +      36.0 s
```

- **Simultaneous (30.0 s)** is swept from the actual recorded intervals, not calculated as `work − elapsed`. That shortcut only works when a study has no gaps, and goes negative as soon as gaps exceed overlap.
- **Unattributed (36.0 s)** is time inside the span that no operation claims. A large value usually means somebody forgot to press start.

**Efficiency of 153 % with an operation at 95 %.** Aggregate efficiency is `Σ reference ÷ Σ observed` across every operation that has both figures — not an average of the percentages. A few operations well under their standard dominate the total.

---

## 11. Notes and photos

Both attach to an individual operation, from the row menu (**11**).

- **Notes** — free text. They print in the Notes column of the report and the PDF.
- **Photos** — take one with the camera, or pick an existing file. They are embedded in the PDF export.

Once a row carries either, small indicators appear next to its name (**9**), with a count for photos.

On a phone or tablet, **Add photo** offers **Take photo** or **Choose from library**. On Windows it opens a file dialog — desktop has no camera.

Photos are downscaled on import. They are documentation, not archival captures, and full-resolution phone images would make backups too large to email.

---

## 12. Exporting

From the report screen, button **1**. Two formats, two jobs.

**PDF — the presentation artifact.** Study header, summary tiles, category breakdown, the timeline, the waste Pareto, the operations table, and any attached photos. One fixed layout. This is what you hand to someone.

**XLSX — the analysis artifact.** Multiple sheets of numbers, not pictures:

| Sheet | Contents |
|---|---|
| Summary | The header fields and the totals |
| Operations | One row per operation: observed, reference, efficiency |
| Segments | **One row per measured interval** — the raw evidence |

The **Segments** sheet is the one to reach for when somebody challenges a result. It contains exactly the intervals the timeline draws and that Simultaneous is calculated from, so the overlap can be recomputed independently and cross-checked against machine logs. Hand-entered time is deliberately absent from it — a typed number is not a measurement.

Durations are written as decimal seconds so they behave as numbers in a spreadsheet. Sheet names stay in English regardless of app language, so formulas built on top of an export survive a language change.

On Windows, export opens a save dialog.

---

## 13. Settings, backup and restore

![Settings screen](manual/images/settings-en.png)

- **Language** — Portuguese, English or Spanish. *System default* follows Windows.
- **Default analyst** — pre-fills the Analyst field on new studies.
- **Time unit** — seconds, or decimal minutes.

### Backing up

**Back up** writes a single `.chronus` file containing your entire database and every photo. Put it somewhere that is not this PC — a network share, a USB stick, a OneDrive folder.

There is no automatic backup and no sync. If the PC dies and you have no `.chronus` file, the studies are gone. On a shared shop-floor machine, back up at the end of every study.

### Restoring

**Restore** reads a `.chronus` file back in.

> **Restore replaces everything.** It is not a merge. Every project, study and photo currently in the app is discarded and replaced by the file's contents. Back up first if the current data matters.

The file is validated before anything is touched, so a corrupt or rejected file leaves the app exactly as it was. A backup from a newer version of Chronus is refused rather than half-read; an older one is upgraded automatically on import.

The same file is how you move data between machines: back up on one PC, copy the file across, restore on the other.

---

## 14. Not built yet

This is an internal preview. These are designed but not yet available:

- **Sampling Study** — repeating a study N times and aggregating statistically (mean, range, standard deviation, sample-size adequacy)
- **Cross-study comparison** — comparing studies side by side and trending an operation over time
- **Video attachments** — photos work; video does not
- **iPhone / iPad version**

Times, categories, reports and exports are complete and safe to rely on.

---

## 15. Troubleshooting

**"Windows protected your PC" when starting.** Expected — the program is not code-signed. **More info → Run anyway**.

**A missing-DLL error on startup.** Install the [Microsoft Visual C++ Redistributable (x64)](https://aka.ms/vs/17/release/vc_redist.x64.exe), then try again.

**The app starts but shows no projects.** Data is per Windows user account. If someone else set up the studies under their login, you will not see them — restore from their `.chronus` backup.

**Work content is larger than total elapsed.** Correct behaviour. See §10.

**An operation shows a time but the timeline draws it hatched.** The time was typed in, not measured. See §9.

**Unattributed time is large.** Somebody forgot to press start, or the study ran with long stretches that were never attributed to any operation. Check the timeline for wide gaps.

**I reset an operation by accident.** The measurement is gone — reset discards it. Restore from your most recent backup, or re-enter the time by hand.
