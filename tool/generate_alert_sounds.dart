// Generates the two workspace pace alert sounds in `assets/sounds/`.
//
// The assets are committed, so this runs only when the sounds need changing —
// it exists so they stay reproducible and licence-free rather than being
// mystery binaries pulled from a sound library.
//
//   dart run tool/generate_alert_sounds.dart
//
// The two cues are distinguished by *contour*, not just pitch: approaching
// rises, exceeded falls. Contour survives a noisy shop floor and a cheap
// laptop speaker, where two similar single beeps would not.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _sampleRate = 44100;
const _amplitude = 0.6; // headroom against clipping on rounding

/// (frequency Hz, seconds) — frequency 0 is a silent gap.
typedef _Part = (double, double);

void main() {
  final dir = Directory('assets/sounds')..createSync(recursive: true);

  // Rising A5 -> D6: "get ready".
  _write(dir, 'approaching.wav', const [
    (880.0, 0.09),
    (0.0, 0.03),
    (1174.7, 0.11),
  ]);

  // Falling E5 -> A4, longer tail: "you are over".
  _write(dir, 'exceeded.wav', const [
    (659.3, 0.13),
    (0.0, 0.05),
    (440.0, 0.20),
  ]);
}

void _write(Directory dir, String name, List<_Part> parts) {
  final file = File('${dir.path}/$name');
  file.writeAsBytesSync(_wav(_render(parts)));
  stdout.writeln('wrote ${file.path} (${file.lengthSync()} bytes)');
}

Int16List _render(List<_Part> parts) {
  final samples = <int>[];
  for (final (freq, seconds) in parts) {
    final count = (seconds * _sampleRate).round();
    for (var i = 0; i < count; i++) {
      if (freq == 0) {
        samples.add(0);
        continue;
      }
      final value = math.sin(2 * math.pi * freq * (i / _sampleRate)) *
          _envelope(i, count) *
          _amplitude;
      samples.add((value * 32767).round().clamp(-32768, 32767));
    }
  }
  return Int16List.fromList(samples);
}

/// Linear attack/release so notes start and stop without an audible click —
/// a hard-edged sine is a pop, which reads as a fault rather than a signal.
double _envelope(int i, int count) {
  const attack = 220; // ~5 ms
  final release = math.min(880, count ~/ 2); // ~20 ms
  if (i < attack) return i / attack;
  if (i > count - release) return (count - i) / release;
  return 1;
}

/// Minimal 16-bit mono PCM RIFF/WAVE container.
Uint8List _wav(Int16List samples) {
  final dataBytes = samples.lengthInBytes;
  final out = ByteData(44 + dataBytes);

  void ascii(int offset, String tag) {
    for (var i = 0; i < tag.length; i++) {
      out.setUint8(offset + i, tag.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  out.setUint32(4, 36 + dataBytes, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  out.setUint32(16, 16, Endian.little); // PCM chunk size
  out.setUint16(20, 1, Endian.little); // format = PCM
  out.setUint16(22, 1, Endian.little); // channels = mono
  out.setUint32(24, _sampleRate, Endian.little);
  out.setUint32(28, _sampleRate * 2, Endian.little); // byte rate
  out.setUint16(32, 2, Endian.little); // block align
  out.setUint16(34, 16, Endian.little); // bits per sample
  ascii(36, 'data');
  out.setUint32(40, dataBytes, Endian.little);

  for (var i = 0; i < samples.length; i++) {
    out.setInt16(44 + i * 2, samples[i], Endian.little);
  }
  return out.buffer.asUint8List();
}
