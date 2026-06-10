# Student Companion Mobile

Flutter mobile application for Student Companion.

## Phase 1
This phase includes the Flutter scaffold, Material 3 theme, Provider setup, SharedPreferences integration, anonymous device ID generation, onboarding state, and bottom navigation shell.

## Run
```bash
flutter pub get
flutter run
```

Use `--dart-define=API_BASE_URL=http://your-backend-url` when testing with a deployed backend later. The app adds `/api/...` inside the service classes, so the base URL should not end with `/api`.
