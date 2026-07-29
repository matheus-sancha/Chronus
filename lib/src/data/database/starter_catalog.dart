import 'enums.dart';

/// The operations a colleague finds in the catalog on first run (DESIGN.md §9).
///
/// **This list is the one piece of Chronus that is specific to the people using
/// it.** §3.7 originally shipped nothing, on the reasoning that generic starter
/// content is noise — which was right when the audience was the App Store. §6
/// made Windows internal-only, and for one known company the content can be
/// exactly right rather than merely plausible. The Process Type picklist in
/// `database.dart` already works this way; this is the same decision applied to
/// the thing that actually blocks a first study.
///
/// Keep it short. The point is to get someone from a cold install to a running
/// stopwatch without an hour of typing, not to model the whole shop. Anything
/// missing is one "add operation" away, and the first person to build a real
/// sequence turns it into a template for everyone else.
///
/// Referenced by **subtype name**, not id: the 7 wastes are seeded with
/// generated ids, and on an upgrade they already exist with ids this file
/// cannot know.
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
const starterCatalog = <StarterOperation>[
  // --- setup ---------------------------------------------------------------
  (
    name: 'Preparar máquina',
    category: OperationCategory.setup,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Posicionar peça no dispositivo',
    category: OperationCategory.setup,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Trocar ferramenta',
    category: OperationCategory.setup,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  // --- productive ----------------------------------------------------------
  (
    name: 'Usinagem',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Soldagem',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Revestimento (cladding)',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Dobra',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Montagem',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Rebarbação / acabamento',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Inspeção dimensional',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  (
    name: 'Retirar peça',
    category: OperationCategory.productive,
    subtypeName: null,
    referenceStandardMs: null,
  ),
  // --- the waste an analyst reaches for mid-run ----------------------------
  // These exist so the §3.5 "log this interruption" flow has something to pick
  // without stopping to author an operation while the line is waiting.
  (
    name: 'Aguardando material',
    category: OperationCategory.unproductive,
    subtypeName: 'Waiting',
    referenceStandardMs: null,
  ),
  (
    name: 'Aguardando ponte rolante',
    category: OperationCategory.unproductive,
    subtypeName: 'Waiting',
    referenceStandardMs: null,
  ),
  (
    name: 'Movimentação de peça',
    category: OperationCategory.unproductive,
    subtypeName: 'Transportation',
    referenceStandardMs: null,
  ),
  (
    name: 'Retrabalho',
    category: OperationCategory.unproductive,
    subtypeName: 'Defects',
    referenceStandardMs: null,
  ),
];
