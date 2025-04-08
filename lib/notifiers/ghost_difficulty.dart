import 'dart:math';

import 'package:tracer/models/game_state.dart';
import 'package:tracer/models/ghost_race_data.dart';

final random = Random();

// Difficulty level constants (typing speed ranges in milliseconds)
const easyMinDelay = 500;
const easyMaxDelay = 700;
const mediumMinDelay = 300;
const mediumMaxDelay = 500;
const hardMinDelay = 150;
const hardMaxDelay = 300;
const goHomeMinDelay = 50;
const goHomeMaxDelay = 150;

// Function to generate keystrokes with realistic delays
List<GhostKeystroke> generateKeystrokes(
  String text,
  Duration startDelay,
  int minDelay,
  int maxDelay,
) {
  List<GhostKeystroke> keystrokes = [];
  Duration timestamp = startDelay;

  for (int i = 0; i < text.length; i++) {
    keystrokes.add(GhostKeystroke(
      character: text[i],
      charIndex: i,
      timestamp: timestamp,
    ));

    // Introduce a random delay based on difficulty
    final randomDelay = random.nextInt(maxDelay - minDelay) + minDelay;
    timestamp += Duration(milliseconds: randomDelay);
  }

  return keystrokes;
}

// Generate keystrokes for different difficulty levels
List<GhostKeystroke> easyKeystrokes =
    generateKeystrokes(targetText, Duration.zero, easyMinDelay, easyMaxDelay);
List<GhostKeystroke> mediumKeystrokes = generateKeystrokes(
    targetText, Duration.zero, mediumMinDelay, mediumMaxDelay);
List<GhostKeystroke> hardKeystrokes =
    generateKeystrokes(targetText, Duration.zero, hardMinDelay, hardMaxDelay);
List<GhostKeystroke> goHomeKeystrokes = generateKeystrokes(
    targetText, Duration.zero, goHomeMinDelay, goHomeMaxDelay);

// Create GhostRaceData for each difficulty level
GhostRaceData easyGhostRace = GhostRaceData(
  currentkeystrokes: [],
  lastSavedkeystrokes: easyKeystrokes,
);

GhostRaceData mediumGhostRace = GhostRaceData(
  currentkeystrokes: [],
  lastSavedkeystrokes: mediumKeystrokes,
);

GhostRaceData hardGhostRace = GhostRaceData(
  currentkeystrokes: [],
  lastSavedkeystrokes: hardKeystrokes,
);

GhostRaceData goHomeGhostRace = GhostRaceData(
  currentkeystrokes: [],
  lastSavedkeystrokes: goHomeKeystrokes,
);

List<GhostRaceData> ghostLevels = [
  easyGhostRace,
  mediumGhostRace,
  hardGhostRace,
  goHomeGhostRace,
];

