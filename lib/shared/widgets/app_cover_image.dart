import 'package:flutter/material.dart';

import 'my_image_local.dart';

class AppCoverImage extends StatelessWidget {
  const AppCoverImage({
    super.key,
    required this.fallback,
    this.fallbackAsset,
    this.imagePath,
    this.resolveImageUrl,
    this.fit = BoxFit.cover,
  });

  final Widget fallback;
  final String? fallbackAsset;
  final String? imagePath;
  final Future<String?> Function(String imagePath)? resolveImageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final cleanPath = imagePath?.trim();
    if (cleanPath == null || cleanPath.isEmpty) {
      return _assetOrFallback(fallbackAsset);
    }

    if (cleanPath.startsWith('assets/')) {
      return _assetOrFallback(cleanPath);
    }

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return _NetworkCover(url: cleanPath, fit: fit, fallback: fallback);
    }

    if (_isLocalPath(cleanPath)) {
      return buildLocalImage(path: cleanPath, fit: fit, fallback: fallback);
    }

    final resolver = resolveImageUrl;
    if (resolver == null) {
      return _assetOrFallback(fallbackAsset);
    }

    return FutureBuilder<String?>(
      future: resolver(cleanPath),
      builder: (context, snapshot) {
        final url = snapshot.data?.trim();
        if (url == null || url.isEmpty) {
          return _assetOrFallback(fallbackAsset);
        }

        return _NetworkCover(url: url, fit: fit, fallback: fallback);
      },
    );
  }

  Widget _assetOrFallback(String? asset) {
    final cleanAsset = asset?.trim();
    if (cleanAsset == null || cleanAsset.isEmpty) {
      return fallback;
    }

    return Image.asset(
      cleanAsset,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

class _NetworkCover extends StatelessWidget {
  const _NetworkCover({
    required this.url,
    required this.fit,
    required this.fallback,
  });

  final String url;
  final BoxFit fit;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

bool _isLocalPath(String imagePath) {
  final isWindowsAbsolutePath = RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(imagePath);
  final isUnixAbsolutePath = imagePath.startsWith('/');
  final isFileUri = imagePath.startsWith('file://');
  return isWindowsAbsolutePath || isUnixAbsolutePath || isFileUri;
}
