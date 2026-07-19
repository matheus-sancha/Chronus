// Enum types stored in the database as their `.name` (via Drift `textEnum`),
// so persisted values stay stable regardless of declaration order.

/// Fixed top-level classification categories. Reports roll up by these and they
/// are NOT user-editable. Subtypes live within one of these.
enum OperationCategory { setup, productive, unproductive }

/// The two study types, chosen at creation. A Time Study has exactly one
/// observation; a Sampling Study has many.
enum StudyType { timeStudy, samplingStudy }

/// What a media attachment hangs off (polymorphic owner).
enum MediaOwnerType { study, observation, operationInstance }

/// Media kind. Photos embed into PDF/XLSX exports; video is in-app only.
enum MediaKind { photo, video }

/// Entry/display unit for durations. (Reports always use the dynamic
/// HH:MM:SS.D format regardless of this setting.)
enum TimeUnit { seconds, decimalMinutes }
