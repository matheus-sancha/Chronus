// Chronus — Stopwatch Spike (throwaway prototype)
//
// Purpose: validate the ONE riskiest assumption in the whole project —
// does the live time-study stopwatch feel right in a technician's hand,
// one-handed, with rapid taps, on a real (noisy) floor?
//
// This is deliberately NOT the product. It has no projects, catalog,
// persistence, or polish. It implements only the core interaction from
// docs/DESIGN.md:
//   - continuous, absolute-timestamp timing (end of one op == start of next)
//   - a single large lap-advance button
//   - insert an unplanned waste operation mid-run without disturbing the
//     remaining preset sequence
//   - a raw results list, times shown in the dynamic HH:MM:SS.D format
//
// Everything here is meant to be thrown away — but it's written in Flutter
// (the real stack) so the timing logic and formatter carry forward.

import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const SpikeApp());

// --- Domain (minimal) -------------------------------------------------------

enum Category { setup, productive, waste }

extension CategoryUi on Category {
  String get label => switch (this) {
        Category.setup => 'Setup',
        Category.productive => 'Value-added',
        Category.waste => 'Waste',
      };
  Color get color => switch (this) {
        Category.setup => const Color(0xFFFFB300), // amber
        Category.productive => const Color(0xFF43A047), // green
        Category.waste => const Color(0xFFE53935), // red
      };
}

/// One timed segment. Times are captured as absolute wall-clock timestamps so
/// the record survives backgrounding / lock and durations are exact.
class Segment {
  Segment({
    required this.name,
    required this.category,
    required this.start,
    this.unplanned = false,
  });

  final String name;
  final Category category;
  final bool unplanned;
  final DateTime start;
  DateTime? end;

  bool get isOpen => end == null;
  Duration get duration => (end ?? DateTime.now()).difference(start);
}

/// The preset operation sequence for the spike (hard-coded stand-in for what
/// would come from a catalog/template in the real app).
const List<({String name, Category category})> _preset = [
  (name: 'Load fixture', category: Category.setup),
  (name: 'Machine part', category: Category.productive),
  (name: 'Deburr edge', category: Category.productive),
  (name: 'Inspect', category: Category.productive),
  (name: 'Unload', category: Category.productive),
];

const List<String> _wastes = [
  'Waiting',
  'Motion',
  'Transportation',
  'Over-processing',
  'Overproduction',
  'Inventory',
  'Defects',
];

/// Dynamic HH:MM:SS.D formatter — tenths of a second, leading empty units
/// collapsed (e.g. 4.3 / 1:15.2 / 1:02:05.4). Matches docs/DESIGN.md §7.
String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  final ds = (d.inMilliseconds % 1000) ~/ 100; // one decisecond
  String two(int n) => n.toString().padLeft(2, '0');
  if (h > 0) return '$h:${two(m)}:${two(s)}.$ds';
  if (m > 0) return '$m:${two(s)}.$ds';
  return '$s.$ds';
}

