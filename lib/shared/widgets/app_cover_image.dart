import 'package:flutter/material.dart';

import 'my_image_local.dart';

class AppCoverImage extends StatefulWidget {
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
  State<AppCoverImage> createState() => _AppCoverImageState();
}

class _AppCoverImageState extends State<AppCoverImage> {
  String? _resolvedPath;
  String? _resolvedUrl;
  Future<String?>? _resolvedUrlFuture;

  @override
  void initState() {
    super.initState();
    _prepareResolvedUrl();
  }

  @override
  void didUpdateWidget(covariant AppCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPath = oldWidget.imagePath?.trim();
    final nextPath = widget.imagePath?.trim();
    final resolverBecameAvailable =
        oldWidget.resolveImageUrl == null && widget.resolveImageUrl != null;

    if (oldPath != nextPath || resolverBecameAvailable) {
      _prepareResolvedUrl();
    }
  }

  void _prepareResolvedUrl() {
    final cleanPath = widget.imagePath?.trim();
    final resolver = widget.resolveImageUrl;

    _resolvedPath = null;
    _resolvedUrl = null;
    _resolvedUrlFuture = null;

    if (cleanPath == null ||
        cleanPath.isEmpty ||
        cleanPath.startsWith('assets/') ||
        cleanPath.startsWith('http://') ||
        cleanPath.startsWith('https://') ||
        _isLocalPath(cleanPath) ||
        resolver == null) {
      return;
    }

    _resolvedPath = cleanPath;
    _resolvedUrlFuture = _resolveSafely(resolver, cleanPath).then((url) {
      final cleanUrl = url?.trim();
      if (_resolvedPath == cleanPath) {
        _resolvedUrl = cleanUrl;
      }
      return cleanUrl;
    });
  }

  Future<String?> _resolveSafely(
    Future<String?> Function(String imagePath) resolver,
    String imagePath,
  ) async {
    try {
      return await resolver(imagePath);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanPath = widget.imagePath?.trim();
    if (cleanPath == null || cleanPath.isEmpty) {
      return _assetOrFallback(widget.fallbackAsset);
    }

    if (cleanPath.startsWith('assets/')) {
      return _assetOrFallback(cleanPath);
    }

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return _NetworkCover(
        url: cleanPath,
        fit: widget.fit,
        fallback: widget.fallback,
      );
    }

    if (_isLocalPath(cleanPath)) {
      return buildLocalImage(
        path: cleanPath,
        fit: widget.fit,
        fallback: widget.fallback,
      );
    }

    if (widget.resolveImageUrl == null) {
      return _assetOrFallback(widget.fallbackAsset);
    }

    final cachedUrl = _resolvedUrl?.trim();
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      return _NetworkCover(
        url: cachedUrl,
        fit: widget.fit,
        fallback: widget.fallback,
      );
    }

    return FutureBuilder<String?>(
      future: _resolvedUrlFuture,
      builder: (context, snapshot) {
        final url = snapshot.data?.trim();
        if (url == null || url.isEmpty) {
          return _assetOrFallback(widget.fallbackAsset);
        }

        return _NetworkCover(
          url: url,
          fit: widget.fit,
          fallback: widget.fallback,
        );
      },
    );
  }

  Widget _assetOrFallback(String? asset) {
    final cleanAsset = asset?.trim();
    if (cleanAsset == null || cleanAsset.isEmpty) {
      return widget.fallback;
    }

    return Image.asset(
      cleanAsset,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) => widget.fallback,
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
      gaplessPlayback: true,
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
