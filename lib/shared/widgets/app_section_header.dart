import 'package:flutter/material.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionColor = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: actionColor),
            label: Text(actionLabel!),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
      ],
    );
  }
}
