import 'package:flutter/material.dart';

import 'app_background.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.backgroundImage,
    this.resizeToAvoidBottomInset,
  });

  final Widget child;
  final String? backgroundImage;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: AppBackground(
        imageAsset: backgroundImage,
        child: SafeArea(child: child),
      ),
    );
  }
}
