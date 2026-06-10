import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/app_preferences_provider.dart';
import 'providers/confession_provider.dart';
import 'providers/interest_provider.dart';
import 'providers/student_provider.dart';
import 'providers/support_resource_provider.dart';
import 'providers/theme_provider.dart';
import 'services/confession_service.dart';
import 'services/interest_service.dart';
import 'services/preferences_service.dart';
import 'services/student_service.dart';
import 'services/support_resource_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesService = await PreferencesService.create();
  final preferencesProvider = AppPreferencesProvider(preferencesService);
  await preferencesProvider.load();

  final themeProvider = ThemeProvider(preferencesService);
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: preferencesProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(
          create: (_) => ConfessionProvider(ConfessionService()),
        ),
        ChangeNotifierProvider(
          create: (_) => SupportResourceProvider(SupportResourceService()),
        ),
        ChangeNotifierProvider(
          create:
              (_) => InterestProvider(InterestService(), preferencesService),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentProvider(StudentService()),
        ),
      ],
      child: const StudentCompanionApp(),
    ),
  );
}
