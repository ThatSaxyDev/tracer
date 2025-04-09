import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracer/models/ghost_race_data.dart';
import 'package:tracer/models/player_entity.dart';
import 'package:tracer/models/game_state.dart';

final gameNotifierProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});

class GameNotifier extends Notifier<GameState> {
  Timer? _timer;
  Timer? _typoTimer;

  @override
  GameState build() {
    return GameState(
      targetText: targetText,
      player: PlayerEntity(playerId: '-1', input: ''),
      otherPlayers: [],
    );
  }

  void clearPlayerInput() {
    state = state.copyWith(player: state.player.copyWith(input: ''));
  }

  void clearData() {
    stopTimer();
    _cancelTypoTimer();
    state = GameState(
      targetText: targetText,
      player: PlayerEntity(playerId: '-1', input: ''),
      otherPlayers: [],
      isTypoPenaltyActive: false,
    );
  }

  void updateInput({
    required String value,
    void Function()? onComplete,
    void Function()? typoPenaltyEffect,
  }) {
    final now = DateTime.now();
    final targetText = state.targetText;

    // If typo penalty is active, don't accept any new input
    if (state.isTypoPenaltyActive) {
      return;
    }

    final trimmedInput = value.trimRight();
    final cappedInput = trimmedInput.length > targetText.length
        ? trimmedInput.substring(0, targetText.length)
        : trimmedInput;

    // Check for typo
    if (cappedInput.isNotEmpty && targetText.isNotEmpty) {
      final currentPosition = cappedInput.length - 1;
      if (currentPosition >= 0 && currentPosition < targetText.length) {
        // Check if the last character typed matches the target text
        if (cappedInput[currentPosition] != targetText[currentPosition]) {
          // First, update the state to show the incorrect character (for shake animation)
          final updatedPlayer = state.player.copyWith(input: cappedInput);
          state = state.copyWith(player: updatedPlayer);

          // Then start the penalty timer to allow animation to play
          _startTypoPenalty(
            input: cappedInput,
            currentPosition: currentPosition,
            typoPenaltyEffect: typoPenaltyEffect,
          );
          return;
        }
      }
    }

    final isFirstInput =
        state.player.startTime == null && cappedInput.isNotEmpty;
    final isComplete = cappedInput.length >= targetText.length;

    final updatedPlayer = state.player.copyWith(
      input: cappedInput,
      startTime: isFirstInput ? now : state.player.startTime,
      endTime: isComplete && state.player.endTime == null
          ? now
          : state.player.endTime,
    );

    // Update ghost keystroke if started
    if (updatedPlayer.startTime != null) {
      final elapsed = now.difference(updatedPlayer.startTime!);
      final charIndex = cappedInput.length - 1;
    }

    // Start UI update timer
    if (isFirstInput) _startTimer();
    if (isComplete && state.player.endTime == null) {
      stopTimer();
      if (onComplete != null) onComplete();
    }

    // Commit updated player to state
    state = state.copyWith(player: updatedPlayer);
  }

  void _startTypoPenalty({
    required String input,
    required int currentPosition,
    void Function()? typoPenaltyEffect,
  }) {
    state = state.copyWith(isTypoPenaltyActive: true);

    // Start a timer that matches the duration of your animation
    // The shake animation + fade transition takes approximately 500ms based on your code
    // So let's set a slightly longer delay to ensure the animation completes
    _typoTimer = Timer(const Duration(milliseconds: 650), () {
      // After the animation plays, delete the word and allow input again
      int lastSpaceIndex = input.lastIndexOf(' ', currentPosition - 1);
      String correctedValue = lastSpaceIndex >= 0
          ? input.substring(0, lastSpaceIndex + 1)
          : ''; // +1 to keep the space

      // Update the player's input
      state = state.copyWith(
        player: state.player.copyWith(input: correctedValue),
      );

      typoPenaltyEffect?.call();

      // Reset the penalty flag
      state = state.copyWith(isTypoPenaltyActive: false);
    });
  }

