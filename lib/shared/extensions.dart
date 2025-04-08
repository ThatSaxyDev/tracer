import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';

/// Extension for creating a ValueNotifier from a value directly.
extension ValueNotifierExtension<T> on T {
  ValueNotifier<T> get notifier {
    return ValueNotifier<T>(this);
  }
}

/// extension for listening to ValueNotifier instances.
extension ValueNotifierBuilderExtension<T> on ValueNotifier<T> {
  Widget sync({
    required Widget Function(BuildContext context, T value, Widget? child)
        builder,
  }) {
    return ValueListenableBuilder<T>(
      valueListenable: this,
      builder: builder,
    );
  }
}

extension ListenableBuilderExtension on List<Listenable> {
  Widget multiSync({
    required Widget Function(BuildContext context, Widget? child) builder,
  }) {
    return ListenableBuilder(
      listenable: Listenable.merge(this),
      builder: builder,
    );
  }
}

//! quality of life fade animations from flutter_animate
extension WidgetAnimation on Widget {
  Animate fadeInFromTop({
    Duration? delay,
    Duration? animationDuration,
    Offset? offset,
  }) =>
      animate(delay: delay ?? 500.ms)
          .move(
            duration: animationDuration ?? 500.ms,
            begin: offset ?? const Offset(0, -10),
          )
          .fade(duration: animationDuration ?? 500.ms);

  Animate fadeInFromBottom({
    Duration? delay,
    Duration? animationDuration,
    AnimationController? controller,
    Offset? offset,
  }) =>
      animate(delay: delay ?? 500.ms, controller: controller)
          .move(
            duration: animationDuration ?? 500.ms,
            begin: offset ?? const Offset(0, 10),
          )
          .fade(duration: animationDuration ?? 500.ms);

  Animate fadeIn({
    Duration? delay,
    Duration? animationDuration,
    Curve? curve,
  }) =>
      animate(delay: delay ?? 500.ms).fade(
        duration: animationDuration ?? 500.ms,
        curve: curve ?? Curves.decelerate,
      );
}

class NoPasteFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > oldValue.text.length &&
        newValue.text.length - oldValue.text.length > 3) {
      // This is likely a paste operation
      return oldValue;
    }
    return newValue;
  }
}
