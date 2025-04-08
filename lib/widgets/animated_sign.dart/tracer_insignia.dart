// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:tracer/widgets/animated_sign.dart/animated_sign.dart';

class TracerInsignia extends StatelessWidget {
  final double? height;
  final double? width;
  const TracerInsignia({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 200,
      height: height ?? 40,
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
    );
  }
}
