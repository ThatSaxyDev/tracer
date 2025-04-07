import 'package:flutter/material.dart';

enum ArrowDirection { left, right }

class AnimatedSign extends StatefulWidget {
  final ArrowDirection direction;
  final double? progress; // Optional progress value for the progress indicator
  final bool
      isIndefinite; // Flag to toggle between repeat or progress indicator

  const AnimatedSign({
    super.key,
    required this.direction,
    this.progress,
    this.isIndefinite = true, // Default to repeat loader
  });

  @override
  State<AnimatedSign> createState() => _AnimatedSignState();
}

class _AnimatedSignState extends State<AnimatedSign>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lineAnimation;
  late Animation<double> _arrowAnimation;
  late Animation<double> _endAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _arrowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _endAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.isIndefinite) {
      _controller
        ..forward()
        ..repeat(reverse: true);
    } else if (widget.progress != null) {
      _controller.value = widget.progress!;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSign oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.progress != oldWidget.progress && widget.progress != null) {
      _controller.value = widget.progress!;
    }

    if (widget.isIndefinite != oldWidget.isIndefinite && widget.isIndefinite) {
      _controller
        ..forward()
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        return CustomPaint(
          size: Size(width, height),
          painter: widget.direction == ArrowDirection.left
              ? LeftSignPainter(
                  _lineAnimation, _arrowAnimation, _endAnimation, width, height)
              : RightSignPainter(_lineAnimation, _arrowAnimation, _endAnimation,
                  width, height),
        );
      },
    );
  }
}

class RightSignPainter extends CustomPainter {
  final Animation<double> lineAnimation;
  final Animation<double> arrowAnimation;
  final Animation<double> endAnimation;
  final double width;
  final double height;

  RightSignPainter(
    this.lineAnimation,
    this.arrowAnimation,
    this.endAnimation,
    this.width,
    this.height,
  ) : super(
            repaint: Listenable.merge([
          lineAnimation,
          arrowAnimation,
          endAnimation,
        ]));

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    final Path path = Path();

    final Offset start = Offset(width, height / 2);
    final Offset end =
        Offset((width + 5) - ((lineAnimation.value * width) / 2), height / 2);

    // Draw horizontal line
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    // Draw animated arrow lines
    if (arrowAnimation.value > 0) {
      final Offset bottomTarget = Offset((width / 2) + 5, height);
      final Offset bottom =
          Offset.lerp(end, bottomTarget, arrowAnimation.value)!;

      path.moveTo(end.dx, end.dy);
      path.lineTo(bottom.dx, bottom.dy);
    }

    // Draw second arrow line (bottom) with endAnimation
    if (endAnimation.value > 0) {
      final Offset fixedBottom = Offset((width / 2) + 5, height);
      final Offset topTarget = Offset(0, height / 2);

      final Offset animatedTop =
          Offset.lerp(fixedBottom, topTarget, endAnimation.value)!;

      path.moveTo(fixedBottom.dx, fixedBottom.dy);
      path.lineTo(animatedTop.dx, animatedTop.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LeftSignPainter extends CustomPainter {
  final Animation<double> lineAnimation;
  final Animation<double> arrowAnimation;
  final Animation<double> endAnimation;
  final double width;
  final double height;

  LeftSignPainter(
    this.lineAnimation,
    this.arrowAnimation,
    this.endAnimation,
    this.width,
    this.height,
  ) : super(
            repaint: Listenable.merge([
          lineAnimation,
          arrowAnimation,
          endAnimation,
        ]));

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color.fromARGB(255, 189, 141, 197)
      ..style = PaintingStyle.stroke;

    final Path path = Path();

    final Offset start = Offset(0, height / 2);
    final Offset end =
        Offset(((lineAnimation.value * width) / 2) - 5, height / 2);

    // Draw horizontal line
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    // Draw first arrow line (top)
    if (arrowAnimation.value > 0) {
      final Offset topTarget = Offset((width / 2) - 5, 0);
      final Offset top = Offset.lerp(end, topTarget, arrowAnimation.value)!;

      path.moveTo(end.dx, end.dy);
      path.lineTo(top.dx, top.dy);
    }

    // Draw second arrow line (bottom) with endAnimation
    if (endAnimation.value > 0) {
      final Offset fixedTop = Offset((width / 2) - 5, 0);
      final Offset bottomTarget = Offset(width, height / 2);

      final Offset animatedBottom =
          Offset.lerp(fixedTop, bottomTarget, endAnimation.value)!;

      path.moveTo(fixedTop.dx, fixedTop.dy);
      path.lineTo(animatedBottom.dx, animatedBottom.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
