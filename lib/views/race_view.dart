import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracer/models/ghost_race_data.dart';
import 'package:tracer/models/player_entity.dart';
import 'package:tracer/notifiers/ghost_input_notifier.dart';
import 'package:tracer/shared/extensions.dart';
import 'package:tracer/widgets/animated_sign.dart/animated_sign.dart';
import 'package:tracer/widgets/player_view.dart';

import '../notifiers/game_notifier.dart';
import '../widgets/type_display.dart';
import 'result_view.dart';

class RaceScreen extends ConsumerStatefulWidget {
  const RaceScreen({super.key});

  @override
  ConsumerState<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends ConsumerState<RaceScreen> {
  final startedPlayBack = false.notifier;
  final _controller = TextEditingController();
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback(
  //     (_) {
  //       // ref.read(ghostInputProvider.notifier).startPlayback();
  //     },
  //   );
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final gameState = ref.watch(gameNotifierProvider);
    // GhostRaceData ghostRaceData = GhostRaceData(keystrokes: []);

    if (ref.watch(gameNotifierProvider).player.isComplete(ref.watch(gameNotifierProvider).targetText)) {
     Future.delayed(0.ms , () {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (_) => const ResultScreen(),
          ),
        );
      });
      return const SizedBox.shrink();
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(ghostInputProvider.notifier).clearGhostInput();
        ref.read(gameNotifierProvider.notifier).clearData();
        ref.read(ghostInputProvider.notifier).stopPlayback();
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Text('Typing Challenge',
              //     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              // const SizedBox(height: 12),
              PlayerView(player: ref.watch(gameNotifierProvider).player),
              const SizedBox(height: 14),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Stack(
                  children: [
                    AnimatedSign(
                      progress: ref.watch(gameNotifierProvider).player.input.length /
                          ref.watch(gameNotifierProvider).targetText.length,
                      isIndefinite: false,
                      direction: ArrowDirection.left,
                    ),
                    AnimatedSign(
                      progress: ref.watch(ghostInputProvider).input.length /
                          ref.watch(gameNotifierProvider).targetText.length,
                      isIndefinite: false,
                      direction: ArrowDirection.right,
                    ),
                  ],
                ),
              ),
              // Row(
              //   children: [
              //     AnimatedLessThanSign(),
              //     AnimatedGreaterThanSign(),
              //   ],
              // ),
              const SizedBox(height: 14),

              // if (gameState.otherPlayers.isNotEmpty)
              if (ref
                  .watch(ghostRaceDataProvider)
                  .lastSavedkeystrokes
                  .isNotEmpty)
                TypeDisplay(
                  target: ref.watch(gameNotifierProvider).targetText,
                  input: ref.watch(ghostInputProvider).input,
                  player: PlayerEntity(
                      playerId: '0',
                      input: ref.watch(ghostInputProvider).input),
                ),

              const SizedBox(height: 24),
              [startedPlayBack, _controller].multiSync(
                builder: (context, child) {
                  return TextField(
                    controller: _controller,
                    autofocus: false,
                    autocorrect: false,
                    enableSuggestions: false,
                    cursorColor: Colors.greenAccent,
                    inputFormatters: [
                      NoPasteFormatter(),
                    ],
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Courier',
                    ),
                    maxLines: 1,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Prevent backspacing by ensuring the input length doesn't decrease

                      if (value.isNotEmpty && !startedPlayBack.value) {
                        startedPlayBack.value = true;
                        ref.read(ghostInputProvider.notifier).startPlayback();
                      }
                      if (value.length >= ref.watch(gameNotifierProvider).player.input.length) {
                        ref
                            .read(gameNotifierProvider.notifier)
                            .updateInput(value: value);
                      } else {
                        _controller.text = ref.watch(gameNotifierProvider).player.input;
                        // _controller.selection = TextSelection.fromPosition(
                        //   TextPosition(offset: gameState.player.input.length),
                        // );
                      }
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

RichText formatDuration(Duration d) {
  int minutes = d.inMinutes;
  int seconds = d.inSeconds % 60;
  return RichText(
      text: TextSpan(
    text: '$minutes',
    style: TextStyle(
      fontSize: 24,
      color: Colors.greenAccent,
      fontFamily: 'Courier',
    ),
    children: [
      TextSpan(
        text: 'mins ',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.greenAccent,
          fontFamily: 'Courier',
        ),
      ),
      TextSpan(
        text: seconds.toString().padLeft(2, '0'),
        style: const TextStyle(
          fontSize: 24,
          color: Colors.greenAccent,
          fontFamily: 'Courier',
        ),
      ),
      TextSpan(
        text: 'secs ',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.greenAccent,
          fontFamily: 'Courier',
        ),
      ),
      TextSpan(
        text: (d.inMilliseconds % 1000).toString().padLeft(3, '0'),
        style: const TextStyle(
          fontSize: 20,
          color: Colors.greenAccent,
          fontFamily: 'Courier',
        ),
      ),
    ],
  ));
  // return '$minutes mins ${seconds.toString().padLeft(2, '0')} secs ${(d.inMilliseconds % 1000).toString().padLeft(3, '0')}';
}
