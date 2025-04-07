import 'package:tracer/models/player_entity.dart';

class GameState {
  final String targetText;
  final PlayerEntity player;
  final List<PlayerEntity> otherPlayers;

  GameState({
    required this.targetText,
    required this.player,
    this.otherPlayers = const [],
  });

  GameState copyWith({
    PlayerEntity? player,
    List<PlayerEntity>? otherPlayers,
  }) {
    return GameState(
      targetText: targetText,
      player: player ?? this.player,
      otherPlayers: otherPlayers ?? this.otherPlayers,
    );
  }
}

String targetText =
    'Despite the rain pouring down outside, the determined developer continued to type, line after line, perfecting their creation with every keystroke, unaware of how much time had passed.';

// String tTExt = 'The text is short';

// String targetText2 = 'Despite the rain pouring down outside.';
