import 'package:flutter/material.dart';

import 'app/aiki_app.dart';
import 'core/data/providers/app_data_container.dart';
import 'core/theme/app_theme_controller.dart';

const resetLocalDatabaseOnStart = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dataContainer = await AppDataContainer.create(
    resetLocalDatabaseOnStart: resetLocalDatabaseOnStart,
  );

  runApp(
    AikiApp(
      themeController: AppThemeController(),
      dataContainer: dataContainer,
    ),
  );
}
