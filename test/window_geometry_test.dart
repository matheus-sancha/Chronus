import 'dart:ui';

import 'package:chronus/src/app/window_geometry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_retriever/screen_retriever.dart';

/// The interesting part of window geometry is the offscreen check: get it wrong
/// and a laptop undocked from a second monitor opens a window nobody can reach,
/// which is indistinguishable from the app failing to launch.
Display _display({
  required double left,
  required double top,
  required double width,
  required double height,
}) =>
    Display(
      id: '$left,$top',
      size: Size(width, height),
      visiblePosition: Offset(left, top),
      visibleSize: Size(width, height),
    );

WindowGeometry _at(Rect bounds, {bool maximized = false}) =>
    WindowGeometry(bounds: bounds, maximized: maximized);

void main() {
  // A laptop screen, plus a monitor to its right — the setup that causes the bug.
  final laptop = _display(left: 0, top: 0, width: 1920, height: 1080);
  final external = _display(left: 1920, top: 0, width: 2560, height: 1440);

  group('isOnSomeDisplay', () {
    test('a window on the primary display is usable', () {
      expect(
        _at(const Rect.fromLTWH(100, 100, 1200, 800)).isOnSomeDisplay([laptop]),
        isTrue,
      );
    });

    test('a window on a second display is usable while it is attached', () {
      final geometry = _at(const Rect.fromLTWH(2200, 300, 1200, 800));
      expect(geometry.isOnSomeDisplay([laptop, external]), isTrue);
      // Undocked: the same position is now nowhere.
      expect(geometry.isOnSomeDisplay([laptop]), isFalse);
    });

    test('a window straddling two displays is kept', () {
      // Users park windows across a seam deliberately; that is not a fault.
      expect(
        _at(const Rect.fromLTWH(1600, 200, 1200, 800))
            .isOnSomeDisplay([laptop, external]),
        isTrue,
      );
    });

    test('hanging slightly off an edge is kept, since it can still be grabbed',
        () {
      expect(
        _at(const Rect.fromLTWH(1700, 900, 1200, 800)).isOnSomeDisplay([laptop]),
        isTrue,
      );
    });

    test('a sliver too small to grab is rejected', () {
      // 50px of width left on screen: not enough title bar to drag it back.
      expect(
        _at(const Rect.fromLTWH(1870, 400, 1200, 800)).isOnSomeDisplay([laptop]),
        isFalse,
      );
    });

    test('a window off the top is rejected even when horizontally on screen',
        () {
      // Dragged under the top edge, its title bar is unreachable.
      expect(
        _at(const Rect.fromLTWH(400, -790, 1200, 800)).isOnSomeDisplay([laptop]),
        isFalse,
      );
    });

    test('no displays at all is not usable', () {
      expect(
        _at(const Rect.fromLTWH(100, 100, 1200, 800)).isOnSomeDisplay([]),
        isFalse,
      );
    });

    test('a display reporting no visible area falls back to its full size', () {
      final bare = Display(id: 'bare', size: const Size(1920, 1080));
      expect(
        _at(const Rect.fromLTWH(100, 100, 1200, 800)).isOnSomeDisplay([bare]),
        isTrue,
      );
    });
  });

  group('serialisation', () {
    test('round-trips bounds and the maximised flag', () {
      final original =
          _at(const Rect.fromLTWH(12, 34, 1600, 1000), maximized: true);
      final restored = WindowGeometry.fromJson(original.toJson());

      expect(restored, isNotNull);
      expect(restored!.bounds, original.bounds);
      expect(restored.maximized, isTrue);
    });

    test('a maximised window still records the frame to unmaximise into', () {
      // The flag and the bounds are independent on purpose: storing the screen
      // rect while maximised would lose the user's layout the moment they
      // unmaximise.
      final restored = WindowGeometry.fromJson(
          _at(const Rect.fromLTWH(200, 150, 1300, 900), maximized: true)
              .toJson())!;
      expect(restored.bounds, const Rect.fromLTWH(200, 150, 1300, 900));
    });

    test('an incomplete or foreign json is rejected rather than half-applied',
        () {
      expect(WindowGeometry.fromJson({'left': 0, 'top': 0}), isNull);
      expect(WindowGeometry.fromJson({}), isNull);
      expect(
        WindowGeometry.fromJson(
            {'left': 'x', 'top': 0, 'width': 100, 'height': 100}),
        isNull,
      );
    });

    test('integers from a hand-edited file are accepted', () {
      final restored = WindowGeometry.fromJson(
          {'left': 10, 'top': 20, 'width': 800, 'height': 600})!;
      expect(restored.bounds, const Rect.fromLTWH(10, 20, 800, 600));
      expect(restored.maximized, isFalse);
    });
  });
}
