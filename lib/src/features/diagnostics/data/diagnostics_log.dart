import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

/// The evidence channel for a build handed out on a zip and used where nobody
/// is watching (DESIGN.md §10).
///
/// Chronus goes to colleagues who run real studies on their own PCs and report
/// back in words. Words do not carry a stack trace, so this appends one to a
/// file they can send instead: a session header, a thin trail of what they were
/// doing, and every error the app managed to catch.
///
/// Three rules shape it:
///
/// * **Append immediately, never buffer.** The lines worth having are the ones
///   written just before a crash, and a buffer is exactly what a crash
///   discards. Writes are serialised through [_pending] so ordering holds.
/// * **Never throw.** A logger that can break the app is worse than no logger,
///   so every failure here is swallowed. There is nowhere to report it *to*.
/// * **Ids, never text the user typed.** Breadcrumbs carry operation and study
///   ids, not names or notes, so the file stays something a colleague can
///   forward without wondering what else is in it.
class DiagnosticsLog {
  DiagnosticsLog(this._file);

  /// Opens the log in [directory] (the app data directory in the real app; a
  /// temp directory in tests).
  static Future<DiagnosticsLog> open(Directory directory) async {
    return DiagnosticsLog(File(p.join(directory.path, logFileName)));
  }

  static const logFileName = 'log.txt';
  static const feedbackFileName = 'feedback.txt';

  /// Session boundary. Trimming only ever cuts here, so a truncated log still
  /// begins at a header rather than halfway through someone's stack trace.
  static const sessionMarker = '=== session ';

  /// Trim above this, keeping [_keepChars]. Sized so months of ordinary use
  /// fit while the file stays small enough to attach to a message.
  static const _capChars = 1024 * 1024;
  static const _keepChars = 700 * 1024;

  final File _file;

  /// Serialises writes. Not a lock — just a chain, so lines land in order.
  Future<void> _pending = Future<void>.value();

  File get file => _file;

  /// Starts a session: trims if needed, then writes the header.
  ///
  /// The header answers the questions every report otherwise costs a round trip
  /// to ask — which build, which PC, which Windows, which language. Schema and
  /// migration state arrive separately, from the database's own `beforeOpen`,
  /// because the database opens lazily well after this runs.
  Future<void> startSession({required String buildLabel}) async {
    await _trim();
    final now = DateTime.now();
    await _append([
      '',
      '$sessionMarker${_stamp(now)} ===',
      'build   $buildLabel',
      'host    ${_hostname()}',
      'os      ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      'locale  ${Platform.localeName}',
      '---',
    ].join('\n'));
  }

  /// One breadcrumb. Keep [event] a short stable token (`timer.start`,
  /// `route`) and [detail] free of anything the user typed.
  void event(String event, [String? detail]) {
    final line = detail == null ? event : '$event $detail';
    _schedule('${_time(DateTime.now())} $line');
  }

  /// One caught error. [source] says which hook caught it, because that tells
  /// you as much as the error does: a `provider` failure surfaced to the user as
  /// a wall of red text, a `flutter` one may have been invisible.
  void error(String source, Object error, StackTrace? stack) {
    final buffer = StringBuffer('${_time(DateTime.now())} ERROR $source: $error');
    if (stack != null) {
      // Enough frames to place the failure, few enough that a long-running
      // session's log stays readable.
      final frames = stack.toString().trimRight().split('\n');
      for (final frame in frames.take(12)) {
        buffer.write('\n    $frame');
      }
      if (frames.length > 12) buffer.write('\n    ... ${frames.length - 12} more');
    }
    _schedule(buffer.toString());
  }

  /// Everything to hand over in one file: the log, preceded by any feedback the
  /// user typed. Two separate files would mean asking for two, and the one they
  /// forget is whichever you needed.
  Future<String> compose({required String buildLabel}) async {
    final buffer = StringBuffer()
      ..writeln('Chronus diagnostics')
      ..writeln('build     $buildLabel')
      ..writeln('host      ${_hostname()}')
      ..writeln('saved at  ${_stamp(DateTime.now())}')
      ..writeln();

    final feedback = File(p.join(_file.parent.path, feedbackFileName));
    if (await feedback.exists()) {
      buffer
        ..writeln('=== feedback ===')
        ..writeln(await _readSafely(feedback))
        ..writeln();
    }

    buffer.writeln('=== log ===');
    buffer.writeln(await _readSafely(_file));
    return buffer.toString();
  }

  /// Appends a feedback entry, stamped so an entry can be placed against a drop
  /// and a session without the user having to say when it happened.
  Future<void> addFeedback(String text, {required String buildLabel}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final feedback = File(p.join(_file.parent.path, feedbackFileName));
    try {
      await feedback.writeAsString(
        '\n[${_stamp(DateTime.now())}  build $buildLabel]\n$trimmed\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Same rule as the log: losing a note must not break the app.
    }
    event('feedback.saved', '${trimmed.length} chars');
  }

  /// Waits for queued writes to reach disk. For tests, and before composing.
  Future<void> flush() => _pending;

  void _schedule(String line) {
    _pending = _pending.then((_) => _append(line)).catchError((_) {});
  }

  Future<void> _append(String line) async {
    try {
      await _file.writeAsString('$line\n', mode: FileMode.append, flush: true);
    } catch (_) {
      // Disk full, file locked by the user's editor, permissions — none of it is
      // worth taking the app down for, and there is no second channel to
      // complain through.
    }
  }

  /// Keeps the tail, cut at a session boundary. Called once per launch, before
  /// the header, so the file never grows without bound across months of use.
  Future<void> _trim() async {
    try {
      if (!await _file.exists()) return;
      if (await _file.length() <= _capChars) return;
      final content = await _file.readAsString();
      final from = content.length - _keepChars;
      final boundary =
          from > 0 ? content.indexOf(sessionMarker, from) : content.indexOf(sessionMarker);
      // No boundary in the tail means one enormous session; start clean rather
      // than keep a fragment whose beginning is unknowable.
      final kept = boundary >= 0 ? content.substring(boundary) : '';
      await _file.writeAsString(kept, flush: true);
    } catch (_) {
      // A log that cannot be trimmed is still a log.
    }
  }

  Future<String> _readSafely(File file) async {
    try {
      return await file.readAsString();
    } catch (error) {
      return '(could not read ${p.basename(file.path)}: $error)';
    }
  }

  static String _hostname() {
    try {
      return Platform.localHostname;
    } catch (_) {
      return 'unknown';
    }
  }

  static String _stamp(DateTime t) =>
      '${t.year}-${_two(t.month)}-${_two(t.day)} ${_time(t)}';

  static String _time(DateTime t) =>
      '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

  static String _two(int n) => n.toString().padLeft(2, '0');
}
