import 'package:tracer/models/player_entity.dart';

class GameState {
  final String targetText;
  // final PlayerEntity player;
  final List<PlayerEntity> players;
  final bool isTypoPenaltyActive;

  GameState({
    required this.targetText,
    // required this.player,
    this.players = const [],
    this.isTypoPenaltyActive = false,
  });

  GameState copyWith({
    String? targetText,
    // PlayerEntity? player,
    List<PlayerEntity>? players,
    bool? isTypoPenaltyActive,
  }) {
    return GameState(
      targetText: targetText ?? this.targetText,
      // player: player ?? this.player,
      players: players ?? this.players,
      isTypoPenaltyActive: isTypoPenaltyActive ?? this.isTypoPenaltyActive,
    );
  }
}

String targetText = 'Despite the rain.';

// String targetText =
//     'Despite the rain pouring down outside, the determined developer continued to type, line after line, perfecting their creation with every keystroke, unaware of how much time had passed. The sound of the keyboard echoed in the empty room, a rhythmic symphony of productivity that drowned out the world around them. The glow of the screen illuminated their focused face, reflecting the passion and dedication that fueled their work. Each character they typed was a step closer to their goal, a testament to their unwavering commitment to excellence. As the hours slipped away, the developer lost themselves in the flow of code, their fingers dancing across the keys with a grace that belied the complexity of the task at hand. The outside world faded into a distant memory, replaced by the vibrant landscape of their imagination, where ideas took shape and innovation thrived. In that moment, nothing else mattered but the code, the creation, and the joy of bringing something new to life.';

// String tTExt = 'The text is short';

// String targetText2 = 'Despite the rain pouring down outside.';
