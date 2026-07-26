import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/build_info.dart';
import '../../../data/app_directory.dart';
import '../data/diagnostics_log.dart';

/// Static entry point to the diagnostics log.
///
/// Deliberately not a Riverpod provider. The error hooks have to be installed
/// in `main()` before a `ProviderScope` exists, the database's `beforeOpen`
/// runs outside the widget tree, and repositories would otherwise all need a
/// log threaded through their constructors to record a breadcrumb. A static
/// facade keeps every call site one line.
///
/// It also means the log is **absent unless installed**, so `flutter test`
/// writes no files and needs no setup: every method here is a no-op until
/// [install] has run.
abstract final class Diag {
  static DiagnosticsLog? _log;

  static DiagnosticsLog? get log => _log;

  /// Opens the log, starts a session, and routes the three error channels into
  /// it. Call once, early in `main()`.
  ///
  /// Never throws: a PC where the log cannot be opened must still run the app.
  static Future<void> install() async {
    try {
      final dir = await appDataDirectory();
      await dir.create(recursive: true);
      final log = await DiagnosticsLog.open(dir);
      await log.startSession(buildLabel: kBuildLabel);
      _log = log;
    } catch (_) {
      return; // No log. Everything below stays a no-op.
    }

    // 1. Framework errors (build/layout/paint). Chained rather than replaced,
    //    so the debug console still shows them during development.
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      _log?.error('flutter', details.exception, details.stack);
      previous?.call(details);
    };

    // 2. Uncaught async errors outside the framework. Preferred over
    //    runZonedGuarded: no zone mismatch with ensureInitialized, and it
    //    catches what the framework's own zone would miss.
    PlatformDispatcher.instance.onError = (error, stack) {
      _log?.error('platform', error, stack);
      return true; // Handled — reported here rather than killing the isolate.
    };
  }

  static void event(String event, [String? detail]) => _log?.event(event, detail);

  static void error(String source, Object error, StackTrace? stack) =>
      _log?.error(source, error, stack);

  /// Shortens a uuid for a breadcrumb. Full uuids make the log unreadable, and
  /// eight hex characters are plenty to correlate lines within one session.
  static String shortId(String id) => id.length <= 8 ? id : id.substring(0, 8);

  @visibleForTesting
  static void installForTest(DiagnosticsLog? log) => _log = log;
}

/// The third error channel, and the one that matters most here.
///
/// Ten screens render a failed async provider as `Center(child: Text('$error'))`
/// — so a repository that throws shows the user a wall of `SqliteException` and
/// never touches `FlutterError.onError`. Without this observer the diagnostics
/// log would miss the failure class the users are most likely to actually hit.
final class DiagnosticsObserver extends ProviderObserver {
  const DiagnosticsObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final name = context.provider.name ?? context.provider.runtimeType.toString();
    Diag.error('provider $name', error, stackTrace);
  }
}
