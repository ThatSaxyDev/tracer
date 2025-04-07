import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracer/models/player_entity.dart';
import 'package:tracer/notifiers/game_notifier.dart';
import 'package:tracer/views/race_view.dart';
import 'package:tracer/widgets/type_display.dart';

class PlayerView extends ConsumerWidget {
  final PlayerEntity player;
  const PlayerView({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time: ${formatDuration(player.elapsedTime)}',
            style: TextStyle(
              fontSize: player.playerId == '-1' ? 16 : 12,
              color: Colors.greenAccent,
            )),
        Text(
            'Accuracy: ${player.accuracy(gameState.targetText).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: player.playerId == '-1' ? 16 : 12,
              color: player.accuracy(gameState.targetText) >= 95
                  ? Colors.greenAccent
                  : (player.accuracy(gameState.targetText) >= 80
                      ? Colors.yellowAccent
                      : Colors.redAccent),
            )),
        Text('WPM: ${player.wpm(gameState.targetText).toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: player.playerId == '-1' ? 16 : 12,
              color: Colors.cyanAccent,
            )),
        const SizedBox(height: 16),
        TypeDisplay(
          target: gameState.targetText,
          input: player.input,
          player: player,
        ),
      ],
    );
  }
}
