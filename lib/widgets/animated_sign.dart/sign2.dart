import 'package:flutter/material.dart';

enum ArrowDirection { left, right }

class AnimatedSign2 extends StatefulWidget {
  final ArrowDirection direction;
  final double? progress; // Optional progress value for the progress indicator
  final bool
      isIndefinite; // Flag to toggle between repeat or progress indicator

  const AnimatedSign2({
    super.key,
    required this.direction,
    this.progress, // Optional
    this.isIndefinite = true, // Default to repeat loader
  });

  @override
  State<AnimatedSign2> createState() => _AnimatedSign2State();
}

class _AnimatedSign2State extends State<AnimatedSign2>
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

    _lineAnimation = Tween<double>(begin: 0, end: 50).animate(
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

    // Start animation based on the type (repeat or progress-driven)
    if (widget.isIndefinite) {
      _controller
        ..forward()
        ..repeat(reverse: true);
    } else if (widget.progress != null) {
      // Use the progress value to drive the animation
      _controller.value = widget.progress!;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSign2 oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If progress is provided and widget is not indefinite, update the controller
    if (widget.progress != oldWidget.progress && widget.progress != null) {
      _controller.value = widget.progress!;
    }

    // If changing to indefinite mode, start repeat animation
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
    return Expanded(
      child: CustomPaint(
        size: const Size(170, 50),
        painter: switch (widget.direction) {
          ArrowDirection.left => LeftSignPainter(
              _lineAnimation,
              _arrowAnimation,
              _endAnimation,
            ),
          ArrowDirection.right => RightSignPainter(
              _lineAnimation,
              _arrowAnimation,
              _endAnimation,
            ),
        },
      ),
    );
  }
}

class RightSignPainter extends CustomPainter {
  final Animation<double> lineAnimation;
  final Animation<double> arrowAnimation;
  final Animation<double> endAnimation;

  RightSignPainter(
    this.lineAnimation,
    this.arrowAnimation,
    this.endAnimation,
  ) : super(
            repaint: Listenable.merge([
          lineAnimation,
          arrowAnimation,
          endAnimation,
        ]));

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke;

    final Path path = Path();

    // Line starts at right and animates to the left, using relative size
    final Offset start = Offset(size.width, size.height / 2);
    final Offset end = Offset(
        size.width - lineAnimation.value * size.width / 110, size.height / 2);

    // Draw horizontal line
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    // Draw animated arrow lines
    if (arrowAnimation.value > 0) {
      final Offset bottomTarget = Offset(0, size.height);
      final Offset bottom =
          Offset.lerp(end, bottomTarget, arrowAnimation.value)!;

      path.moveTo(end.dx, end.dy);
      path.lineTo(bottom.dx, bottom.dy);
    }

    // Draw second arrow line (bottom) with endAnimation
    if (endAnimation.value > 0) {
      final Offset fixedBottom =
          Offset(0, size.height); // or wherever your arrow tip ends
      final Offset topTarget = Offset(-60, size.height / 2);

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

  LeftSignPainter(
    this.lineAnimation,
    this.arrowAnimation,
    this.endAnimation,
  ) : super(
            repaint: Listenable.merge([
          lineAnimation,
          arrowAnimation,
          endAnimation,
        ]));

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke;

    final Path path = Path();

    final Offset start = Offset(0, size.height / 2);
    final Offset end =
        Offset(lineAnimation.value * size.width / 110, size.height / 2);

    // Draw horizontal line
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    // Draw first arrow line (top)
    if (arrowAnimation.value > 0) {
      final Offset topTarget = Offset(size.width, 0);
      final Offset top = Offset.lerp(end, topTarget, arrowAnimation.value)!;

      path.moveTo(end.dx, end.dy);
      path.lineTo(top.dx, top.dy);
    }

    // Draw second arrow line (bottom) with endAnimation
    if (endAnimation.value > 0) {
      final Offset fixedTop =
          Offset(size.width, 0); // or wherever your arrow tip ends
      final Offset bottomTarget = Offset(size.width + 60, size.height / 2);

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
