import 'package:flutter/material.dart';

class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.displacement = 48,
    this.edgeOffset = 0,
  });

  final RefreshCallback onRefresh;
  final Widget child;
  final double displacement;
  final double edgeOffset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return RefreshIndicator.adaptive(
      color: scheme.primary,
      backgroundColor: scheme.surface,
      displacement: displacement,
      edgeOffset: edgeOffset,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
