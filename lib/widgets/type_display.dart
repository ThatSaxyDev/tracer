import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tracer/models/player_entity.dart';
import 'package:tracer/shared/extensions.dart';
import 'package:tracer/widgets/shake_widget.dart';

class TypeDisplay extends StatefulWidget {
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
  State<TypeDisplay> createState() => _TypeDisplayState();
}

class _TypeDisplayState extends State<TypeDisplay> {
  final ScrollController _scrollController = ScrollController();
  String _previousInput = '';
  bool _isScrolling = false;
  // Debounce timer to reduce calculations
  DateTime _lastScrollTime = DateTime.now();

  @override
  void didUpdateWidget(TypeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only process if input changed
    if (widget.input != _previousInput) {
      _previousInput = widget.input;

      // Debounce scrolling calculations to avoid excessive processing
      final now = DateTime.now();
      if (now.difference(_lastScrollTime).inMilliseconds > 100) {
        _lastScrollTime = now;

        // Only schedule a scroll if we're not already scrolling
        if (!_isScrolling) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToCurrentPosition();
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentPosition() {
    if (!_scrollController.hasClients || widget.target.isEmpty) return;

    _isScrolling = true;

    try {
      // Simple formula to calculate a target scroll position
      final viewportHeight = _scrollController.position.viewportDimension;
      final contentHeight =
          _scrollController.position.maxScrollExtent + viewportHeight;

      // Very simple estimation - assumes text is evenly distributed
      final progress = widget.input.length / widget.target.length;
      final targetOffset = (contentHeight * progress) - (viewportHeight * 0.5);

      // Clamp to valid range and avoid tiny movements
      final clampedOffset =
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
      if ((clampedOffset - _scrollController.offset).abs() > 15) {
        _scrollController
            .animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        )
            .then((_) {
          _isScrolling = false;
        });
      } else {
        _isScrolling = false;
      }
    } catch (e) {
      _isScrolling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];

    for (int i = 0; i < widget.target.length; i++) {
      final bool isUserTyped = i < widget.input.length;
      final bool isCursor = i == widget.input.length;
      final bool isPrevious = i == widget.input.length - 1;

      Color color;
      if (isUserTyped) {
        color = widget.input[i] == widget.target[i]
            ? Colors.greenAccent
            : Colors.redAccent;
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
            child: isUserTyped && widget.input[i] != widget.target[i]
                ? ShakeWidget(
                    key: ValueKey('$i-${widget.input[i]}'),
                    child: _buildStyledChar(
                      widget.target[i],
                      color,
                      isCursor,
                      isPrevious,
                      ValueKey(
                          '$i-${widget.input.length > i ? widget.input[i] : ''}'),
                    ),
                  )
                : _buildStyledChar(
                    widget.target[i],
                    color,
                    isCursor,
                    isPrevious,
                    ValueKey(
                        '$i-${widget.input.length > i ? widget.input[i] : ''}'),
                  ),
          ),
        ),
      );
    }

    return ClipRRect(
      child: SizedBox(
        height: widget.player.playerId == '-1' ? 150 : 70,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 5),
          physics: const ClampingScrollPhysics(
              parent:
                  NeverScrollableScrollPhysics()), // Prevents overscroll bounce
          child: RichText(
            text: TextSpan(children: spans),
          ),
        ),
      ),
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
        fontSize: widget.player.playerId == '-1' ? 20 : 12,
        fontFamily: 'Courier',
        color: color,
        decoration: isCursor ? TextDecoration.underline : TextDecoration.none,
      ),
    );
  }
}
