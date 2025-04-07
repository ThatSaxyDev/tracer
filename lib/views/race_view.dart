import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tracer/models/ghost_race_data.dart';
import 'package:tracer/models/player_entity.dart';
import 'package:tracer/notifiers/ghost_input_notifier.dart';
import 'package:tracer/shared/extensions.dart';
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
              const SizedBox(height: 14),

              Row(
                children: [
                  // AnimatedContainer(
                  //   duration: duration,
                  // ),
                  // Expanded(
                  //   child: Divider(
                  //     color: Colors.greenAccent,
                  //     thickness: 1,
                  //   ),
                  // ),
                  AnimatedLessThanSign(),
                  SignWidget(
                    painter: GreaterThanSignPainter(),
                  ),
                  // Expanded(
                  //   child: Divider(
                  //     color: Colors.redAccent,
                  //     thickness: 1,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 14),

              // if (gameState.otherPlayers.isNotEmpty)
              if (ref
                  .watch(ghostRaceDataProvider)
                  .lastSavedkeystrokes
                  .isNotEmpty)
                TypeDisplay(
                  target: gameState.targetText,
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
                      if (value.length >= gameState.player.input.length) {
                        ref
                            .read(gameNotifierProvider.notifier)
                            .updateInput(value: value);
                      } else {
                        _controller.text = gameState.player.input;
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

class GreaterThanSignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke;

    Path path = Path();

    // Define the points for the greater-than sign ">"
    Offset pointA = Offset(0, 0); // Top-left
    Offset pointB =
        Offset(size.width - 110, size.height / 2); // Right middle (moved left)
    Offset pointC = Offset(0, size.height); // Bottom-left (no change)

    // Draw the triangle-like ">" shape (inverted)
    path.moveTo(pointA.dx, pointA.dy);
    path.lineTo(pointB.dx, pointB.dy);
    path.lineTo(pointC.dx, pointC.dy);

    // Add a line to join the pointed end to the middle of the Y shape
    path.moveTo(
        size.width, size.height / 2); // Pointing end, extended to the right
    path.lineTo(size.width - 110,
        size.height / 2); // Horizontal line joining the two points

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class LessThanSignPainter extends CustomPainter {
  final Animation<double> animation;

  LessThanSignPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke;

    Path path = Path();

    Offset pointD = Offset(0, size.height / 2);

    // Define the points for the less-than sign "<"
    Offset pointA =
        Offset(size.width, 0); // Top-right (invert the "greater than" shape)
    Offset pointB =
        Offset(animation.value, size.height / 2); // Animated middle point
    Offset pointC = Offset(size.width, size.height); // Bottom-right (top point)

    // Draw the triangle-like "<" shape (inverted)
    // path.moveTo(pointA.dx, pointA.dy);
    // path.lineTo(pointB.dx, pointB.dy);
    // path.lineTo(pointC.dx, pointC.dy);

    // Add a line to join the pointed end to the middle of the Y shape
    path.moveTo(pointD.dx, pointD.dy);
    path.lineTo(pointB.dx, pointB.dy); // Horizontal line joining the two points
    path.lineTo(pointA.dx, pointA.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SignWidget extends StatelessWidget {
  final CustomPainter painter;
  const SignWidget({
    super.key,
    required this.painter,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomPaint(
        size: Size(50, 50), // Specify the size of the canvas
        painter: painter,
      ),
    );
  }
}

class AnimatedLessThanSign extends StatefulWidget {
  const AnimatedLessThanSign({super.key});

  @override
  State<AnimatedLessThanSign> createState() => _AnimatedLessThanSignState();
}

class _AnimatedLessThanSignState extends State<AnimatedLessThanSign>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // Create a tween to animate the position of the middle point (pointB)
    _animation = Tween<double>(begin: 0, end: 110.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomPaint(
        size: Size(50, 50),
        painter: LessThanSignPainter(_animation),
      ),
    );
  }
}
