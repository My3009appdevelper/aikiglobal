import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBackground extends StatefulWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.imageAsset,
    this.imageOpacity = 0.08,
    this.showGeometry = true,
    this.animateEntry = false,
    this.entryDuration = const Duration(milliseconds: 1200),
    this.entryCurve = Curves.easeOut,
    this.contentDelay = Duration.zero,
  });

  final Widget child;
  final String? imageAsset;
  final double imageOpacity;
  final bool showGeometry;
  final bool animateEntry;
  final Duration entryDuration;
  final Curve entryCurve;
  final Duration contentDelay;

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _backgroundOpacity;
  late Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.entryDuration,
      value: widget.animateEntry ? 0.0 : 1.0,
    );

    _configureAnimations();

    if (widget.animateEntry) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AppBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.entryDuration != widget.entryDuration) {
      _controller.duration = widget.entryDuration;
    }

    if (oldWidget.entryCurve != widget.entryCurve ||
        oldWidget.contentDelay != widget.contentDelay) {
      _configureAnimations();
    }

    if (oldWidget.animateEntry != widget.animateEntry) {
      if (widget.animateEntry) {
        _controller
          ..stop()
          ..reset()
          ..forward();
      } else {
        _controller
          ..stop()
          ..value = 1.0;
      }
    }
  }

  void _configureAnimations() {
    _backgroundOpacity = CurvedAnimation(
      parent: _controller,
      curve: widget.entryCurve,
    );

    final delayFraction = _delayFraction();
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delayFraction, 1.0, curve: widget.entryCurve),
      ),
    );
  }

  double _delayFraction() {
    if (!widget.animateEntry ||
        widget.entryDuration <= Duration.zero ||
        widget.contentDelay <= Duration.zero) {
      return 0.0;
    }

    final totalMs = widget.entryDuration.inMilliseconds.toDouble();
    if (totalMs <= 0) return 1.0;
    return (widget.contentDelay.inMilliseconds / totalMs).clamp(0.0, 0.95);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  AppColors.darkBackground,
                  AppColors.darkSurface,
                  AppColors.primaryDeep,
                ]
              : const [
                  AppColors.ivory,
                  AppColors.warmIvory,
                  AppColors.sandLight,
                ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.imageAsset != null)
            AnimatedBuilder(
              animation: _backgroundOpacity,
              builder: (_, child) => Opacity(
                opacity: widget.imageOpacity * _backgroundOpacity.value,
                child: Image.asset(
                  widget.imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          if (widget.showGeometry)
            Stack(
              children: [
                Positioned(
                  top: -110,
                  right: -120,
                  child: _SacredGeometry(
                    size: 360,
                    color: isDark
                        ? AppColors.sand.withValues(alpha: 0.08)
                        : AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
                Positioned(
                  bottom: 110,
                  left: -180,
                  child: _SacredGeometry(
                    size: 320,
                    color: isDark
                        ? AppColors.sand.withValues(alpha: 0.05)
                        : AppColors.primary.withValues(alpha: 0.04),
                  ),
                ),
              ],
            ),
          FadeTransition(opacity: _contentOpacity, child: widget.child),
        ],
      ),
    );
  }
}

class _SacredGeometry extends StatelessWidget {
  const _SacredGeometry({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _SacredGeometryPainter(color)),
    );
  }
}

class _SacredGeometryPainter extends CustomPainter {
  const _SacredGeometryPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 4.4;

    for (var ring = 0; ring < 3; ring++) {
      final ringRadius = radius * (1 + ring * 0.34);
      for (var i = 0; i < 12; i++) {
        final angle = (math.pi * 2 / 12) * i;
        final offset = Offset(
          math.cos(angle) * ringRadius * 0.72,
          math.sin(angle) * ringRadius * 0.72,
        );
        canvas.drawCircle(center + offset, ringRadius, paint);
      }
    }
    canvas.drawCircle(center, radius * 2.25, paint);
    canvas.drawCircle(center, radius * 1.45, paint);
  }

  @override
  bool shouldRepaint(covariant _SacredGeometryPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
