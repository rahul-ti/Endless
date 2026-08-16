# Android APK Modernization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the obsolete Android v1 runner with Flutter 3.47's supported Android build structure and produce an inspected debug APK that can be installed directly.

**Architecture:** Keep the existing Flutter/Dart application unchanged and replace only the Android host configuration with the installed Flutter 3.47 Kotlin template pattern. Pin the Android namespace and application ID to `com.rahultiwari.endless`, install the exact SDK/JDK inputs required by the template, and verify the final APK's manifest rather than relying only on Gradle configuration text.

**Tech Stack:** Flutter 3.47.0, Dart 3.13.0, Android SDK 36, Android Gradle Plugin 9.1.0, Gradle 9.3.1, Kotlin 2.4.0, Java 17, Android v2 embedding.

## Global Constraints

- Minimum Android SDK is API 24 (Android 7.0).
- Compile and target Android SDK are API 36 (Android 16).
- The APK must run across Android 12 through Android 17 and retain compatibility with API 24 and newer.
- Android namespace and application ID are `com.rahultiwari.endless`.
- Flutter UI and arithmetic behavior must not change.
- Existing launcher icons remain unchanged.
- `android/key.properties`, `*.jks`, and `*.keystore` remain outside version control.
- Existing unrelated worktree changes, including Eclipse metadata edits, must not be overwritten or committed accidentally.
- The first artifact is a debug APK. Play upload-key creation and a signed release AAB are a separate follow-up phase.
- Do not create implementation commits unless the user explicitly asks; use exact diffs and verification output as checkpoints.

---

### Task 1: Install and Validate the Android Toolchain

**Files:**
- No repository files are modified.
- Machine-local SDK root: `/opt/homebrew/share/android-commandlinetools`
- Machine-local JDK: `/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home`

**Interfaces:**
- Consumes: installed Flutter 3.47.0 at `/opt/homebrew/share/flutter`
- Produces: callable `sdkmanager`, Android platform/build tools 36.0.0, platform tools, NDK 28.2.13676358, and a Flutter-recognized Java 17/Android SDK configuration

- [ ] **Step 1: Capture the existing toolchain failure**

Run:

```sh
flutter doctor -v
```

Expected before setup: Flutter and Chrome pass, while the Android toolchain reports that it cannot locate an Android SDK.

- [ ] **Step 2: Install Java 17 and Android command-line tools**

Run:

```sh
brew install openjdk@17
brew install --cask android-commandlinetools
```

Expected: Homebrew installs the JDK and exposes `sdkmanager` from `/opt/homebrew/share/android-commandlinetools/cmdline-tools/latest/bin`.

- [ ] **Step 3: Pin Flutter to the Java 17 runtime and Android SDK root**

Run:

```sh
flutter config --jdk-dir /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
flutter config --android-sdk /opt/homebrew/share/android-commandlinetools
```

Expected: Flutter confirms both settings.

- [ ] **Step 4: Install the SDK components required by Flutter 3.47**

Run:

```sh
sdkmanager --sdk_root=/opt/homebrew/share/android-commandlinetools "platform-tools" "platforms;android-36" "build-tools;36.0.0" "ndk;28.2.13676358"
```

Expected: all four packages finish installing without an error.

- [ ] **Step 5: Accept Android SDK licenses interactively**

Run:

```sh
flutter doctor --android-licenses
```

Answer `y` to each license prompt. Expected: `All SDK package licenses accepted.`

- [ ] **Step 6: Verify the toolchain**

Run:

```sh
flutter doctor -v
```

Expected: the Android toolchain section passes and reports Android SDK 36 plus Java 17. Xcode warnings remain unrelated to the Android build.

---

### Task 2: Replace the Legacy Gradle Host with Flutter 3.47 Configuration

**Files:**
- Delete: `android/settings.gradle`
- Delete: `android/build.gradle`
- Delete: `android/app/build.gradle`
- Create: `android/settings.gradle.kts`
- Create: `android/build.gradle.kts`
- Create: `android/app/build.gradle.kts`
- Modify: `android/gradle.properties`
- Modify: `android/gradle/wrapper/gradle-wrapper.properties`
- Modify: `android/.gitignore`
- Test: `flutter build apk --debug`

