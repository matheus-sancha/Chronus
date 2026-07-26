import 'package:chronus/src/features/analysis/application/sampling_statistics.dart';
import 'package:flutter_test/flutter_test.dart';

/// These numbers are the deliverable of a Sampling Study, and an engineer will
/// check them against a handbook. So the tests pin actual values rather than
/// asserting vague properties.
void main() {
  group('operation statistics', () {
    test('mean, min, max and range over the measured passes', () {
      final s = statisticsFor([10000, 12000, 11000, 13000])!;
      expect(s.count, 4);
      expect(s.mean, 11500);
      expect(s.min, 10000);
      expect(s.max, 13000);
      expect(s.range, 3000);
    });

    test('standard deviation divides by n-1, not n', () {
      // 2, 4, 4, 4, 5, 5, 7, 9 has population sd 2 and sample sd 2.13809…
      // These passes are a sample of an ongoing process, never all of it.
      final s = statisticsFor([2, 4, 4, 4, 5, 5, 7, 9])!;
      expect(s.mean, 5);
      expect(s.standardDeviation, closeTo(2.13809, 0.00001));
    });

    test('one pass has no deviation, which is not the same as zero', () {
      final s = statisticsFor([12000])!;
      expect(s.count, 1);
      expect(s.mean, 12000);
      expect(s.range, 0);
      // Null, not 0: with one measurement spread is undefined, and reporting 0
      // would claim perfect consistency from a single observation.
      expect(s.standardDeviation, isNull);
      expect(s.coefficientOfVariation, isNull);
    });

    test('identical passes really do have zero deviation', () {
      final s = statisticsFor([9000, 9000, 9000])!;
      expect(s.standardDeviation, 0);
      expect(s.coefficientOfVariation, 0);
    });

    test('coefficient of variation is spread relative to the mean', () {
      final s = statisticsFor([9000, 11000])!;
      // sd = 1414.21…, mean = 10000
      expect(s.coefficientOfVariation, closeTo(0.14142, 0.00001));
    });

    test('an operation never timed has no statistics at all', () {
      // Distinct from an operation measured as zero.
      expect(statisticsFor(const []), isNull);
    });
  });

  group("Student's t table", () {
    test('matches the printed two-sided values', () {
      // The rows an analyst is most likely to look up.
      expect(studentT(confidenceLevel: 0.95, degreesOfFreedom: 1), 12.706);
      expect(studentT(confidenceLevel: 0.95, degreesOfFreedom: 5), 2.571);
      expect(studentT(confidenceLevel: 0.95, degreesOfFreedom: 11), 2.201);
      expect(studentT(confidenceLevel: 0.95, degreesOfFreedom: 30), 2.042);
      expect(studentT(confidenceLevel: 0.90, degreesOfFreedom: 9), 1.833);
      expect(studentT(confidenceLevel: 0.99, degreesOfFreedom: 4), 4.604);
    });

    test('past the table it falls back through 40, 60, 120 to the z limit', () {
      expect(studentT(confidenceLevel: 0.95, degreesOfFreedom: 35), 2.021);
      expect(studentT(confidenceLevel: 0.95, degreesOfFreedom: 60), 2.000);
      expect(studentT(confidenceLevel: 0.95, degreesOfFreedom: 100), 1.980);
      // The normal limit — 1,96 at 95 %, as every textbook has it.
      expect(studentT(confidenceLevel: 0.95, degreesOfFreedom: 5000), 1.960);
    });

    test('an unsupported confidence snaps to the nearest tabulated one', () {
      // A hand-edited or migrated study cannot produce a lookup with no table.
      expect(nearestConfidencePercent(0.94), 95);
      expect(nearestConfidencePercent(0.91), 90);
      expect(nearestConfidencePercent(0.999), 99);
      expect(studentT(confidenceLevel: 0.94, degreesOfFreedom: 5), 2.571);
    });

    test('degrees of freedom below one are clamped rather than throwing', () {
      expect(studentT(confidenceLevel: 0.95, degreesOfFreedom: 0), 12.706);
      expect(studentT(confidenceLevel: 0.95, degreesOfFreedom: -3), 12.706);
    });
  });

  group('required passes', () {
    test('a consistent operation is already adequate', () {
      // sd 1414 on a mean of 10 000 is 14 % variation; at ±5 % that needs more.
      final verdict = requiredPasses(
        statistics: statisticsFor([9000, 11000])!,
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
      );
      expect(verdict.isAdequate, isFalse);
      expect(verdict.have, 2);
      expect(verdict.required_, greaterThan(2));
    });

    test('the reported t and df reproduce the reported n', () {
      final stats = statisticsFor([10000, 12000, 11000, 13000, 11500])!;
      final verdict = requiredPasses(
        statistics: stats,
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
      );

      // The whole reason t and df are surfaced: an analyst puts them back into
      // n = (t·s/(E·x̄))² and must get the same answer.
      final tolerance = 0.05 * stats.mean;
      final recomputed =
          (verdict.tValue! * stats.standardDeviation! / tolerance);
      expect((recomputed * recomputed).ceil(), verdict.required_);
      expect(verdict.degreesOfFreedom, verdict.required_! - 1);
    });

    test('Student\'s t asks for at least as many passes as z would', () {
      final stats = statisticsFor([10000, 12000, 11000, 13000, 11500])!;
      final verdict = requiredPasses(
        statistics: stats,
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
      );
      // The z answer, for comparison: 1,96 rather than a t of ~2,1-2,3.
      final tolerance = 0.05 * stats.mean;
      final zAnswer = (1.960 * stats.standardDeviation! / tolerance);
      expect(verdict.required_,
          greaterThanOrEqualTo((zAnswer * zAnswer).ceil()));
    });

    test('a perfectly repeatable operation needs one pass, not zero', () {
      final verdict = requiredPasses(
        statistics: statisticsFor([9000, 9000, 9000])!,
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
      );
      // The formula would give 0, which reads as "no passes required" instead of
      // "this one is settled".
      expect(verdict.required_, 1);
      expect(verdict.isAdequate, isTrue);
      expect(verdict.tValue, isNotNull);
    });

    test('one pass cannot say how many are needed, and says why', () {
      final verdict = requiredPasses(
        statistics: statisticsFor([12000])!,
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
      );
      expect(verdict.unavailable, SampleSizeUnavailable.tooFewPasses);
      expect(verdict.required_, isNull);
      expect(verdict.isAdequate, isFalse);
      expect(verdict.have, 1);
    });

    test('a zero mean is reported as such rather than dividing by it', () {
      final verdict = requiredPasses(
        statistics: statisticsFor([0, 0])!,
        confidenceLevel: 0.95,
        relativePrecision: 0.05,
      );
      // sd is 0 here too, but a zero mean has no relative precision to speak of,
      // so that check has to come first.
      expect(verdict.unavailable, SampleSizeUnavailable.zeroMean);
    });

    test('looser precision needs fewer passes, tighter needs more', () {
      final stats = statisticsFor([10000, 12000, 11000, 13000])!;
      int need(double precision) => requiredPasses(
            statistics: stats,
            confidenceLevel: 0.95,
            relativePrecision: precision,
          ).required_!;

      expect(need(0.10), lessThan(need(0.05)));
      expect(need(0.05), lessThan(need(0.02)));
    });

    test('higher confidence needs more passes', () {
      final stats = statisticsFor([10000, 12000, 11000, 13000])!;
      int need(double confidence) => requiredPasses(
            statistics: stats,
            confidenceLevel: confidence,
            relativePrecision: 0.05,
          ).required_!;

      expect(need(0.90), lessThan(need(0.95)));
      expect(need(0.95), lessThan(need(0.99)));
    });

    test('a wildly variable operation terminates instead of looping', () {
      // Huge spread drives n up, where t barely moves — the iteration has to
      // settle rather than chase itself.
      final verdict = requiredPasses(
        statistics: statisticsFor([1000, 90000, 5000, 120000])!,
        confidenceLevel: 0.99,
        relativePrecision: 0.02,
      );
      expect(verdict.required_, isNotNull);
      expect(verdict.required_, greaterThan(100));
      expect(verdict.isAdequate, isFalse);
    });
  });
}
