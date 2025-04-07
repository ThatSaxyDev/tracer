import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracer/models/ghost_race_data.dart';
import 'package:tracer/models/player_entity.dart';
import 'package:tracer/models/game_state.dart';

final gameNotifierProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});

class GameNotifier extends Notifier<GameState> {
  Timer? _timer;

  @override
  GameState build() {
    return GameState(
      targetText: targetText,
      player: PlayerEntity(playerId: '-1', input: ''),
      otherPlayers: [
        // PlayerEntity(
        //   playerId: '0',
        //   input: ref.watch(ghostInputProvider),
        // ),
      ],
    );
  }

  void clearPlayerInput() {
    state = state.copyWith(player: state.player.copyWith(input: ''));
  }

  void clearData() {
    _stopTimer();
    state = GameState(
      targetText: targetText,
      player: PlayerEntity(playerId: '-1', input: ''),
      otherPlayers: [
        // PlayerEntity(
        //   playerId: '0',
        //   input: ref.watch(ghostInputProvider),
        // ),
      ],
    );
  }

  void updateInput({required String value}) {
    final now = DateTime.now();
    final targetText = state.targetText;

    final trimmedInput = value.trimRight();
    final cappedInput = trimmedInput.length > targetText.length
        ? trimmedInput.substring(0, targetText.length)
        : trimmedInput;

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

      if (charIndex >= 0 && charIndex < targetText.length) {
        ref.read(ghostRaceDataProvider.notifier).addKeystroke(
              charIndex,
              elapsed,
              cappedInput[charIndex],
            );
      }
    }

    // Log keystrokes (optional debugging)
    final keystrokes = ref.read(ghostRaceDataProvider).currentkeystrokes;
    for (int i = 0; i < keystrokes.length; i++) {
      final k = keystrokes[i];
      if (k.charIndex >= 0 && k.charIndex < cappedInput.length) {
        final char = cappedInput[k.charIndex];
        print(
            'Keystroke ${i + 1}: Index: ${k.charIndex}, Char: "$char", Time: ${k.timestamp}');
      } else {
        print('Keystroke ${i + 1}: Index out of bounds: ${k.charIndex}');
      }
    }
    print('Total Keystrokes: ${keystrokes.length}');

    // Start UI update timer
    if (isFirstInput) _startTimer();
    if (isComplete && state.player.endTime == null) _stopTimer();

    // Commit updated player to state
    state = state.copyWith(player: updatedPlayer);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (state.player.endTime == null) {
        state = state.copyWith(); // trigger rebuild
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }
}
