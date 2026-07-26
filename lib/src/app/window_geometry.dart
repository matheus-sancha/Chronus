import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:path/path.dart' as p;
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import '../data/app_directory.dart';
import '../features/diagnostics/application/diagnostics.dart';

/// Remembers where the window was, and puts it back (DESIGN.md §10).
///
/// Windows does not remember a window's size, position or maximised state for an
/// application — the app must. Without this every launch opens at the hardcoded
/// 1280×720 at (10, 10) from `windows/runner/main.cpp` and begins with a manual
/// maximise, several times a day, for months.
///
/// Stored as a small json file beside the database rather than in `AppSettings`:
/// window chrome is not domain state, and it would otherwise mean a schema
/// migration every time a field is added to it.
class WindowGeometry {
  const WindowGeometry({required this.bounds, required this.maximized});

  /// The window's frame in logical pixels, as last seen unmaximised. Kept even
  /// when [maximized] is true, so unmaximising restores somewhere sensible
  /// rather than the default.
  final Rect bounds;
  final bool maximized;

  static const fileName = 'window.json';

  /// Below this the timing table cannot lay out its columns, so the window
  /// refuses to go smaller rather than presenting an unusable workspace.
  static const minimumSize = Size(900, 600);

  /// Used on a first run, and whenever a stored position no longer lands on a
  /// display that exists.
  static const defaultSize = Size(1600, 1000);

  /// How much of the window must overlap a display for the position to be
  /// considered usable. A title bar's worth: enough to grab and drag.
  static const _minimumVisible = Size(200, 40);

  Map<String, Object?> toJson() => {
        'left': bounds.left,
        'top': bounds.top,
        'width': bounds.width,
        'height': bounds.height,
        'maximized': maximized,
      };

  static WindowGeometry? fromJson(Map<String, Object?> json) {
    // Type-tested rather than cast: this file is plain text in a folder the
    // readme tells users to open, so a hand-edited value has to be *rejected*,
    // not thrown on.
    double? number(String key) {
      final value = json[key];
      return value is num ? value.toDouble() : null;
    }

    final left = number('left');
    final top = number('top');
    final width = number('width');
    final height = number('height');
    if (left == null || top == null || width == null || height == null) {
      return null;
    }
    return WindowGeometry(
      bounds: Rect.fromLTWH(left, top, width, height),
      maximized: json['maximized'] == true,
    );
  }

  static Future<File> _file() async =>
      File(p.join((await appDataDirectory()).path, fileName));

  static Future<WindowGeometry?> load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return null;
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;
      return fromJson(decoded.cast<String, Object?>());
    } catch (error, stack) {
      // A corrupt or unreadable geometry file must never stop the app from
      // opening — it just opens where it would have before.
      Diag.error('window.load', error, stack);
      return null;
    }
  }

  Future<void> save() async {
    try {
      await (await _file()).writeAsString(jsonEncode(toJson()), flush: true);
    } catch (error, stack) {
      Diag.error('window.save', error, stack);
    }
  }

  /// Whether [bounds] still lands on a display that exists.
  ///
  /// This is the check that stops a laptop undocked from a second monitor
  /// opening entirely offscreen — where the window is unreachable and the app
  /// looks like it failed to launch. Only a corner needs to be reachable, so a
  /// window straddling two displays or hanging slightly off an edge is still
  /// accepted; users park windows like that deliberately.
  bool isOnSomeDisplay(List<Display> displays) {
    for (final display in displays) {
      final origin = display.visiblePosition ?? Offset.zero;
      final size = display.visibleSize ?? display.size;
      final screen = Rect.fromLTWH(
          origin.dx, origin.dy, size.width, size.height);
      final overlap = screen.intersect(bounds);
      if (overlap.width >= _minimumVisible.width &&
          overlap.height >= _minimumVisible.height) {
        return true;
      }
    }
    return false;
  }

  /// Applies saved geometry, or sensible defaults.
  ///
  /// **Deliberately does not show the window.** `windows/runner/win32_window.cpp`
  /// creates it without `WS_VISIBLE`, and `flutter_window.cpp` shows it from the
  /// first-frame callback — so it is already hidden while this runs, and already
  /// revealed only once there is something painted to see. Calling
  /// `windowManager.show()` here would reveal an *empty* window a moment early,
  /// which is the very flash this is meant to avoid. Do not add it back.
  /// Returns the unmaximised frame the window ended up with, for
  /// [WindowGeometryObserver.rememberNormalBounds].
  static Future<Rect> restore() async {
    final saved = await load();
    final options = WindowOptions(
      size: saved?.bounds.size ?? defaultSize,
      minimumSize: minimumSize,
      center: saved == null,
    );

    // No callback: `waitUntilReadyToShow` invokes it *without awaiting*, so
    // anything asynchronous inside races the caller — the reason an earlier
    // version of this returned a frame that had not been read yet. Awaiting the
    // options pass and then doing the rest inline is deterministic.
    await windowManager.waitUntilReadyToShow(options);

    var normal = saved?.bounds;
    if (saved != null) {
      var usable = true;
      try {
        usable = saved.isOnSomeDisplay(await screenRetriever.getAllDisplays());
      } catch (error, stack) {
        // If the displays cannot be enumerated, trust the saved position rather
        // than second-guessing it: being wrong here costs a window in an odd
        // place, and refusing costs the user their layout every launch.
        Diag.error('window.displays', error, stack);
      }
      if (usable) {
        await windowManager.setBounds(saved.bounds);
      } else {
        Diag.event('window.offscreen', 'ignoring saved position');
        await windowManager.setSize(defaultSize);
        await windowManager.center();
        normal = null; // Recaptured below, wherever centring landed.
      }
    }
    // Read back before maximising — while maximised, getBounds() is the screen.
    normal ??= await windowManager.getBounds();
    if (saved?.maximized ?? false) await windowManager.maximize();
    return normal;
  }
}
