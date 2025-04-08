import 'package:flutter/material.dart';
import 'package:tracer/widgets/animated_sign.dart/tracer_insignia.dart';

class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSelected;
  final Color? buttonColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final double elevation;
  final double fontSize;
  final IconData? leadingIcon;
  final Widget? trailingWidget;
  final bool showSelectionIndicator;
  final EdgeInsetsGeometry? padding;
  final bool isJustText;

  const GameButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSelected = false,
    this.buttonColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.elevation = 4.0,
    this.fontSize = 22.0,
    this.leadingIcon,
    this.trailingWidget,
    this.showSelectionIndicator = true,
    this.padding,
    this.isJustText = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color defaultButtonColor =
        buttonColor ?? Theme.of(context).primaryColor;
    final Color defaultTextColor = textColor ?? Colors.white;

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: defaultButtonColor.withOpacity(0.4),
            blurRadius: isSelected ? 8 : 4,
            spreadRadius: isSelected ? 1 : 0,
            offset: Offset(0, isSelected ? 2 : 1),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: defaultButtonColor,
          foregroundColor: defaultTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: isSelected ? Colors.white70 : Colors.transparent,
              width: 1.5,
            ),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 32,
              ),
          elevation: isSelected ? elevation * 1.5 : elevation,
        ),
        onPressed: onPressed,
        child: isJustText
            ? Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (leadingIcon != null) ...[
                        Icon(leadingIcon, color: defaultTextColor, size: 20),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      // if (trailingIcon != null) ...[
                      //   const SizedBox(width: 12),
                      //   Icon(trailingIcon, color: defaultTextColor, size: 20),
                      // ],
                    ],
                  ),

                  // Selected indicator
                  if (isSelected && showSelectionIndicator)
                    Positioned(
                      right: 0,
                      child: TracerInsignia(
                        height: 10,
                        width: 35,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
