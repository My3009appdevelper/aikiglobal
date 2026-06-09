import 'package:flutter/material.dart';

import '../../../shared/widgets/app_content_card.dart';
import '../models/content_item.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.item,
    this.width = 174,
    this.onTap,
  });

  final ContentItem item;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppContentCard(
      imageAsset: item.imageAsset,
      title: item.title,
      subtitle: item.subtitle,
      badge: item.type,
      isNew: item.isNew,
      favoriteIcon: item.isFavorite
          ? Icons.bookmark_rounded
          : Icons.bookmark_border_rounded,
      width: width,
      onTap: onTap,
    );
  }
}
