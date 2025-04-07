import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracer/models/game_state.dart';
import 'package:tracer/models/ghost_race_data.dart';
import 'package:tracer/notifiers/game_notifier.dart';

// Ghost input provider
final ghostInputProvider = NotifierProvider<GhostInputNotifier, String>(() {
  return GhostInputNotifier();
});

class GhostInputNotifier extends Notifier<String> {
  GhostRaceData get ghostRaceData => ref.watch(ghostRaceDataProvider);
  GameState get gameState => ref.watch(gameNotifierProvider);
  // DateTime? raceStart;
  // late String targetText;

  @override
  String build() {
    return '';
  }

  // void setLastGhostInput({required String lastInput}) {
  //   state = lastInput;
  // }

  void clearGhostInput() {
    state = '';
  }

  void startPlayback() {
    if (ghostRaceData.lastSavedkeystrokes.isEmpty) {
      return;
    }

    print('Ghost playback started');
    List<GhostKeystroke> keystrokes = ghostRaceData.lastSavedkeystrokes;
    final total = keystrokes.length;

    String reconstructedTargetText = keystrokes.map((k) => k.character).join();

    for (int i = 0; i < total; i++) {
      final delay = keystrokes[i].timestamp;
      Future.delayed(delay, () {
        if (i < total) {
          state = reconstructedTargetText.substring(0, i + 1);
          print('Ghost typed: ${reconstructedTargetText[i]} at $delay');
        }
      });
    }
  }
}
