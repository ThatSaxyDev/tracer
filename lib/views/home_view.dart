import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tracer/notifiers/game_notifier.dart';
import 'package:tracer/notifiers/ghost_input_notifier.dart';
import 'package:tracer/shared/extensions.dart';
import 'package:tracer/views/level_selection_view.dart';
import 'package:tracer/widgets/animated_sign.dart/animated_sign.dart';
import 'package:tracer/widgets/animated_sign.dart/tracer_insignia.dart';
import 'package:tracer/widgets/game_button.dart';
import 'race_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _showStart = false.notifier;

  @override
  void dispose() {
    _showStart.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _showStartButton();
  }

  void _showStartButton() {
    Future.delayed(2.seconds).then((_) {
      _showStart.value = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Stack(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TracerInsignia(
                        height: 40,
                        width: 200,
                      ).fadeIn(delay: 400.ms),
                      const SizedBox(height: 32),
                      const Text(
                        'T-Racer',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ).fadeIn(delay: 200.ms),
                    ],
                  ),
                  _showStart.sync(
                    builder: (context, value, child) => _showStart.value
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 32),
                            child: Column(
                              spacing: 15,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: List.generate(2, (index) {
                                return Opacity(
                                  opacity: index == 0 ? 1 : 0.3,
                                  child: GameButton(
                                          onPressed: () {
                                            ref
                                                .read(
                                                    ghostInputProvider.notifier)
                                                .clearGhostInput();
                                            ref
                                                .read(gameNotifierProvider
                                                    .notifier)
                                                .clearData();
                                            ref
                                                .read(
                                                    ghostInputProvider.notifier)
                                                .stopPlayback();

                                            switch (index) {
                                              case 0:
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const LevelSelectionView()));
                                                break;
                                              default:
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      'Multiplayer mode is not available yet.'),
                                                ));
                                            }
                                          },
                                          text: switch (index) {
                                            0 => 'VS Ghost',
                                            _ => 'VS Player',
                                          })
                                      .fadeInFromBottom(
                                          delay: (index * 400).ms),
                                );
                              }),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
