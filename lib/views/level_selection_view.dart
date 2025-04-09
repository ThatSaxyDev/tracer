import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tracer/models/ghost_race_data.dart';
import 'package:tracer/notifiers/game_notifier.dart';
import 'package:tracer/notifiers/ghost_difficulty.dart';
import 'package:tracer/notifiers/ghost_input_notifier.dart';
import 'package:tracer/shared/extensions.dart';
import 'package:tracer/widgets/animated_sign.dart/animated_sign.dart';
import 'package:tracer/widgets/animated_sign.dart/tracer_insignia.dart';
import 'package:tracer/widgets/game_button.dart';
import 'race_view.dart';

class LevelSelectionView extends ConsumerWidget {
  const LevelSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 64),
              // SafeArea(
              //   child: TracerInsignia(
              //     height: 40,
              //     width: 200,
              //   ),
              // ),
              Column(
                children: List.generate(
                  ghostLevels.length,
                  (index) {
                    GhostRaceData ghostLevel = ghostLevels[index];
                    bool isSelected =
                        ghostLevel == ref.watch(ghostRaceDataProvider);

                    // Define more subdued, professional colors
                    Color buttonColor;
                    Color textColor;
                    IconData? levelIcon;

                    switch (index) {
                      case 0: // Easy
                        buttonColor = const Color(0xFF335C67); // Subdued teal
                        textColor = Colors.white;
                        levelIcon = Icons.looks_one;
                        break;
                      case 1: // Medium
                        buttonColor = const Color(0xFF3F4E4F); // Dark slate
                        textColor = Colors.white;
                        levelIcon = Icons.looks_two;
                        break;
                      case 2: // Hard
                        buttonColor = const Color(0xFF2C3639); // Deep charcoal
                        textColor = Colors.white;
                        levelIcon = Icons.looks_3;
                        break;
                      case 3: // Go-home
                        buttonColor = const Color(0xFF293241); // Navy blue
                        textColor = Colors.white;
                        levelIcon = Icons.looks_4;
                        break;
                      default:
                        buttonColor = const Color(0xFF1E1E1E);
                        textColor = Colors.white;
                        levelIcon = null;
                    }

                    return GameButton(
                      isJustText: false,
                      text: switch (index) {
                        0 => 'Easy',
                        1 => 'Medium',
                        2 => 'Hard',
                        3 => 'Go Home',
                        _ => 'Unknown',
                      },
                      onPressed: () {
                        ref
                            .read(ghostRaceDataProvider.notifier)
                            .setGhostDifficultyLevel(ghostLevel: ghostLevel);
                      },
                      isSelected: isSelected,
                      buttonColor: buttonColor,
                      textColor: textColor,
                      leadingIcon: levelIcon,
                      width: 260,
                      borderRadius: 10,
                      fontSize: 20,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: GameButton(
                  text: 'Start',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RaceScreen(),
                      ),
                    );
                  },
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => const RaceScreen(),
                //       ),
                //     );
                //   },
                //   child: const Text('Start'),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
