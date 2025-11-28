import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final double? width;
  final IconData? icon;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();

    VoidCallback? effectiveOnPressed;
    if (isLoading || isDisabled) {
      effectiveOnPressed = null;
    } else {
      effectiveOnPressed = onPressed;
    }

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        else if (icon != null)
          Icon(icon, size: _getIconSize()),
        if (!isLoading) ...[
          if (icon != null) const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              text,
              style: textStyle,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: buttonStyle,
        child: buttonChild,
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor =
            isDisabled ? AppColors.buttonDisabled : AppColors.buttonPrimary;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        backgroundColor =
            isDisabled ? AppColors.buttonDisabled : AppColors.buttonSecondary;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor =
            isDisabled ? AppColors.buttonDisabled : AppColors.buttonPrimary;
        borderSide = BorderSide(
          color:
              isDisabled ? AppColors.buttonDisabled : AppColors.buttonPrimary,
          width: 1.5,
        );
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor =
            isDisabled ? AppColors.buttonDisabled : AppColors.buttonPrimary;
        break;
      case AppButtonVariant.danger:
        backgroundColor =
            isDisabled ? AppColors.buttonDisabled : AppColors.buttonDanger;
        foregroundColor = Colors.white;
        break;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: variant == AppButtonVariant.outline ||
              variant == AppButtonVariant.ghost
          ? 0
          : 2,
      shadowColor: Colors.black.withOpacity(0.2),
      side: borderSide,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.mdRadius,
      ),
      padding: _getPadding(),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        );
    }
  }

  TextStyle _getTextStyle() {
    TextStyle baseStyle;
    switch (size) {
      case AppButtonSize.small:
        baseStyle = AppTypography.labelMedium;
        break;
      case AppButtonSize.medium:
        baseStyle = AppTypography.labelLarge;
        break;
      case AppButtonSize.large:
        baseStyle = AppTypography.labelLarge.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        );
        break;
    }

    return baseStyle.copyWith(
      color: _getTextColor(),
      fontWeight: FontWeight.w600,
    );
  }

  Color _getTextColor() {
    if (variant == AppButtonVariant.outline ||
        variant == AppButtonVariant.ghost) {
      return isDisabled ? AppColors.buttonDisabled : AppColors.buttonPrimary;
    }
    return Colors.white;
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 16;
      case AppButtonSize.large:
        return 20;
    }
  }
}

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

// Shortcut constructors for common variants
class PrimaryButton extends AppButton {
  const PrimaryButton({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
    IconData? icon,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          isDisabled: isDisabled,
          variant: AppButtonVariant.primary,
          size: size,
          width: width,
          icon: icon,
        );
}

class SecondaryButton extends AppButton {
  const SecondaryButton({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    AppButtonSize size = AppButtonSize.medium,
    double? width,
    IconData? icon,
  }) : super(
          key: key,
          text: text,
          onPressed: onPressed,
          isLoading: isLoading,
          isDisabled: isDisabled,
          variant: AppButtonVariant.secondary,
          size: size,
          width: width,
          icon: icon,
        );
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonSize size;
  final double? width;
  final IconData? icon;

  const OutlineButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = AppButtonSize.medium,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      variant: AppButtonVariant.outline,
      size: size,
      width: width,
      icon: icon,
    );
  }
}

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonSize size;
  final double? width;
  final IconData? icon;

  const GhostButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = AppButtonSize.medium,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      variant: AppButtonVariant.ghost,
      size: size,
      width: width,
      icon: icon,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonSize size;
  final double? width;
  final IconData? icon;

  const DangerButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = AppButtonSize.medium,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      variant: AppButtonVariant.danger,
      size: size,
      width: width,
      icon: icon,
    );
  }
}
