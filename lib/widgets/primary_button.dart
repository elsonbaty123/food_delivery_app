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
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return isOutlined
                ? Colors.transparent
                : theme.colorScheme.primary.withAlpha(128); // 0.5 opacity
          }
          return isOutlined
              ? Colors.transparent
              : backgroundColor ?? theme.colorScheme.primary;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return theme.colorScheme.onSurface.withAlpha(97); // 0.38 opacity
          }
          return isOutlined
              ? (textColor ?? theme.colorScheme.primary)
              : textColor ?? theme.colorScheme.onPrimary;
        },
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return isOutlined
                ? theme.colorScheme.primary.withAlpha(26) // 0.1 opacity
                : theme.colorScheme.primary.withAlpha(204); // 0.8 opacity
          }
          return Colors.transparent;
        },
      ),
      elevation: WidgetStateProperty.all<double>(elevation ?? 0.0),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: side ??
              (isOutlined
                  ? BorderSide(color: theme.colorScheme.primary)
                  : BorderSide.none),
        ),
      ),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
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

