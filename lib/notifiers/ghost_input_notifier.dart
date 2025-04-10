// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  Timer? playbackTimer; // Timer to manage playback

  @override
  GhostInputState build() {
    return GhostInputState(
      // input: '',
      playBackState: PlayBackState.notStarted,
    );
  }

  void clearGhostInput() {
    state = state.copyWith(
      // input: '',
      playBackState: PlayBackState.notStarted,
    );
  }

  void startPlayback() async {
    state = state.copyWith(
      playBackState: PlayBackState.notStarted,
      startTime: DateTime.now(),
      endTime: null,
    );
    ref.read(gameNotifierProvider.notifier).updateGhostPlayer(
          startTime: DateTime.now(),
          endTime: null,
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
      if (state.playBackState == PlayBackState.stopped) {
        print('Playback stopped at character $i');
        break;
      }

      state = state.copyWith(
        // input: reconstructedTargetText.substring(0, i + 1),
        playBackState: PlayBackState.playing,
      );
      ref
          .read(gameNotifierProvider.notifier)
          .updateGhostInput(reconstructedTargetText.substring(0, i + 1));
      final trimmedInput =
          ref.read(gameNotifierProvider).players[0].input.trimRight();
      final cappedInput = trimmedInput.length > targetText.length
          ? trimmedInput.substring(0, targetText.length)
          : trimmedInput;

      final isFirstInput = state.startTime == null && cappedInput.isNotEmpty;
      final isComplete = cappedInput.length >= targetText.length;
      // print('Ghost typed: ${reconstructedTargetText[i]} at $delay');
      // if (isFirstInput) _startTimer();
      if (isComplete && state.endTime == null) {
        stopPlayback();
      }
    }

    // End playback
    // if (state.playBackState != PlayBackState.stopped) {
    //   state = state.copyWith(
    //     playBackState: PlayBackState.stopped,
    //   );
    //   print('Ghost playback ended');
    // }
  }

  void stopPlayback() {
    // Set the playback state to stopped and cancel the ongoing playback
    if (playbackTimer?.isActive ?? false) {
      playbackTimer?.cancel();
    }
    // Set endTime when stopping playback
    state = state.copyWith(
      playBackState: PlayBackState.stopped,
      endTime: DateTime.now(), // Add this line
    );
    ref.read(gameNotifierProvider.notifier).updateGhostPlayer(
          endTime: DateTime.now(),
        );

    print('Ghost playback stopped');
  }
}

enum PlayBackState {
  notStarted,
  playing,
  paused,
  stopped,
}

class GhostInputState {
  // final String input;
  final PlayBackState playBackState;
  final DateTime? startTime;
  final DateTime? endTime;

  GhostInputState({
    // required this.input,
    required this.playBackState,
    this.startTime,
    this.endTime,
  });

  Duration get elapsedTime {
    if (startTime == null) return Duration.zero;
    return (endTime ?? DateTime.now()).difference(startTime!);
  }

  // int correctChars(String targetText) {
  //   int correct = 0;
  //   for (int i = 0; i < input.length && i < targetText.length; i++) {
  //     if (input[i] == targetText[i]) correct++;
  //   }
  //   return correct;
  // }

  // double accuracy(String targetText) {
  //   if (input.isEmpty) return 0;
  //   return (correctChars(targetText) / input.length) * 100;
  // }

  // double wpm(String targetText) {
  //   if (startTime == null || input.isEmpty) return 0;
  //   final minutes = elapsedTime.inMilliseconds / 60000;
  //   if (minutes == 0) return 0;
  //   return (correctChars(targetText) / 5) / minutes;
  // }

  GhostInputState copyWith({
    // String? input,
    PlayBackState? playBackState,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return GhostInputState(
      // input: input ?? this.input,
      playBackState: playBackState ?? this.playBackState,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
