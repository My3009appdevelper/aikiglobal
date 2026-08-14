import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../models/content_item.dart';
import 'content_card.dart';

class ContentHorizontalList extends StatelessWidget {
  const ContentHorizontalList({
    super.key,
    required this.items,
    this.cardWidth = 174,
    this.showBadges = false,
    this.onItemTap,
    this.onFavoriteTap,
  });

  final List<ContentItem> items;
  final double cardWidth;
  final bool showBadges;
  final ValueChanged<ContentItem>? onItemTap;
  final ValueChanged<ContentItem>? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: AppSpacing.md);
        },
        itemBuilder: (context, index) {
          final item = items[index];
          return ContentCard(
            item: item,
            width: cardWidth,
            showBadge: showBadges,
            onTap: onItemTap == null ? null : () => onItemTap!(item),
            onFavoriteTap: onFavoriteTap == null
                ? null
                : () => onFavoriteTap!(item),
          );
        },
      ),
    );
  }
}
