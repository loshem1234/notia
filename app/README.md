# Notia Mobile App

Flutter mobile application for frictionless idea capture.

## Features (Phase 1 MVP)

✅ **Frictionless Capture**
- Voice-to-text using device speech recognition (free, offline-capable)
- Text input fallback
- Instant local save (never blocked by network/AI)

✅ **AI Categorization**
- Background categorization via Claude API
- 10 default categories (To-Do, Business Idea, Philosophical, etc.)
- Graceful degradation if API is unavailable

✅ **Browse & Search**
- List view with newest first
- Text search across note content and categories
- Filter by category
- Note details view

✅ **Local-First Storage**
- SQLite database on device
- Fast, reliable, offline-capable

## Prerequisites

- Flutter SDK 3.0.0 or later
- Dart SDK 3.0.0 or later
- For iOS: Xcode 14+ and CocoaPods
- For Android: Android Studio with Android SDK 24+

## Setup Instructions

### 1. Install Flutter

If you don't have Flutter installed:
```bash
# Visit https://docs.flutter.dev/get-started/install
# Or use your package manager
```

### 2. Install Dependencies

```bash
cd app
flutter pub get
```

### 3. Configure Backend URL

Edit `lib/services/api_service.dart` and replace the placeholder with your Railway deployment URL:

```dart
static const String baseUrl = 'https://your-app.railway.app';
```

For local testing, use:
```dart
static const String baseUrl = 'http://localhost:8000';
// On Android emulator use: 'http://10.0.2.2:8000'
```

### 4. Run the App

**iOS Simulator:**
```bash
flutter run -d iPhone
```

**Android Emulator:**
```bash
flutter run -d emulator
```

**Physical Device:**
```bash
# Connect device via USB
flutter devices  # List available devices
flutter run -d <device-id>
```

## Project Structure

```
app/
├── lib/
│   ├── models/
│   │   └── note.dart              # Note data model
│   ├── services/
│   │   ├── database_service.dart  # SQLite operations
│   │   ├── api_service.dart       # Backend API calls
│   │   └── notes_provider.dart    # State management
│   ├── screens/
│   │   ├── home_screen.dart       # Main notes list
│   │   └── capture_screen.dart    # Voice/text capture
│   ├── widgets/
│   │   └── note_card.dart         # Note display widget
│   └── main.dart                  # App entry point
├── android/                       # Android config
├── ios/                          # iOS config
└── pubspec.yaml                  # Dependencies
```

## Key Dependencies

- `sqflite` - SQLite database
- `provider` - State management
- `speech_to_text` - Voice input
- `http` - API calls
- `permission_handler` - Runtime permissions
- `home_widget` - Home screen widget (Phase 1.5)

## Troubleshooting

### Speech recognition not working

**iOS:** Make sure microphone permissions are granted in Settings > Notia

**Android:** 
1. Check microphone permission in app settings
2. Ensure Google app is installed (provides speech services)
3. Test with `adb logcat` for detailed errors

### Build errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### API connection issues

1. Check that backend is deployed and healthy: `curl https://your-app.railway.app/health`
2. Verify API URL in `api_service.dart`
3. Check CORS is enabled on backend (already configured)
4. For Android emulator, use `10.0.2.2` instead of `localhost`

## Testing

```bash
# Run unit tests
flutter test

# Run with verbose logging
flutter run --verbose
```

## Building for Release

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**iOS IPA:**
```bash
flutter build ios --release
# Then archive in Xcode
```

## Next Steps (Phase 1.5)

- [ ] Add home screen widget
- [ ] Implement quick-capture from widget
- [ ] Add widget configuration
- [ ] Test offline mode thoroughly

## Support

For issues or questions, check:
1. Backend is running: `curl <backend-url>/health`
2. Flutter doctor: `flutter doctor -v`
3. App logs: `flutter logs`