  void _cancelTypoTimer() {
    _typoTimer?.cancel();
    _typoTimer = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (state.player.endTime == null) {
        state = state.copyWith(); // trigger rebuild
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }
}

// class GameNotifier extends Notifier<GameState> {
//   Timer? _timer;

//   @override
//   GameState build() {
//     return GameState(
//       targetText: targetText,
//       player: PlayerEntity(playerId: '-1', input: ''),
//       otherPlayers: [
//         // PlayerEntity(
//         //   playerId: '0',
//         //   input: ref.watch(ghostInputProvider),
//         // ),
//       ],
//     );
//   }

//   void clearPlayerInput() {
//     state = state.copyWith(player: state.player.copyWith(input: ''));
//   }

//   void clearData() {
//     _stopTimer();
//     state = GameState(
//       targetText: targetText,
//       player: PlayerEntity(playerId: '-1', input: ''),
//       otherPlayers: [
//         // PlayerEntity(
//         //   playerId: '0',
//         //   input: ref.watch(ghostInputProvider),
//         // ),
//       ],
//     );
//   }

//   void updateInput({
//     required String value,
//     void Function()? onComplete,
//   }) async {
//     final now = DateTime.now();
//     final targetText = state.targetText;

//     // Check for typo and delete current word if needed
//     String correctedValue = value;
//     if (value.isNotEmpty && targetText.isNotEmpty) {
//       final currentPosition = value.length - 1;
//       if (currentPosition >= 0 && currentPosition < targetText.length) {
//         // Check if the last character typed matches the target text
//         if (value[currentPosition] != targetText[currentPosition]) {
//           // Typo detected, delete back to the last space
//           int lastSpaceIndex = value.lastIndexOf(' ', currentPosition - 1);
//           correctedValue = lastSpaceIndex >= 0
//               ? value.substring(0, lastSpaceIndex + 1)
//               : ''; // +1 to keep the space
//         }
//       }
//     }

//     final trimmedInput = correctedValue.trimRight();
//     final cappedInput = trimmedInput.length > targetText.length
//         ? trimmedInput.substring(0, targetText.length)
//         : trimmedInput;

//     final isFirstInput =
//         state.player.startTime == null && cappedInput.isNotEmpty;
//     final isComplete = cappedInput.length >= targetText.length;

//     final updatedPlayer = state.player.copyWith(
//       input: cappedInput,
//       startTime: isFirstInput ? now : state.player.startTime,
//       endTime: isComplete && state.player.endTime == null
//           ? now
//           : state.player.endTime,
//     );

//     // Update ghost keystroke if started
//     if (updatedPlayer.startTime != null) {
//       final elapsed = now.difference(updatedPlayer.startTime!);
//       final charIndex = cappedInput.length - 1;

//       // if (charIndex >= 0 && charIndex < targetText.length) {
//       //   ref.read(ghostRaceDataProvider.notifier).addKeystroke(
//       //         charIndex,
//       //         elapsed,
//       //         cappedInput[charIndex],
//       //       );
//       // }
//     }

//     // Log keystrokes (optional debugging)
//     // final keystrokes = ref.read(ghostRaceDataProvider).currentkeystrokes;
//     // for (int i = 0; i < keystrokes.length; i++) {
//     //   final k = keystrokes[i];
//     //   if (k.charIndex >= 0 && k.charIndex < cappedInput.length) {
//     //     final char = cappedInput[k.charIndex];
//     //     print(
//     //         'Keystroke ${i + 1}: Index: ${k.charIndex}, Char: "$char", Time: ${k.timestamp}');
//     //   } else {
//     //     print('Keystroke ${i + 1}: Index out of bounds: ${k.charIndex}');
//     //   }
//     // }
//     // print('Total Keystrokes: ${keystrokes.length}');

//     // Start UI update timer
//     if (isFirstInput) _startTimer();
//     if (isComplete && state.player.endTime == null) {
//       _stopTimer();
//     }

//     // Commit updated player to state
//     state = state.copyWith(player: updatedPlayer);
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
//       if (state.player.endTime == null) {
//         state = state.copyWith(); // trigger rebuild
//       }
//     });
//   }

//   void _stopTimer() {
//     _timer?.cancel();
//   }
// }