// --- App --------------------------------------------------------------------

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronus Stopwatch Spike',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        brightness: Brightness.dark, // high-contrast, easy on battery on-floor
      ),
      home: const StudyScreen(),
    );
  }
}

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});
  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final List<Segment> _segments = [];
  int _presetIndex = 0; // index of the next preset op to start
  Segment? _current; // currently open segment
  bool _finished = false;
  Timer? _ticker; // display-only refresh; real times come from timestamps

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  String? get _nextPresetName =>
      _presetIndex < _preset.length ? _preset[_presetIndex].name : null;

  bool get _running => _current != null;

  // --- Actions --------------------------------------------------------------

  void _startStudy() {
    setState(() {
      _segments.clear();
      _presetIndex = 0;
      _finished = false;
      _openNextPreset(DateTime.now());
    });
    _startTicker();
  }

  void _openNextPreset(DateTime at) {
    if (_presetIndex >= _preset.length) {
      _finish(at);
      return;
    }
    final op = _preset[_presetIndex];
    _presetIndex++;
    final seg = Segment(name: op.name, category: op.category, start: at);
    _segments.add(seg);
    _current = seg;
  }

  /// Lap: close the current op and open the next preset op at the SAME instant
  /// (continuous timing — no gap between operations).
  void _lap() {
    if (_current == null) return;
    final now = DateTime.now();
    setState(() {
      _current!.end = now;
      _openNextPreset(now);
    });
  }

  /// Insert an unplanned waste op mid-run. Does NOT advance the preset index,
  /// so the preset sequence resumes on the next lap.
  void _insertUnplanned(String waste) {
    final now = DateTime.now();
    setState(() {
      _current?.end = now;
      final seg = Segment(
        name: waste,
        category: Category.waste,
        start: now,
        unplanned: true,
      );
      _segments.add(seg);
      _current = seg;
    });
  }

  void _finish(DateTime at) {
    _current?.end = at;
    _current = null;
    _finished = true;
    _stopTicker();
  }

  void _finishNow() => setState(() => _finish(DateTime.now()));

  void _reset() {
    _stopTicker();
    setState(() {
      _segments.clear();
      _presetIndex = 0;
      _current = null;
      _finished = false;
    });
  }

  Future<void> _pickUnplanned() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Insert unplanned waste',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            for (final w in _wastes)
              ListTile(
                leading: Icon(Icons.circle, color: Category.waste.color),
                title: Text(w, style: const TextStyle(fontSize: 18)),
                onTap: () => Navigator.pop(ctx, w),
              ),
          ],
        ),
      ),
    );
    if (choice != null) _insertUnplanned(choice);
  }

  // --- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chronus · Stopwatch Spike'),
        actions: [
          if (_segments.isNotEmpty || _finished)
            IconButton(
              tooltip: 'Reset',
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
            ),
        ],
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_finished) return _summaryView();
    if (!_running) return _idleView();
    return _runningView();
  }

  Widget _idleView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text('Preset sequence',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < _preset.length; i++)
                  ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(_preset[i].name),
                    trailing: _categoryChip(_preset[i].category),
                  ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _startStudy,
            icon: const Icon(Icons.play_arrow, size: 28),
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(72)),
            label: const Text('START STUDY',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _runningView() {
    final cur = _current!;
    final next = _nextPresetName;
    return Column(
      children: [
        // Live current-operation panel.
        Container(
          width: double.infinity,
          color: cur.category.color.withOpacity(0.15),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (cur.unplanned) ...[
                    const Icon(Icons.warning_amber, size: 18),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      cur.name,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _categoryChip(cur.category),
              const SizedBox(height: 12),
              Text(
                formatDuration(cur.duration),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        // The one big primary action.
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _lap,
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(96)),
            child: Text(
              next != null ? 'END & START:\n$next' : 'END FINAL OPERATION',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickUnplanned,
                  icon: const Icon(Icons.add_alert),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56)),
                  label: const Text('Unplanned'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _finishNow,
                  icon: const Icon(Icons.stop),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56)),
                  label: const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 24),
        Expanded(child: _segmentList(live: true)),
      ],
    );
  }

  Widget _summaryView() {
    final total = _segments.fold<Duration>(
        Duration.zero, (a, s) => a + s.duration);
    Duration byCat(Category c) => _segments
        .where((s) => s.category == c)
        .fold<Duration>(Duration.zero, (a, s) => a + s.duration);
    final va = byCat(Category.productive);
    final vaRatio = total.inMilliseconds == 0
        ? 0.0
        : va.inMilliseconds / total.inMilliseconds;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Study complete',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              _statRow('Total time', formatDuration(total)),
              _statRow('Setup', formatDuration(byCat(Category.setup))),
              _statRow('Value-added', formatDuration(va)),
              _statRow('Waste', formatDuration(byCat(Category.waste))),
              _statRow('Value-added ratio',
                  '${(vaRatio * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _segmentList(live: false)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.replay),
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
            label: const Text('RUN AGAIN', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _segmentList({required bool live}) {
    if (_segments.isEmpty) {
      return const Center(child: Text('No operations recorded yet.'));
    }
    // Newest first while running so the live one is at the top; chronological
    // in the summary.
    final items = live ? _segments.reversed.toList() : _segments;
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final s = items[i];
        return ListTile(
          leading: Icon(Icons.circle, size: 14, color: s.category.color),
          title: Text(s.name +
              (s.unplanned ? '  (unplanned)' : '') +
              (s.isOpen ? '  •' : '')),
          subtitle: Text(s.category.label),
          trailing: Text(
            formatDuration(s.duration),
            style: const TextStyle(
              fontSize: 18,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              )),
        ],
      ),
    );
  }

  Widget _categoryChip(Category c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: c.color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(c.label,
          style: TextStyle(color: c.color, fontWeight: FontWeight.w600)),
    );
  }
}
