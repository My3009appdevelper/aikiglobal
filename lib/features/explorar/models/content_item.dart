class ContentItem {
  const ContentItem({
    required this.title,
    required this.type,
    required this.duration,
    required this.imageAsset,
    this.uuidContentItem,
    this.imagePath,
    this.description,
    this.lessons,
    this.isNew = false,
    this.isFavorite = false,
  });

  final String? uuidContentItem;
  final String title;
  final String type;
  final String duration;
  final String imageAsset;
  final String? imagePath;
  final String? description;
  final int? lessons;
  final bool isNew;
  final bool isFavorite;

  String get subtitle {
    if (lessons != null) return '$lessons lecciones · $duration';
    return '$type · $duration';
  }
}
