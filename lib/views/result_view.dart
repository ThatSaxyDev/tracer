import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracer/notifiers/game_notifier.dart';
import 'package:tracer/notifiers/ghost_input_notifier.dart';
import 'package:tracer/views/home_view.dart';
import 'package:tracer/widgets/game_button.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ref.read(gameNotifierProvider.notifier).clearPlayerInput();
      // ref.read(ghostInputProvider.notifier).clearGhostInput();
      ref.read(ghostInputProvider.notifier).stopPlayback();
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameNotifierProvider);
    final duration = game.player.elapsedTime;
    final accuracy = game.player.accuracy(game.targetText);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉 Race Complete!',
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                'Your Time: ${duration.inSeconds}.${(duration.inMilliseconds % 1000).toString().padLeft(3, '0')}s',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.greenAccent,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 18,
                  color: accuracy >= 95
                      ? Colors.greenAccent
                      : (accuracy >= 80
                          ? Colors.yellowAccent
                          : Colors.redAccent),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'WPM: ${game.player.wpm(game.targetText).toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.cyanAccent,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(height: 32),
              GameButton(
                onPressed: () {
                  ref.read(gameNotifierProvider.notifier).clearData();
                  ref.read(ghostInputProvider.notifier).clearGhostInput();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                text: 'Try Again',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
