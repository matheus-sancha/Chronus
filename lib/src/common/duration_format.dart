/// Formats a duration in milliseconds as the dynamic `HH:MM:SS.D` used across
/// Chronus reports — tenths of a second, collapsing leading empty units:
/// `4.3`, `1:15.2`, `1:02:05.4`.
String formatHmsd(int milliseconds) {
  final totalTenths = (milliseconds / 100).round();
  final tenths = totalTenths % 10;
  final totalSeconds = totalTenths ~/ 10;
  final seconds = totalSeconds % 60;
  final totalMinutes = totalSeconds ~/ 60;
  final minutes = totalMinutes % 60;
  final hours = totalMinutes ~/ 60;

  String two(int n) => n.toString().padLeft(2, '0');

  if (hours > 0) return '$hours:${two(minutes)}:${two(seconds)}.$tenths';
  if (minutes > 0) return '$minutes:${two(seconds)}.$tenths';
  return '$seconds.$tenths';
}
