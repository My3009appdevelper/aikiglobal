import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import 'my_image_local.dart';

class MyImage extends StatefulWidget {
  const MyImage({
    super.key,
    required this.initials,
    this.imagePath,
    this.resolveImageUrl,
    this.size = 96,
    this.borderRadius,
    this.circle = true,
    this.fit = BoxFit.cover,
  });

  final String initials;
  final String? imagePath;
  final Future<String?> Function(String imagePath)? resolveImageUrl;
  final double size;
  final BorderRadius? borderRadius;
  final bool circle;
  final BoxFit fit;

  @override
  State<MyImage> createState() => _MyImageState();
}

class _MyImageState extends State<MyImage> {
  Future<String?>? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(covariant MyImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _resolveUrl();
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.imagePath?.trim();
    final localPath = _localImagePath(imagePath);
    final directUrl = _directImageUrl(imagePath);
    final content = localPath != null
        ? buildLocalImage(
            path: localPath,
            fit: widget.fit,
            fallback: _fallback(),
          )
        : directUrl != null
        ? _ImageContent(url: directUrl, fit: widget.fit, fallback: _fallback())
        : _resolvedUrl == null
        ? _fallback()
        : FutureBuilder<String?>(
            future: _resolvedUrl,
            builder: (context, snapshot) {
              final url = snapshot.data?.trim();
              if (url == null || url.isEmpty) {
                return _fallback();
              }

              return _ImageContent(
                url: url,
                fit: widget.fit,
                fallback: _fallback(),
              );
            },
          );

    return ClipRRect(
      borderRadius: widget.circle
          ? BorderRadius.circular(widget.size / 2)
          : widget.borderRadius ?? AppRadius.medium,
      child: SizedBox(width: widget.size, height: widget.size, child: content),
    );
  }

  void _resolveUrl() {
    final imagePath = widget.imagePath?.trim();
    final resolver = widget.resolveImageUrl;
    if (imagePath == null ||
        imagePath.isEmpty ||
        _directImageUrl(imagePath) != null ||
        resolver == null) {
      _resolvedUrl = null;
      return;
    }

    _resolvedUrl = resolver(imagePath);
  }

  Widget _fallback() {
    return Container(
      width: widget.size,
      height: widget.size,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
      alignment: Alignment.center,
      child: Text(
        widget.initials,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ImageContent extends StatelessWidget {
  const _ImageContent({
    required this.url,
    required this.fit,
    required this.fallback,
  });

  final String url;
  final BoxFit fit;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: fit, errorBuilder: (_, _, _) => fallback);
    }

    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          alignment: Alignment.center,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

String? _directImageUrl(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return null;
  }

  if (imagePath.startsWith('http://') ||
      imagePath.startsWith('https://') ||
      imagePath.startsWith('assets/')) {
    return imagePath;
  }

  return null;
}

String? _localImagePath(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return null;
  }

  if (_directImageUrl(imagePath) != null) {
    return null;
  }

  final isWindowsAbsolutePath = RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(imagePath);
  final isUnixAbsolutePath = imagePath.startsWith('/');
  final isFileUri = imagePath.startsWith('file://');

  if (isWindowsAbsolutePath || isUnixAbsolutePath || isFileUri) {
    return imagePath;
  }

  return null;
}
