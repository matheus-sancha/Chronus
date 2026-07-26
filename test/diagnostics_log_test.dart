import 'dart:io';

import 'package:chronus/src/features/diagnostics/data/diagnostics_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// The log is the only evidence channel for a build handed out on a zip
/// (DESIGN.md §10), so the two things that must hold are: it survives being
/// trimmed, and it never throws.
void main() {
  late Directory dir;
  late DiagnosticsLog log;

  File file(String name) => File(p.join(dir.path, name));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('chronus-log-test');
    log = await DiagnosticsLog.open(dir);
  });
  tearDown(() => dir.delete(recursive: true));

  test('a session header records the build, then events append under it',
      () async {
    await log.startSession(buildLabel: '2026-07-27');
    log.event('timer.start', 'op=1234abcd');
    log.error('provider studyOps', 'SqliteException(5)', StackTrace.current);
    await log.flush();

    final text = await file(DiagnosticsLog.logFileName).readAsString();
    expect(text, contains('=== session '));
    expect(text, contains('build   2026-07-27'));
    expect(text, contains('timer.start op=1234abcd'));
    expect(text, contains('ERROR provider studyOps: SqliteException(5)'));
    // Events land after the header they belong to.
    expect(text.indexOf('timer.start'),
        greaterThan(text.indexOf('=== session ')));
  });

  test('trimming cuts at a session boundary, never mid-stack', () async {
    // Three sessions, the first two padded past the 1 MB cap.
    final target = file(DiagnosticsLog.logFileName);
    final filler = 'x' * 600 * 1024;
    for (final label in ['old', 'middle']) {
      await log.startSession(buildLabel: label);
      log.event('pad', filler);
      await log.flush();
    }
    expect(await target.length(), greaterThan(1024 * 1024));

    await log.startSession(buildLabel: 'current');
    await log.flush();

    final text = await target.readAsString();
    expect(text, contains('build   current'));
    expect(text, isNot(contains('build   old')));
    // Whatever survived starts at a header, so the file is still parseable.
    expect(text.trimLeft(), startsWith(DiagnosticsLog.sessionMarker));
  });

  test('feedback is stamped and travels with the composed diagnostics',
      () async {
    await log.startSession(buildLabel: '2026-07-27');
    await log.addFeedback('  a tabela fica pequena  ',
        buildLabel: '2026-07-27');
    await log.flush();

    final composed = await log.compose(buildLabel: '2026-07-27');
    expect(composed, contains('=== feedback ==='));
    expect(composed, contains('a tabela fica pequena'));
    expect(composed, contains('build 2026-07-27'));
    expect(composed, contains('=== log ==='));
    // One file to ask for: the log is in there too.
    expect(composed, contains('feedback.saved'));
  });

  test('blank feedback is not recorded', () async {
    await log.addFeedback('   \n  ', buildLabel: '2026-07-27');
    await log.flush();
    expect(await file(DiagnosticsLog.feedbackFileName).exists(), isFalse);
  });

  test('an unwritable log never throws at its caller', () async {
    // A directory where the log file should be: every write fails, which stands
    // in for the disk-full and file-locked cases that do happen on a shop floor.
    final blocked = await Directory.systemTemp.createTemp('chronus-log-blocked');
    await Directory(p.join(blocked.path, DiagnosticsLog.logFileName)).create();
    final broken = await DiagnosticsLog.open(blocked);

    await expectLater(broken.startSession(buildLabel: 'x'), completes);
    broken.event('timer.start', 'op=1');
    broken.error('flutter', 'boom', StackTrace.current);
    await expectLater(broken.flush(), completes);
    // Composing still yields something to send, saying what it could not read.
    expect(await broken.compose(buildLabel: 'x'), contains('could not read'));

    await blocked.delete(recursive: true);
  });
}
