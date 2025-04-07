import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracer/models/game_state.dart';
import 'package:tracer/models/ghost_race_data.dart';
import 'package:tracer/notifiers/game_notifier.dart';

// Ghost input provider
final ghostInputProvider =
    NotifierProvider<GhostInputNotifier, GhostInputState>(() {
  return GhostInputNotifier();
});

class GhostInputNotifier extends Notifier<GhostInputState> {
  GhostRaceData get ghostRaceData => ref.watch(ghostRaceDataProvider);
  GameState get gameState => ref.watch(gameNotifierProvider);
  // DateTime? raceStart;
  // late String targetText;

  @override
  GhostInputState build() {
    return GhostInputState(
      input: '',
      playBackState: PlayBackState.notStarted,
    );
  }

  // void setLastGhostInput({required String lastInput}) {
  //   state = lastInput;
  // }

  void clearGhostInput() {
    state = state.copyWith(
      input: '',
      playBackState: PlayBackState.notStarted,
    );
  }

  void startPlayback() async {
    state = state.copyWith(
      playBackState: PlayBackState.notStarted,
    );
    if (ghostRaceData.lastSavedkeystrokes.isEmpty) {
      return;
    }

    print('Ghost playback started');
    List<GhostKeystroke> keystrokes = ghostRaceData.lastSavedkeystrokes;
    final total = keystrokes.length;

    // Reconstruct target text from keystrokes
    String reconstructedTargetText = keystrokes.map((k) => k.character).join();

    // Initial timestamp (starting at 0)
    Duration lastTimestamp = Duration.zero;

    // Start playback
    for (int i = 0; i < total; i++) {
      final keystroke = keystrokes[i];

      // Calculate the time delay between the current and previous keystroke
      Duration delay = keystroke.timestamp - lastTimestamp;
      lastTimestamp = keystroke.timestamp; // Update the last timestamp

      // Wait for the calculated delay before showing the next character
      await Future.delayed(delay);

      // Update the state with the next character to simulate typing
      state = state.copyWith(
        input: reconstructedTargetText.substring(0, i + 1),
        playBackState: PlayBackState.playing,
      );
      print('Ghost typed: ${reconstructedTargetText[i]} at $delay');
    }

    // End playback
    state = state.copyWith(
      playBackState: PlayBackState.stopped,
    );
  }
}

enum PlayBackState {
  notStarted,
  playing,
  paused,
  stopped,
}

class GhostInputState {
  final String input;
  final PlayBackState playBackState;

  GhostInputState({
    required this.input,
    required this.playBackState,
  });

  GhostInputState copyWith({
    String? input,
    PlayBackState? playBackState,
  }) {
    return GhostInputState(
      input: input ?? this.input,
      playBackState: playBackState ?? this.playBackState,
    );
  }
}
