import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool fullWidth;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BorderSide? side;
  final bool isOutlined;

  const PrimaryButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.fullWidth = true,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 50.0,
    this.width,
    this.borderRadius = 12.0,
    this.padding,
    this.elevation,
    this.side,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return isOutlined
                ? Colors.transparent
                : theme.colorScheme.primary.withOpacity(0.5);
          }
          return isOutlined
              ? Colors.transparent
              : backgroundColor ?? theme.colorScheme.primary;
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return theme.colorScheme.onSurface.withOpacity(0.38);
          }
          return isOutlined
              ? (textColor ?? theme.colorScheme.primary)
              : textColor ?? theme.colorScheme.onPrimary;
        },
      ),
      overlayColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return isOutlined
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.primary.withOpacity(0.8);
          }
          return Colors.transparent;
        },
      ),
      elevation: MaterialStateProperty.all<double>(elevation ?? 0.0),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: side ??
              (isOutlined
                  ? BorderSide(color: theme.colorScheme.primary)
                  : BorderSide.none),
        ),
      ),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        padding ?? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      ),
    );

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOutlined
                        ? (textColor ?? theme.colorScheme.primary)
                        : (textColor ?? theme.colorScheme.onPrimary),
                  ),
                ),
              )
            : child,
      ),
    );
  }
}
