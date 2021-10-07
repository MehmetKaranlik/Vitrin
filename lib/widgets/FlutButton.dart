import 'package:flutter/material.dart';

enum FlutButtonType { elevated, outline, text }

class FlutButton extends StatelessWidget {
  final FlutButtonType buttonType;

  final ButtonStyle? style;

  final VoidCallback onPressed;
  final MaterialStateProperty<EdgeInsetsGeometry>? msPadding;
  final EdgeInsetsGeometry? padding;

  final MaterialStateProperty<EdgeInsetsGeometry>? msShape;
  final OutlinedBorder? shape;
  final BorderRadiusGeometry? borderRadius;
  final double borderRadiusAll;

  final MaterialStateProperty<Color>? msBackgroundColor;
  final Color? backgroundColor;
  final MaterialStateProperty<Color>? msShadowColor;
  final Color? shadowColor;

  final Widget child;

  FlutButton(
      {required this.onPressed,
      required this.child,
      this.msPadding,
      this.padding,
      this.msShape,
      this.shape,
      this.borderRadius,
      this.borderRadiusAll = 0,
      this.msBackgroundColor,
      this.backgroundColor,
      this.buttonType = FlutButtonType.elevated,
      this.style,
      this.msShadowColor,
      this.shadowColor});

  FlutButton.rounded(
      {required this.onPressed,
      required this.child,
      this.msPadding,
      this.padding,
      this.msShape,
      this.shape,
      this.borderRadius,
      this.borderRadiusAll = 4,
      this.msBackgroundColor,
      this.backgroundColor,
      this.buttonType = FlutButtonType.elevated,
      this.style,
      this.msShadowColor,
      this.shadowColor});

  FlutButton.small(
      {required this.onPressed,
      required this.child,
      this.msPadding,
      this.padding = const EdgeInsets.fromLTRB(8, 4, 8, 4),
      this.msShape,
      this.shape,
      this.borderRadius,
      this.borderRadiusAll = 0,
      this.msBackgroundColor,
      this.backgroundColor,
      this.buttonType = FlutButtonType.elevated,
      this.style,
      this.msShadowColor,
      this.shadowColor});

  FlutButton.medium(
      {required this.onPressed,
      required this.child,
      this.msPadding,
      this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 12),
      this.msShape,
      this.shape,
      this.borderRadius,
      this.borderRadiusAll = 0,
      this.msBackgroundColor,
      this.backgroundColor,
      this.buttonType = FlutButtonType.elevated,
      this.style,
      this.msShadowColor,
      this.shadowColor});

  FlutButton.large(
      {required this.onPressed,
      required this.child,
      this.msPadding,
      this.padding = const EdgeInsets.fromLTRB(36, 16, 36, 16),
      this.msShape,
      this.shape,
      this.borderRadius,
      this.borderRadiusAll = 0,
      this.msBackgroundColor,
      this.backgroundColor,
      this.buttonType = FlutButtonType.elevated,
      this.style,
      this.msShadowColor,
      this.shadowColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: style ??
            ButtonStyle(
                backgroundColor: msBackgroundColor ??
                    MaterialStateProperty.all(backgroundColor),
                shadowColor:
                    msShadowColor ?? MaterialStateProperty.all(shadowColor),
                padding: msPadding ?? MaterialStateProperty.all(padding),
                shape: msShape as MaterialStateProperty<OutlinedBorder?>? ??
                    MaterialStateProperty.all(shape ??
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadiusAll),
                        ))),
        onPressed: onPressed,
        child: child);
  }
}
