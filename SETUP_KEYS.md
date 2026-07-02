# API Keys & Security Setup Guide

This guide explains how to properly set up sensitive credentials for the Sa2e7 app.

## Overview

The following files contain sensitive information and **MUST NEVER be committed to version control**:
- `lib/firebase/firebase_config.dart` - Firebase API keys
- `google-services.json` - Android Firebase configuration
- `GoogleService-Info.plist` - iOS Firebase configuration

These files are listed in `.gitignore` to prevent accidental commits.

## Firebase Configuration

### Option 1: Using google-services.json (Recommended)

The most secure way to manage Firebase credentials is through Google's official configuration files:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (Sa2e7)
3. Go to **Project Settings** (gear icon)
4. Under **Your apps**, click your Android app
5. Click **google-services.json** to download
6. Place the file at `android/app/google-services.json`

This approach:
- Keeps keys out of Dart code
- Works with CI/CD pipelines
- Android Gradle automatically reads this file
- Keys are encrypted in the JSON file

### Option 2: Manual Firebase Config File

If you prefer to use `firebase_config.dart`:

1. Copy the template file:
   ```bash
   cp lib/firebase/firebase_config.dart.example lib/firebase/firebase_config.dart
   ```

2. Get your credentials:
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select project → Project Settings
   - Under "Your apps", select Android
   - Copy these values:
     - `apiKey`
     - `appId`
     - `projectId`
     - `storageBucket`
     - `messagingSenderId`

3. Update `firebase_config.dart` with your actual credentials

4. Ensure this file is in `.gitignore` (it is by default)

## Google Maps API Key

### Setup for Android

The Maps API key is injected at build time from `build.gradle.kts`. To set it up:

#### Method 1: Local Development (Easiest)

1. Open `android/app/build.gradle.kts`
2. In the `defaultConfig` section, replace `YOUR_MAPS_API_KEY` placeholder
3. For CI/CD, pass it via environment variable (see CI/CD section below)

#### Method 2: Using Gradle Properties

Create `android/local.properties` (if it doesn't exist):
```properties
GOOGLE_MAPS_API_KEY=AIzaSyAYFRlXlNKavwP1G4ZcvD7lzI5jfXI6zfk
```

Then update `build.gradle.kts`:
```kotlin
val mapsApiKey = project.findProperty("GOOGLE_MAPS_API_KEY") as? String ?: "YOUR_MAPS_API_KEY"
```

#### Method 3: Build Command Line

When building, pass the key as a parameter:
```bash
# For local testing
flutter run --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY

# For Android
gradle assembleDebug -PGOOGLE_MAPS_API_KEY=YOUR_KEY
```

### Getting Your Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing one
3. Enable the **Maps SDK for Android**
4. Go to **Credentials** → **Create Credentials** → **API Key**
5. Restrict the key to Android apps and add your app's package name (`com.example.Sa2e7`)
6. Copy the API key

## CI/CD Integration

For GitHub Actions, GitLab CI, or other CI/CD systems:

### GitHub Actions Example

Create `.github/workflows/build.yml`:

```yaml
name: Build APK

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Create firebase_config.dart
        run: |
          cat > lib/firebase/firebase_config.dart << EOF
          class FirebaseConfig {
            static const String apiKey = "${{ secrets.FIREBASE_API_KEY }}";
            static const String appId = "${{ secrets.FIREBASE_APP_ID }}";
            static const String projectId = "${{ secrets.FIREBASE_PROJECT_ID }}";
            static const String storageBucket = "${{ secrets.FIREBASE_STORAGE_BUCKET }}";
            static const String messagingSenderId = "${{ secrets.FIREBASE_MESSAGING_SENDER_ID }}";
          }
          EOF

      - name: Build APK
        run: flutter build apk --dart-define=GOOGLE_MAPS_API_KEY=${{ secrets.GOOGLE_MAPS_API_KEY }}
```

### Environment Variables

Store sensitive credentials in your CI/CD platform's secret management:
- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_MESSAGING_SENDER_ID`
- `GOOGLE_MAPS_API_KEY`

## Security Best Practices

1. **Never commit credentials** - Use `.gitignore`
2. **Use example files** - Provide `*.example` templates for developers
3. **Rotate keys regularly** - Especially if accidentally exposed
4. **Restrict API keys**:
   - For Android Maps: Restrict to Android apps + your package name
   - For Firebase: Use security rules and API restrictions
5. **Use environment variables** - For CI/CD pipelines
6. **Monitor API usage** - Check Google Cloud Console for unusual activity
7. **Revoke compromised keys immediately** - In Firebase Console or Google Cloud

## Testing Locally

After setting up credentials:

```bash
# Run the app
flutter run

# Or with Maps API key
flutter run --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY
```

## Troubleshooting

### "API key not found" Error
- Verify `firebase_config.dart` exists with actual credentials
- For Maps: Check `build.gradle.kts` has the API key placeholder filled
- Check `.gitignore` to ensure config files will be ignored in future commits

### Firebase Auth Fails
- Confirm `google-services.json` or `firebase_config.dart` has correct credentials
- Check Firebase Console for API restrictions
- Verify app's package name matches Firebase project configuration

### Maps Not Showing
- Verify Maps API key is correctly set in `build.gradle.kts`
- Check Google Cloud Console - Maps SDK enabled for your project
- Verify API key restrictions include your app's package name
- Check Android logcat for Map initialization errors

## References

- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps API Documentation](https://developers.google.com/maps/documentation/android-sdk)
- [Managing API Keys](https://cloud.google.com/docs/authentication/api-keys)
- [Flutter Environment Variables](https://flutter.dev/docs/development/build-and-release/build-app-bundle)
