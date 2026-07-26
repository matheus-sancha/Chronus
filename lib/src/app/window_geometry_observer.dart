import 'dart:async';
import 'dart:ui';

import 'package:window_manager/window_manager.dart';

import '../features/diagnostics/application/diagnostics.dart';
import 'window_geometry.dart';

/// Persists the window's geometry as the user changes it.
///
/// Register once, for the life of the process, seeding it with the frame the
/// window started at:
/// ```dart
/// final observer = WindowGeometryObserver();
/// windowManager.addListener(observer);
/// observer.rememberNormalBounds(await WindowGeometry.restore());
/// ```
class WindowGeometryObserver extends WindowListener {
  WindowGeometryObserver({this.debounce = const Duration(milliseconds: 500)});

  final Duration debounce;
  Timer? _timer;

  /// The last frame seen while *not* maximised.
  ///
  /// Kept in memory because a maximised window's bounds are the screen, and
  /// storing that would mean unmaximising later restores to the whole screen —
  /// the user's layout quietly lost. Seeded at startup so it is never null when
  /// the very first thing a user does is maximise, which is the common case this
  /// whole feature exists for.
  Rect? _normalBounds;

  /// Avoids rewriting an identical file on every window blur.
  WindowGeometry? _written;

  void rememberNormalBounds(Rect bounds) => _normalBounds = bounds;

  @override
  void onWindowResize() => _schedule();

  @override
  void onWindowResized() => _schedule();

  @override
  void onWindowMove() => _schedule();

  @override
  void onWindowMoved() => _schedule();

  @override
  void onWindowMaximize() => _schedule();

  @override
  void onWindowUnmaximize() => _schedule();

  /// Losing focus is the catch-all, and it is not redundant.
  ///
  /// The plugin only emits move/resize from `WM_MOVING`/`WM_SIZING`, which
  /// Windows sends during an **interactive drag**. Snapping a window (Win+Arrow,
  /// or dragging to a screen edge) resizes it via `SetWindowPos` and emits
  /// nothing at all — so without this, a snapped layout would never be
  /// remembered. Switching away from the app catches it.
  @override
  void onWindowBlur() => _schedule();

  /// Written immediately rather than debounced: there is no later.
  @override
  void onWindowClose() {
    _timer?.cancel();
    _persist();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(debounce, _persist);
  }

  Future<void> _persist() async {
    try {
      final maximized = await windowManager.isMaximized();
      if (!maximized) _normalBounds = await windowManager.getBounds();
      final bounds = _normalBounds;
      if (bounds == null) return; // Not seeded yet; nothing trustworthy to write.

      final geometry = WindowGeometry(bounds: bounds, maximized: maximized);
      if (_written != null &&
          _written!.bounds == geometry.bounds &&
          _written!.maximized == geometry.maximized) {
        return;
      }
      await geometry.save();
      _written = geometry;
    } catch (error, stack) {
      Diag.error('window.persist', error, stack);
    }
  }
}
