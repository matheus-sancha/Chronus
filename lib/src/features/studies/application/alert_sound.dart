import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'timing_model.dart';

/// Plays the workspace pace cues. An interface, not a concrete player, so the
/// workspace can be exercised in tests and screenshots without an audio device.
abstract class AlertSounds {
  Future<void> play(OperationPace pace);
  void dispose();
}

/// Silent implementation — the default in tests and dev-tool renders.
class SilentAlertSounds implements AlertSounds {
  const SilentAlertSounds();

  @override
  Future<void> play(OperationPace pace) async {}

  @override
  void dispose() {}
}

/// Asset-backed cues. One player per sound so an "exceeded" never has to wait
/// on an "approaching" that is still finishing.
///
/// Every failure is swallowed: no sound device, no plugin registration (a
/// packaged build missing its native bits), a codec the host cannot open. An
/// alert is an aid — losing it must never interrupt the timing that the analyst
/// is actually standing at the machine to capture.
class AssetAlertSounds implements AlertSounds {
  AssetAlertSounds();

  final _players = <OperationPace, AudioPlayer>{};

  static const _assets = {
    OperationPace.approaching: 'sounds/approaching.wav',
    OperationPace.over: 'sounds/exceeded.wav',
  };

  @override
  Future<void> play(OperationPace pace) async {
    final asset = _assets[pace];
    if (asset == null) return; // onTrack has no sound
    try {
      final player = _players[pace] ??= AudioPlayer()
        ..setReleaseMode(ReleaseMode.stop);
      await player.stop(); // restart rather than overlap with itself
      await player.play(AssetSource(asset));
    } catch (error, stack) {
      debugPrint('Alert sound failed ($asset): $error\n$stack');
    }
  }

  @override
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }
}

/// Override with [SilentAlertSounds] in tests and screenshot tooling.
final alertSoundsProvider = Provider<AlertSounds>((ref) {
  final sounds = AssetAlertSounds();
  ref.onDispose(sounds.dispose);
  return sounds;
});
