import 'package:aikiglobal/app/aiki_theme_host.dart';
import 'package:aikiglobal/app/app_theme_transition.dart';
import 'package:aikiglobal/core/theme/app_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('theme host updates theme without remounting its child', (
    tester,
  ) async {
    final controller = AppThemeController();
    final scrollController = ScrollController();
    var initCount = 0;
    var disposeCount = 0;
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      AikiThemeHost(
        controller: controller,
        child: _StatefulScrollable(
          scrollController: scrollController,
          onInit: () => initCount += 1,
          onDispose: () => disposeCount += 1,
        ),
      ),
    );

    expect(initCount, 1);
    expect(disposeCount, 0);
    expect(
      Theme.of(tester.element(find.text('Themed child'))).brightness,
      Brightness.light,
    );

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pump();
    final offsetBeforeThemeChange = scrollController.offset;

    controller.setThemeMode(ThemeMode.dark);
    await tester.pump();

    expect(initCount, 1);
    expect(disposeCount, 0);
    expect(scrollController.offset, offsetBeforeThemeChange);

    await tester.pump(appThemeAnimationDuration);

    expect(
      Theme.of(tester.element(find.text('Themed child'))).brightness,
      Brightness.dark,
    );
  });
}

class _StatefulScrollable extends StatefulWidget {
  const _StatefulScrollable({
    required this.scrollController,
    required this.onInit,
    required this.onDispose,
  });

  final ScrollController scrollController;
  final VoidCallback onInit;
  final VoidCallback onDispose;

  @override
  State<_StatefulScrollable> createState() => _StatefulScrollableState();
}

class _StatefulScrollableState extends State<_StatefulScrollable> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: SizedBox(
          height: 1200,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              'Themed child',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}
