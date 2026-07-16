import 'package:flutter/material.dart';

import '../../../core/data/providers/app_data_scope.dart';
import '../../../shared/widgets/app_content_card.dart';
import '../models/content_item.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.item,
    this.width = 174,
    this.showBadge = false,
    this.onTap,
  });

  final ContentItem item;
  final double width;
  final bool showBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppContentCard(
      imageAsset: item.imageAsset,
      imagePath: item.imagePath,
      resolveImageUrl: AppDataScope.contentItems(context).resolveCoverImageUrl,
      title: item.title,
      subtitle: item.subtitle,
      badge: showBadge ? item.type : null,
      isNew: showBadge && item.isNew,
      favoriteIcon: item.isFavorite
          ? Icons.bookmark_rounded
          : Icons.bookmark_border_rounded,
      width: width,
      onTap: onTap,
    );
  }
}
