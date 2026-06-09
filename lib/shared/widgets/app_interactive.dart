import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';

class AppInteractive extends StatefulWidget {
  const AppInteractive({
    super.key,
    required this.child,
    this.onTap,
    this.tooltip,
    this.borderRadius,
    this.enabled = true,
    this.hoverScale = 1.02,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;
  final BorderRadius? borderRadius;
  final bool enabled;
  final double hoverScale;
  final double pressedScale;

  @override
  State<AppInteractive> createState() => _AppInteractiveState();
}

class _AppInteractiveState extends State<AppInteractive> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _canInteract => widget.enabled && widget.onTap != null;

  void _setHovered(bool value) {
    if (!_canInteract || _hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setPressed(bool value) {
    if (!_canInteract || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed
        ? widget.pressedScale
        : _hovered
        ? widget.hoverScale
        : 1.0;

    Widget child = MouseRegion(
      cursor: _canInteract ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => _setHovered(true),
      onExit: (_) {
        _setHovered(false);
        _setPressed(false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _canInteract ? widget.onTap : null,
        onTapDown: _canInteract ? (_) => _setPressed(true) : null,
        onTapUp: _canInteract ? (_) => _setPressed(false) : null,
        onTapCancel: _canInteract ? () => _setPressed(false) : null,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          scale: scale,
          child: widget.child,
        ),
      ),
    );

    if (_canInteract && widget.tooltip != null) {
      child = Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 450),
        showDuration: const Duration(milliseconds: 1600),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inverseSurface,
          borderRadius: widget.borderRadius ?? AppRadius.small,
        ),
        child: child,
      );
    }

    return child;
  }
}
