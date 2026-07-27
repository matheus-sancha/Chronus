import 'dart:math' as math;

/// Statistics across the passes of a Sampling Study, and how many passes the
/// observed variability actually calls for (DESIGN.md §4, §11).
///
/// Pure functions over plain numbers: no database rows, no widgets. The whole
/// point of a sampling study is the numbers, so they are the part that has to be
/// testable in isolation and identical wherever they are shown — screen, PDF or
/// spreadsheet.

/// One operation's spread across the passes that measured it.
class OperationStatistics {
  const OperationStatistics({
    required this.times,
    required this.mean,
    required this.min,
    required this.max,
    required this.standardDeviation,
  });

  /// The measured times that went in, in pass order. Kept so a report can show
  /// what the summary was computed from.
  final List<int> times;

  final double mean;
  final int min;
  final int max;

  /// **Sample** standard deviation (divides by n−1), not the population one.
  ///
  /// These passes are a sample of an ongoing process, never the whole of it, and
  /// the sample-size formula this feeds assumes the same. Null with fewer than
  /// two passes, where spread is not defined rather than zero.
  final double? standardDeviation;

  int get count => times.length;

  int get range => max - min;

  /// Coefficient of variation — spread as a fraction of the mean, so operations
  /// of very different lengths can be compared for consistency. Null when there
  /// is no deviation to divide, or when the mean is zero.
  double? get coefficientOfVariation {
    final sd = standardDeviation;
    if (sd == null || mean == 0) return null;
    return sd / mean;
  }
}

/// Summarises one operation's times. Returns null when nothing was measured —
/// an operation present in the sequence but never timed has no statistics, which
/// is different from having zeroes.
OperationStatistics? statisticsFor(List<int> times) {
  if (times.isEmpty) return null;
  final mean = times.reduce((a, b) => a + b) / times.length;

  double? sd;
  if (times.length >= 2) {
    var sumSquares = 0.0;
    for (final t in times) {
      final d = t - mean;
      sumSquares += d * d;
    }
    sd = math.sqrt(sumSquares / (times.length - 1)); // n-1: sample, not population
  }

  return OperationStatistics(
    times: List.unmodifiable(times),
    mean: mean,
    min: times.reduce(math.min),
    max: times.reduce(math.max),
    standardDeviation: sd,
  );
}

/// Why a sample size could not be computed, so a report can say which rather
/// than showing a blank.
enum SampleSizeUnavailable {
  /// Fewer than two passes: no spread to extrapolate from.
  tooFewPasses,

  /// A zero mean — nothing to express a relative precision against.
  zeroMean,
}

/// How many passes the observed variability calls for, and whether we are there.
class SampleSizeVerdict {
  const SampleSizeVerdict({
    required this.required_,
    required this.have,
    required this.tValue,
    required this.degreesOfFreedom,
    this.unavailable,
  });

  const SampleSizeVerdict.unavailable(this.unavailable, {required this.have})
      : required_ = null,
        tValue = null,
        degreesOfFreedom = null;

  /// Passes needed. Null when [unavailable] says why not.
  final int? required_;

  final int have;

  /// The t value and degrees of freedom the answer came from.
  ///
  /// Shown in the report on purpose: Student's t asks for one to three more
  /// passes than the Z formula in most textbooks, so without these an analyst
  /// checking the tool by hand finds a disagreement and no way to explain it.
  /// With them they can look the value up and see it is right.
  final double? tValue;
  final int? degreesOfFreedom;

  final SampleSizeUnavailable? unavailable;

  /// True when a perfectly consistent operation needs nothing more. Also true
  /// once enough passes exist.
  bool get isAdequate => required_ != null && have >= required_!;
}

