import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracer/models/game_state.dart';

import 'package:tracer/models/ghost_race_data.dart';
import 'package:tracer/models/player_entity.dart';
import 'package:tracer/notifiers/ghost_input_notifier.dart';
import 'package:tracer/shared/extensions.dart';
import 'package:tracer/widgets/animated_sign.dart/animated_sign.dart';
import 'package:tracer/widgets/animated_sign.dart/tracer_insignia.dart';
import 'package:tracer/widgets/game_button.dart';
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
  bool _hasShownDialog = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkCompletion(GameState? prev, GameState next, WidgetRef ref) {
    final targetText = next.targetText;

    final playerCompletedBefore = prev?.player.isComplete(targetText) ?? false;
    final playerCompletedNow = next.player.isComplete(targetText);

    final ghostInput = ref.read(ghostInputProvider).input;
    final ghostCompleted = ghostInput.length >= targetText.length;

    final hasJustCompleted =
        !playerCompletedBefore && (playerCompletedNow || ghostCompleted);

    if (hasJustCompleted) {
      hideKeyboard(context);
      ref.read(gameNotifierProvider.notifier).stopTimer();
    }

    if (hasJustCompleted && !_hasShownDialog) {
      _hasShownDialog = true;

      final whoWon = playerCompletedNow
          ? 'You won!'
          : ghostCompleted
              ? 'Ghost won!'
              : 'It\'s a tie!';

      Future.microtask(() {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (contextt) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(
              whoWon,
              style: TextStyle(
                color:
                    playerCompletedNow ? Colors.greenAccent : Colors.redAccent,
                fontFamily: 'Courier',
              ),
            ),
            content: Text(
              'See how you did in the results screen.',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
            actions: [
              GameButton(
                onPressed: () {
                  // Navigator.of(contextt).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultScreen(
                        winner: playerCompletedNow
                            ? 'player'
                            : ghostCompleted
                                ? 'ghost'
                                : 'tie',
                      ),
                    ),
                  );
                },
                text: 'View Results',
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for when player completes the race
    ref.listen<GameState>(gameNotifierProvider, (prev, next) {
      _checkCompletion(prev, next, ref);
    });

    ref.listen<GhostInputState>(ghostInputProvider, (_, __) {
      final gameState = ref.read(gameNotifierProvider);
      _checkCompletion(
          null, gameState, ref); // use null as prev to focus on ghost
    });
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(ghostInputProvider.notifier).clearGhostInput();
        ref.read(gameNotifierProvider.notifier).clearData();
        ref.read(ghostInputProvider.notifier).stopPlayback();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          title: formatDuration(
              ref.watch(gameNotifierProvider).player.elapsedTime),
        ),
        // extendBodyBehindAppBar: true,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // const Text('Typing Challenge',
                    //     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    // const SizedBox(height: 12),
                    PlayerView(player: ref.watch(gameNotifierProvider).player),
                    const SizedBox(height: 14),
                    TracerInsignia(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      isIndefinite: false,
                      leftProgress:
                          ref.watch(gameNotifierProvider).player.input.length /
                              ref.watch(gameNotifierProvider).targetText.length,
                      rightProgress:
                          ref.watch(ghostInputProvider).input.length /
                              ref.watch(gameNotifierProvider).targetText.length,
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
                  ],
                ),
              ),
              [startedPlayBack, _controller].multiSync(
                builder: (context, child) {
                  return SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24)
                            .copyWith(bottom: 30),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withAlpha(25), // Semi-transparent overlay
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: TextField(
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
                                  if (value.isNotEmpty &&
                                      !startedPlayBack.value) {
                                    startedPlayBack.value = true;
                                    ref
                                        .read(ghostInputProvider.notifier)
                                        .startPlayback();
                                  }

                                  // Prevent backspacing by ensuring the input length doesn't decrease
                                  if (value.length >=
                                      ref
                                          .watch(gameNotifierProvider)
                                          .player
                                          .input
                                          .length) {
                                    ref
                                        .read(gameNotifierProvider.notifier)
                                        .updateInput(
                                          value: value,
                                          typoPenaltyEffect: () {
                                            _controller.text = ref
                                                .read(gameNotifierProvider)
                                                .player
                                                .input;
                                            _controller.selection =
                                                TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: ref
                                                      .read(
                                                          gameNotifierProvider)
                                                      .player
                                                      .input
                                                      .length),
                                            );
                                          },
                                        );
                                  } else {
                                    _controller.text = ref
                                        .watch(gameNotifierProvider)
                                        .player
                                        .input;
                                    _controller.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                          offset: ref
                                              .watch(gameNotifierProvider)
                                              .player
                                              .input
                                              .length),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
}
