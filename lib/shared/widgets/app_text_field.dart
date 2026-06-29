import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTapOutside,
    this.minLines,
    this.maxLines = 1,
  });

  final String hintText;
  final String? labelText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final TapRegionCallback? onTapOutside;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      minLines: obscureText ? 1 : minLines,
      maxLines: obscureText ? 1 : maxLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      onTapOutside: onTapOutside,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: labelText == hintText ? null : hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: muted),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