**Interfaces:**
- Consumes: Flutter SDK path from ignored `android/local.properties` and the toolchain from Task 1
- Produces: a declarative Gradle host using AGP 9.1.0, Gradle 9.3.1, Flutter's plugin loader, namespace `com.rahultiwari.endless`, min SDK 24, and target SDK 36

- [ ] **Step 1: Reproduce the pre-migration failure**

Run:

```sh
flutter build apk --debug
```

Expected: FAIL with `Build failed due to use of deleted Android v1 embedding.` Flutter may mechanically rewrite the Gradle wrapper before failing; if so, restore the wrapper before applying the complete configuration below so the diff remains attributable.

- [ ] **Step 2: Replace `android/settings.gradle` with `android/settings.gradle.kts`**

Create `android/settings.gradle.kts` with:

```kotlin
pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
```

Delete `android/settings.gradle` in the same patch.

- [ ] **Step 3: Replace `android/build.gradle` with `android/build.gradle.kts`**

Create `android/build.gradle.kts` with:

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
```

Delete `android/build.gradle` in the same patch.

- [ ] **Step 4: Replace `android/app/build.gradle` with `android/app/build.gradle.kts`**

Create `android/app/build.gradle.kts` with:

```kotlin
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rahultiwari.endless"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.rahultiwari.endless"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
```

Delete `android/app/build.gradle` in the same patch. The debug signing fallback in the release block is temporary template behavior and must not be used for a Play upload.

- [ ] **Step 5: Update Gradle runtime properties**

Replace `android/gradle.properties` with:

```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.newDsl=false
android.builtInKotlin=false
```

Replace `android/gradle/wrapper/gradle-wrapper.properties` with:

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-9.3.1-all.zip
```

- [ ] **Step 6: Protect future signing material**

Append these entries to `android/.gitignore`:

```gitignore
/key.properties
*.jks
*.keystore
```

Confirm `android/key.properties` remains deleted and no keystore exists in `git ls-files`.

- [ ] **Step 7: Inspect the Gradle-only diff**

Run:

```sh
git diff --check -- android/settings.gradle android/settings.gradle.kts android/build.gradle android/build.gradle.kts android/app/build.gradle android/app/build.gradle.kts android/gradle.properties android/gradle/wrapper/gradle-wrapper.properties android/.gitignore
git status --short android
```

Expected: no whitespace errors; only the explicitly listed build files plus the pre-existing Eclipse metadata changes and staged key-properties deletion appear.

---

### Task 3: Migrate the Android Host to v2 Embedding

**Files:**
- Delete: `android/app/src/main/kotlin/com/example/endless/MainActivity.kt`
- Create: `android/app/src/main/kotlin/com/rahultiwari/endless/MainActivity.kt`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/src/debug/AndroidManifest.xml`
- Modify: `android/app/src/profile/AndroidManifest.xml`
- Modify: `android/app/src/main/res/values/styles.xml`
- Create: `android/app/src/main/res/values-night/styles.xml`
- Create: `android/app/src/main/res/drawable-v21/launch_background.xml`
- Test: `flutter build apk --debug`

**Interfaces:**
- Consumes: namespace and application ID `com.rahultiwari.endless` from Task 2
- Produces: launcher activity `.MainActivity` backed by Android v2 `FlutterActivity`, Flutter embedding metadata version 2, and v2 launch/normal themes

- [ ] **Step 1: Replace the legacy activity**

Create `android/app/src/main/kotlin/com/rahultiwari/endless/MainActivity.kt` with:

```kotlin
package com.rahultiwari.endless

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

Delete `android/app/src/main/kotlin/com/example/endless/MainActivity.kt`. This removes manual `GeneratedPluginRegistrant.registerWith` usage.

- [ ] **Step 2: Replace the main manifest with the v2 host manifest**

Replace `android/app/src/main/AndroidManifest.xml` with:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="endless"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT" />
            <data android:mimeType="text/plain" />
        </intent>
    </queries>
</manifest>
```

- [ ] **Step 3: Remove obsolete package attributes from debug/profile manifests**

Replace both `android/app/src/debug/AndroidManifest.xml` and `android/app/src/profile/AndroidManifest.xml` with:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>
```

- [ ] **Step 4: Add v2 light and dark themes**

