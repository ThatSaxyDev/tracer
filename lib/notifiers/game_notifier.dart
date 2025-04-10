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
      // player: PlayerEntity(
      //   playerId: '-1',
      //   input: '',
      //   playerName: 'You',
      // ),
      players: [yourPlayer],
    );
  }

  void updatePlayer({
    String? input,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    // Find the ghost player in the list of otherPlayers
    final playerIndex =
        state.players.indexWhere((player) => player.playerId == '-1');

    // If the ghost player exists, update it
    final player = state.players[playerIndex];
    final updatedPlayer = player.copyWith(
      input: input,
      startTime: startTime,
      endTime: endTime,
    );

    // Create a new list with the updated ghost player
    final updatedPlayers = List<PlayerEntity>.from(state.players);
    updatedPlayers[playerIndex] = updatedPlayer;

    // Update the state with the new list
    state = state.copyWith(players: updatedPlayers);
  }

  void updatePlayerInput(String value) {
    updatePlayer(input: value);
  }

  void clearPlayerInput() {
    updatePlayerInput('');
  }

  void clearData() {
    stopTimer();
    _cancelTypoTimer();
    state = GameState(
      targetText: targetText,
      players: [yourPlayer],
      isTypoPenaltyActive: false,
    );
  }

  void addNewPlayer({required PlayerEntity newPlayer}) {
    state = state.copyWith(players: [newPlayer, ...state.players]);
  }

  void removeAllPlayers() {
    // state = state.copyWith(players: []);
    removeAllPlayersExcept('')
  }

  void removeAllPlayersExcept(String playerId) {
    final players = state.players;
    final playerToKeep = players.firstWhere(
      (player) => player.playerId == playerId,
    );

    state = state.copyWith(players: [playerToKeep]);
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

    // final trimmedInput = value.trimRight();
    final cappedInput = value.length > targetText.length
        ? value.substring(0, targetText.length)
        : value;

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
    _typoTimer = Timer(const Duration(milliseconds: 650), () {
      // Check if we're dealing with the first word
      int firstSpaceIndex = state.targetText.indexOf(' ');
      bool isFirstWord =
          firstSpaceIndex == -1 || currentPosition <= firstSpaceIndex;

      // Handle differently based on whether it's the first word or not
      String correctedValue;

      if (isFirstWord) {
        // For first word, only delete the current character, not the whole word
        correctedValue = '';
      } else {
        // For subsequent words, delete the whole word as before
        int lastSpaceIndex = input.lastIndexOf(' ', currentPosition - 1);
        correctedValue = lastSpaceIndex >= 0
            ? input.substring(0, lastSpaceIndex + 1)
            : ''; // +1 to keep the space
      }

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

  void updateGhostPlayer({
    String? input,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    // Find the ghost player in the list of otherPlayers
    final ghostIndex =
        state.otherPlayers.indexWhere((player) => player.playerName == 'Ghost');

    if (ghostIndex != -1) {
      // If the ghost player exists, update it
      final ghostPlayer = state.otherPlayers[ghostIndex];
      final updatedGhostPlayer = ghostPlayer.copyWith(
        input: input,
        startTime: startTime,
        endTime: endTime,
      );

      // Create a new list with the updated ghost player
      final updatedOtherPlayers = List<PlayerEntity>.from(state.otherPlayers);
      updatedOtherPlayers[ghostIndex] = updatedGhostPlayer;

      // Update the state with the new list
      state = state.copyWith(otherPlayers: updatedOtherPlayers);
    } else {
      // If the ghost player doesn't exist, create and add it
      final newGhostPlayer = PlayerEntity(
        playerId: 'ghost-${DateTime.now().millisecondsSinceEpoch}',
        playerName: 'Ghost',
        isGhost: true,
        input: input ?? '',
        startTime: startTime,
        endTime: endTime,
      );

      state = state.copyWith(
        otherPlayers: [newGhostPlayer, ...state.otherPlayers],
      );
    }
  }

  void updateGhostInput(String value) {
    updateGhostPlayer(input: value);
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

final yourPlayer = PlayerEntity(
  playerId: '-1',
  input: '',
  playerName: 'You',
);
