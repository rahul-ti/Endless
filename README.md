# Endless Arithmetic

Endless Arithmetic is a small Flutter practice app for mental-math topics commonly used in Indian MBA competitive exams. It continuously generates multiplication, square, cube, and reciprocal-percentage questions. Entering the exact correct answer clears the field and immediately loads the next question.

## Project shape

- `lib/main.dart` contains the question generator and the complete UI.
- `test/widget_test.dart` covers every question type and the answer-to-next-question flow.
- `web/` is the generated Flutter web runner used for the quickest local setup.
- `android/` and `ios/` contain the original mobile runners; their platform SDKs are optional for web development.

The app has no backend, database, environment variables, accounts, or third-party runtime packages.

## Local setup

Install Flutter 3.47.0 (which includes Dart 3.13.0), then run from this
directory:

```sh
flutter pub get
flutter run -d chrome
```

## Android debug APK

The verified Android toolchain is Flutter 3.47.0, Dart 3.13.0, JDK 17,
Android SDK/API 36, and Android Build Tools 36.0.0. Confirm it with:

```sh
flutter doctor -v
```

Build a debug APK with:

```sh
flutter build apk --debug
```

The resulting APK is at
`build/app/outputs/flutter-apk/app-debug.apk`. It is intended for direct
testing; Play Store distribution requires a separately signed release AAB and
upload key.

Useful verification commands:

```sh
flutter analyze
flutter test
flutter build web
```

Android builds require Android Studio and an Android SDK. iOS builds require a
full Xcode installation and CocoaPods.
