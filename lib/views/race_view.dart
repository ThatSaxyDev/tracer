import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracer/models/ghost_race_data.dart';
import 'package:tracer/models/player_entity.dart';
import 'package:tracer/notifiers/ghost_input_notifier.dart';
import 'package:tracer/shared/extensions.dart';
import 'package:tracer/widgets/player_view.dart';
import '../widgets/type_display.dart';
import '../notifiers/game_notifier.dart';
import 'result_view.dart';

class RaceScreen extends ConsumerStatefulWidget {
  const RaceScreen({super.key});

  @override
  ConsumerState<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends ConsumerState<RaceScreen> {
  final startedPlayBack = false.notifier;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        // ref.read(ghostInputProvider.notifier).startPlayback();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    // GhostRaceData ghostRaceData = GhostRaceData(keystrokes: []);

    if (gameState.player.isComplete(gameState.targetText)) {
      Future.delayed(Duration.zero, () {
        ref.read(ghostRaceDataProvider.notifier).setLastSavedKeystroke();
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      });
      return const SizedBox.shrink();
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(ghostInputProvider.notifier).clearGhostInput();
        ref.read(gameNotifierProvider.notifier).clearData();
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Text('Typing Challenge',
              //     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              // const SizedBox(height: 12),
              PlayerView(player: gameState.player),

              const SizedBox(height: 24),

              // if (gameState.otherPlayers.isNotEmpty)
              if (ref
                  .watch(ghostRaceDataProvider)
                  .lastSavedkeystrokes
                  .isNotEmpty)
                TypeDisplay(
                  target: gameState.targetText,
                  input: ref.watch(ghostInputProvider),
                  player: PlayerEntity(
                      playerId: '0', input: ref.watch(ghostInputProvider)),
                ),

              const SizedBox(height: 24),
              startedPlayBack.sync(
                builder: (context, value, child) {
                  return TextField(
                    autofocus: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    cursorColor: Colors.greenAccent,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Courier',
                    ),
                    maxLines: 1,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && !startedPlayBack.value) {
                        startedPlayBack.value = true;
                        ref.read(ghostInputProvider.notifier).startPlayback();
                      }
                      ref
                          .read(gameNotifierProvider.notifier)
                          .updateInput(value: value);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatDuration(Duration d) {
  int minutes = d.inMinutes;
  int seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}.${(d.inMilliseconds % 1000).toString().padLeft(3, '0')}s';
}
