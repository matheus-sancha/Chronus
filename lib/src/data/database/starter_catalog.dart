import 'enums.dart';

/// The operations a colleague finds in the catalog on first run (DESIGN.md §9).
///
/// **This is the one part of Chronus specific to the people using it.** §3.7
/// originally shipped nothing, on the reasoning that generic starter content is
/// noise — which was right when the audience was the App Store. §6 made Windows
/// internal-only, and for one known company the content can be exactly right
/// rather than merely plausible. The Process Type picklist in `database.dart`
/// already works this way; this is the same decision applied to the thing that
/// actually blocks a first study.
///
/// The list came from a real boring cycle. It is deliberately **deduplicated**:
/// a catalog holds one definition per operation, and a sequence that inspects
/// after every tool pass references the same `Inspection` four times rather than
/// carrying four of them. The ordering and the repeats belong to a template.
///
/// Keep it short. The point is getting someone from a cold install to a running
/// stopwatch, not modelling the whole shop — anything missing is one "add
/// operation" away.

/// A waste subtype the 7 built-ins do not cover (§3.4 allows custom subtypes,
/// always inside one of the fixed categories, so roll-up reporting still works).
typedef StarterSubtype = ({String name, OperationCategory category});

/// Seeded because the operations below need them and they are not among the 7
/// wastes. Both sit under `unproductive`, which is a claim worth being explicit
/// about: neither changes the part, so neither is value-added — inspection
/// proves the work was right rather than doing it, and a tool change is the
/// machine not cutting. Both then appear in the waste Pareto, which is the
/// point of classifying them at all.
const starterSubtypes = <StarterSubtype>[
  (name: 'Tool Setup/Change', category: OperationCategory.unproductive),
  (name: 'Inspection', category: OperationCategory.unproductive),
];

typedef StarterOperation = ({
  String name,
  OperationCategory category,
  String? subtypeName,
  int? referenceStandardMs,
});

/// Reference standards are deliberately absent. A benchmark that came from
/// nobody's measurement would flow into efficiency figures and pace alerts as
/// though it meant something (§3.6), and a wrong standard is worse than none —
/// the analyst enters the real one once, in the catalog, and every future study
/// snapshots it.
///
/// Subtypes are referenced **by name**: the built-ins carry generated ids, and
/// on an upgrade they already exist with ids this file cannot know.
const starterCatalog = <StarterOperation>[
  (
    name: 'Machine Setup',
    category: OperationCategory.setup,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Workoffset',
    category: OperationCategory.setup,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Tool load',
    category: OperationCategory.unproductive,
    subtypeName: 'Tool Setup/Change',
    referenceStandardMs: null,
  ),
  (
    name: 'Bore Roughing Operation 1',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  // Used twice in the cycle, once in the catalog.
  (
    name: 'Insert Change',
    category: OperationCategory.unproductive,
    subtypeName: 'Tool Setup/Change',
    referenceStandardMs: null,
  ),
  // Used four times in the cycle, once here.
  (
    name: 'Inspection',
    category: OperationCategory.unproductive,
    subtypeName: 'Inspection',
    referenceStandardMs: null,
  ),
  (
    name: 'Bore Roughing Operation 2',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Bore Semi-Finish Operation 3',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Bore Finish Operation',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  // Distinct from 'Tool load': loading a tool at setup and swapping one
  // mid-cycle are different events an analyst wants to tell apart afterwards.
  (
    name: 'Tool change',
    category: OperationCategory.unproductive,
    subtypeName: 'Tool Setup/Change',
    referenceStandardMs: null,
  ),
  (
    name: 'Break Edges',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Machine Teardown',
    category: OperationCategory.setup,
    subtypeName: null,
    referenceStandardMs: null,
  ),
];
