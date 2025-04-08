// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:tracer/widgets/animated_sign.dart/animated_sign.dart';

class TracerInsignia extends StatelessWidget {
  final double? height;
  final double? width;
  final double? leftProgress;
  final double? rightProgress;
  final bool isIndefinite;
  const TracerInsignia({
    super.key,
    this.height,
    this.width,
    this.leftProgress,
    this.rightProgress,
    this.isIndefinite = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 200,
      height: height ?? 40,
      child: Stack(
        children: [
          AnimatedSign(
            progress: leftProgress,
            isIndefinite: isIndefinite,
            direction: ArrowDirection.left,
          ),
          AnimatedSign(
            progress: rightProgress,
            isIndefinite: isIndefinite,
            direction: ArrowDirection.right,
          ),
        ],
      ),
    );
  }
}