Replace `android/app/src/main/res/values/styles.xml` with:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

Create `android/app/src/main/res/values-night/styles.xml` with:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

- [ ] **Step 5: Add the API-21-and-newer launch background**

Create `android/app/src/main/res/drawable-v21/launch_background.xml` with:

```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="?android:colorBackground" />
</layer-list>
```

- [ ] **Step 6: Confirm every v1 embedding reference is gone**

Run:

```sh
rg -n "io\.flutter\.app|GeneratedPluginRegistrant\.registerWith|PluginRegistry\.Registrar" android
```

Expected: no matches.

- [ ] **Step 7: Build the debug APK**

Run:

```sh
flutter build apk --debug
```

Expected: exit 0 and `build/app/outputs/flutter-apk/app-debug.apk` exists.

---

### Task 4: Verify the APK Contract and Existing Flutter Behavior

**Files:**
- Test: `test/widget_test.dart`
- Artifact: `build/app/outputs/flutter-apk/app-debug.apk` (ignored build output)

**Interfaces:**
- Consumes: debug APK from Task 3 and `apkanalyzer` from Task 1
- Produces: evidence that the package ID, SDK range, launcher activity, Dart analysis, and arithmetic behavior match the approved design

- [ ] **Step 1: Run static analysis**

Run:

```sh
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: Run the complete Flutter tests**

Run:

```sh
flutter test
```

Expected: both existing question-generation and correct-answer widget tests pass.

- [ ] **Step 3: Inspect the APK application ID**

Run:

```sh
apkanalyzer manifest application-id build/app/outputs/flutter-apk/app-debug.apk
```

Expected: `com.rahultiwari.endless`.

- [ ] **Step 4: Inspect the APK SDK contract**

Run:

```sh
apkanalyzer manifest min-sdk build/app/outputs/flutter-apk/app-debug.apk
apkanalyzer manifest target-sdk build/app/outputs/flutter-apk/app-debug.apk
```

Expected: minimum SDK `24` and target SDK `36`.

- [ ] **Step 5: Inspect the launcher activity**

Run:

```sh
apkanalyzer manifest print build/app/outputs/flutter-apk/app-debug.apk
```

Expected manifest content includes `com.rahultiwari.endless.MainActivity`, `android.intent.action.MAIN`, and `android.intent.category.LAUNCHER`.

- [ ] **Step 6: Check the final repository diff**

Run:

```sh
git diff --check
git status --short --branch
git diff --stat
```

Expected: no whitespace errors. The report must distinguish Android migration files from earlier Flutter/web setup changes, the user's Eclipse metadata changes, and the staged deletion of `android/key.properties`.

---

### Task 5: Install and Smoke-Test on an Available Android Device

**Files:**
- No repository files are modified.
- Artifact: `build/app/outputs/flutter-apk/app-debug.apk`

**Interfaces:**
- Consumes: inspected APK from Task 4 and an Android device exposed by `flutter devices` or `adb devices`
- Produces: installation result and, when a device is available, runtime evidence for app launch and answer progression

- [ ] **Step 1: Discover Android devices**

Run:

```sh
flutter devices
/opt/homebrew/share/android-commandlinetools/platform-tools/adb devices -l
```

Expected: a physical Android device or emulator is listed as `device`. If none is available, record that runtime installation was not executed and retain the verified APK for manual installation.

- [ ] **Step 2: Install the APK when a device is available**

Run:

```sh
/opt/homebrew/share/android-commandlinetools/platform-tools/adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Expected: `Success`.

- [ ] **Step 3: Launch the app when a device is available**

Run:

```sh
/opt/homebrew/share/android-commandlinetools/platform-tools/adb shell am start -n com.rahultiwari.endless/.MainActivity
```

Expected: Android reports that it started the activity and the app opens without an immediate crash.

- [ ] **Step 4: Exercise the core flow manually**

On the device, enter one incorrect answer and confirm the current question remains. Then enter the correct answer and confirm the input clears and a new question appears.

- [ ] **Step 5: Report the artifact and Play follow-up boundary**

Report the absolute APK path, file size, SHA-256 checksum, verified SDK/application values, device result, and remaining platform warnings. State that Play publishing still requires a dedicated upload keystore, release signing configuration, a signed AAB, store assets, and Play Console submission.
