import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tracer/models/player_entity.dart';
import 'package:tracer/shared/extensions.dart';
import 'package:tracer/widgets/shake_widget.dart';

class TypeDisplay extends StatelessWidget {
  final String target;
  final String input;
  final PlayerEntity player;

  const TypeDisplay({
    super.key,
    required this.target,
    required this.input,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];

    for (int i = 0; i < target.length; i++) {
      final bool isUserTyped = i < input.length;
      final bool isCursor = i == input.length;
      final bool isPrevious = i == input.length - 1;

      Color color;
      if (isUserTyped) {
        color = input[i] == target[i] ? Colors.greenAccent : Colors.redAccent;
      } else if (isCursor) {
        color = Colors.white;
      } else {
        color = Colors.white70;
      }

      spans.add(
        WidgetSpan(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: isUserTyped && input[i] != target[i]
                ? ShakeWidget(
                    key: ValueKey('$i-${input[i]}'),
                    child: _buildStyledChar(
                      target[i],
                      color,
                      isCursor,
                      isPrevious,
                      ValueKey('$i-${input.length > i ? input[i] : ''}'),
                    ),
                  )
                : _buildStyledChar(
                    target[i],
                    color,
                    isCursor,
                    isPrevious,
                    ValueKey('$i-${input.length > i ? input[i] : ''}'),
                  ),
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildStyledChar(
    String char,
    Color color,
    bool isCursor,
    bool isPrevious,
    Key key,
  ) {
    final isSpace = char == ' ';
    final shouldShowUnderscore = isSpace && (isCursor || isPrevious);

    final displayChar = shouldShowUnderscore ? '_' : char;

    return Text(
      displayChar,
      key: key,
      style: TextStyle(
        fontSize: player.playerId == '-1' ? 20 : 12,
        fontFamily: 'Courier',
        color: color,
        decoration: isCursor ? TextDecoration.underline : TextDecoration.none,
      ),
    );
  }
}