/// Passes required for [statistics] at [confidenceLevel] and [relativePrecision].
///
/// Uses **Student's t, solved iteratively** rather than the Z formula found in
/// most cronoanálise texts:
///
///     n(i+1) = ( t(n(i) − 1) · s / (E · x̄) )²
///
/// Z assumes a known population deviation and a large sample; these studies have
/// five to ten passes, where that understates what is needed. The iteration is
/// needed because t depends on the degrees of freedom, which depend on the answer.
///
/// Converges in a handful of rounds in practice. [maxIterations] guards the case
/// where it oscillates between two adjacent values instead of settling, and the
/// larger of the pair is taken — asking for one pass too many is the safe error.
SampleSizeVerdict requiredPasses({
  required OperationStatistics statistics,
  required double confidenceLevel,
  required double relativePrecision,
  int maxIterations = 20,
}) {
  final sd = statistics.standardDeviation;
  if (sd == null) {
    return SampleSizeVerdict.unavailable(
      SampleSizeUnavailable.tooFewPasses,
      have: statistics.count,
    );
  }
  if (statistics.mean == 0) {
    return SampleSizeVerdict.unavailable(
      SampleSizeUnavailable.zeroMean,
      have: statistics.count,
    );
  }

  // A perfectly repeatable operation needs no more evidence than it has. Stated
  // explicitly because the formula would otherwise return zero, which reads as
  // "no passes required" rather than "this one is settled".
  if (sd == 0) {
    final df = statistics.count - 1;
    return SampleSizeVerdict(
      required_: 1,
      have: statistics.count,
      tValue: studentT(confidenceLevel: confidenceLevel, degreesOfFreedom: df),
      degreesOfFreedom: df,
    );
  }

  final tolerance = relativePrecision * statistics.mean;

  int estimate(int from) {
    final df = math.max(1, from - 1);
    final t = studentT(confidenceLevel: confidenceLevel, degreesOfFreedom: df);
    return math.max(1, math.pow(t * sd / tolerance, 2).ceil());
  }

  var n = math.max(2, statistics.count);
  int? previous;
  for (var i = 0; i < maxIterations; i++) {
    final next = estimate(n);
    if (next == n) break;
    if (next == previous) {
      // A two-cycle (…12, 11, 12, 11…) rather than a fixed point: take the
      // larger. Asking for one pass too many is the cheaper error.
      n = math.max(n, next);
      break;
    }
    previous = n;
    n = next;
  }

  // Reported for the answer we landed on, so the figures are self-consistent:
  // an analyst can put this t back into the formula and get this n.
  final df = math.max(1, n - 1);
  return SampleSizeVerdict(
    required_: n,
    have: statistics.count,
    tValue: studentT(confidenceLevel: confidenceLevel, degreesOfFreedom: df),
    degreesOfFreedom: df,
  );
}

/// Two-sided Student's t for the given confidence and degrees of freedom.
///
/// A table rather than a computed inverse CDF: these are the three confidence
/// levels the app offers, the values are exactly the ones printed in the
/// handbooks an analyst will check against, and a table cannot fail to converge.
/// Beyond the tabulated rows t is within a rounding error of z, so the limit is
/// used.
double studentT({
  required double confidenceLevel,
  required int degreesOfFreedom,
}) {
  final (rows, tail) = switch (nearestConfidencePercent(confidenceLevel)) {
    90 => _t90,
    99 => _t99,
    _ => _t95,
  };
  final df = math.max(1, degreesOfFreedom);
  if (df <= 30) return rows[df - 1];
  // 40, 60, 120, then the normal limit — the usual tail of a printed table.
  if (df <= 40) return tail[0];
  if (df <= 60) return tail[1];
  if (df <= 120) return tail[2];
  return tail[3];
}

/// The confidence levels offered, as probabilities.
const supportedConfidenceLevels = [0.90, 0.95, 0.99];

/// Snaps a stored value to a tabulated one, as a whole percent.
///
/// Keyed by percent rather than by the probability itself because a `double`
/// cannot key a const map, and because snapping means a hand-edited or migrated
/// study can never produce a lookup with no table behind it.
int nearestConfidencePercent(double confidenceLevel) {
  var best = supportedConfidenceLevels.first;
  for (final level in supportedConfidenceLevels) {
    if ((level - confidenceLevel).abs() < (best - confidenceLevel).abs()) {
      best = level;
    }
  }
  return (best * 100).round();
}

// Two-sided critical values: rows for df 1..30, then the tail (40, 60, 120, ∞).
// Transcribed from a standard table so the numbers an analyst checks against
// their handbook are the same ones this used.

const _t90 = (
  [
    6.314, 2.920, 2.353, 2.132, 2.015, 1.943, 1.895, 1.860, 1.833, 1.812, //
    1.796, 1.782, 1.771, 1.761, 1.753, 1.746, 1.740, 1.734, 1.729, 1.725, //
    1.721, 1.717, 1.714, 1.711, 1.708, 1.706, 1.703, 1.701, 1.699, 1.697,
  ],
  [1.684, 1.671, 1.658, 1.645],
);

const _t95 = (
  [
    12.706, 4.303, 3.182, 2.776, 2.571, 2.447, 2.365, 2.306, 2.262, 2.228, //
    2.201, 2.179, 2.160, 2.145, 2.131, 2.120, 2.110, 2.101, 2.093, 2.086, //
    2.080, 2.074, 2.069, 2.064, 2.060, 2.056, 2.052, 2.048, 2.045, 2.042,
  ],
  [2.021, 2.000, 1.980, 1.960],
);

const _t99 = (
  [
    63.657, 9.925, 5.841, 4.604, 4.032, 3.707, 3.499, 3.355, 3.250, 3.169, //
    3.106, 3.055, 3.012, 2.977, 2.947, 2.921, 2.898, 2.878, 2.861, 2.845, //
    2.831, 2.819, 2.807, 2.797, 2.787, 2.779, 2.771, 2.763, 2.756, 2.750,
  ],
  [2.704, 2.660, 2.617, 2.576],
);
