import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_companion/app.dart';
import 'package:student_companion/providers/app_preferences_provider.dart';
import 'package:student_companion/providers/theme_provider.dart';
import 'package:student_companion/services/preferences_service.dart';

void main() {
  testWidgets('shows onboarding entry point', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferencesService = await PreferencesService.create();
    final appPreferences = AppPreferencesProvider(preferencesService);
    final themeProvider = ThemeProvider(preferencesService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appPreferences),
          ChangeNotifierProvider.value(value: themeProvider),
        ],
        child: const StudentCompanionApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Student Companion'), findsWidgets);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
