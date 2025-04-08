import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracer/notifiers/ghost_difficulty.dart';

final ghostRaceDataProvider =
    NotifierProvider<GhostRaceDataNotifier, GhostRaceData>(() {
  return GhostRaceDataNotifier();
});

class GhostRaceDataNotifier extends Notifier<GhostRaceData> {
  @override
  GhostRaceData build() {
    return mediumGhostRace;
  }

  void setGhostDifficultyLevel({required GhostRaceData ghostLevel}) {
    state = ghostLevel;
  }

  // void addKeystroke(
  //   int charIndex,
  //   Duration timestamp,
  //   String character,
  // ) {
  //   state = state.copyWith(
  //     currentkeystrokes: [
  //       ...state.currentkeystrokes,
  //       GhostKeystroke(
  //           charIndex: charIndex, timestamp: timestamp, character: character),
  //     ],
  //   );
  // }

  // void setLastSavedKeystroke() {
  //   state = state.copyWith(
  //     lastSavedkeystrokes: state.currentkeystrokes,
  //   );
  //   state = state.copyWith(currentkeystrokes: []);
  // }
}

class GhostRaceData {
  final List<GhostKeystroke> currentkeystrokes;
  final List<GhostKeystroke> lastSavedkeystrokes;

  GhostRaceData({
    required this.currentkeystrokes,
    required this.lastSavedkeystrokes,
  });

  GhostRaceData copyWith({
    List<GhostKeystroke>? currentkeystrokes,
    List<GhostKeystroke>? lastSavedkeystrokes,
  }) {
    return GhostRaceData(
      currentkeystrokes: currentkeystrokes ?? this.currentkeystrokes,
      lastSavedkeystrokes: lastSavedkeystrokes ?? this.lastSavedkeystrokes,
    );
  }

  @override
  String toString() =>
      'GhostRaceData(currentkeystrokes: $currentkeystrokes, lastSavedkeystrokes: $lastSavedkeystrokes)';
}

class GhostKeystroke {
  final String character;
  final int charIndex;
  final Duration timestamp;

  GhostKeystroke({
    required this.character,
    required this.charIndex,
    required this.timestamp,
  });

  @override
  String toString() =>
      'GhostKeystroke(character: $character, charIndex: $charIndex, timestamp: $timestamp)';
}

// final lastRaceGhostProvider = StateProvider<GhostRaceData?>((ref) => null);
