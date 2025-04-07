import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:tracer/notifiers/game_notifier.dart';
import 'package:tracer/notifiers/ghost_input_notifier.dart';
import 'package:tracer/widgets/animated_sign.dart/animated_sign.dart';
import 'race_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 64),
              Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: Stack(
                      children: [
                        AnimatedSign(
                          direction: ArrowDirection.left,
                        ),
                        AnimatedSign(
                          direction: ArrowDirection.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'T-Racer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(ghostInputProvider.notifier).clearGhostInput();
                    ref.read(gameNotifierProvider.notifier).clearData();
                    ref.read(ghostInputProvider.notifier).stopPlayback();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RaceScreen()));
                  },
                  child: const Text('Start'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
