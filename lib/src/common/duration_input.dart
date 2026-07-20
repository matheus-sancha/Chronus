import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Segmented `HH:MM:SS.D` duration entry — the user types (or edits) each unit.
/// Reports a value in milliseconds, or null when everything is blank/zero.
class DurationInput extends StatefulWidget {
  const DurationInput({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialMs,
  });

  final String label;
  final int? initialMs;
  final ValueChanged<int?> onChanged;

  @override
  State<DurationInput> createState() => _DurationInputState();
}

class _DurationInputState extends State<DurationInput> {
  late final TextEditingController _hours;
  late final TextEditingController _minutes;
  late final TextEditingController _seconds;
  late final TextEditingController _tenths;

  @override
  void initState() {
    super.initState();
    final ms = widget.initialMs ?? 0;
    final totalTenths = (ms / 100).round();
    final tenths = totalTenths % 10;
    final totalSeconds = totalTenths ~/ 10;
    final seconds = totalSeconds % 60;
    final totalMinutes = totalSeconds ~/ 60;
    final minutes = totalMinutes % 60;
    final hours = totalMinutes ~/ 60;
    final blank = ms == 0;
    _hours = TextEditingController(text: blank ? '' : '$hours');
    _minutes = TextEditingController(text: blank ? '' : '$minutes');
    _seconds = TextEditingController(text: blank ? '' : '$seconds');
    _tenths = TextEditingController(text: blank ? '' : '$tenths');
  }

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    _seconds.dispose();
    _tenths.dispose();
    super.dispose();
  }

  int _read(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  void _emit() {
    final ms = _read(_hours) * 3600000 +
        _read(_minutes) * 60000 +
        _read(_seconds) * 1000 +
        _read(_tenths) * 100;
    widget.onChanged(ms == 0 ? null : ms);
  }

  Widget _segment(TextEditingController controller, String hint, int maxLen) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLen),
        ],
        decoration: InputDecoration(hintText: hint, counterText: ''),
        onChanged: (_) => _emit(),
      ),
    );
  }

  Widget _sep(String ch) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(ch, style: Theme.of(context).textTheme.titleLarge),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Row(
          children: [
            _segment(_hours, 'HH', 2),
            _sep(':'),
            _segment(_minutes, 'MM', 2),
            _sep(':'),
            _segment(_seconds, 'SS', 2),
            _sep('.'),
            _segment(_tenths, 'D', 1),
          ],
        ),
      ],
    );
  }
}
