# Authentication Setup Guide

## Overview
This guide will help you set up Google OAuth authentication with Supabase for the Quiz App.

## Prerequisites
- Supabase project created
- Google Cloud Project with OAuth credentials

## Step 1: Update Dependencies

Add the required packages to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  google_sign_in: ^6.0.0
```

Then run:
```bash
flutter pub get
```

## Step 2: Get Google OAuth Credentials

### For Android:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select your project
3. Enable Google+ API
4. Go to Credentials → Create OAuth 2.0 Client ID → Android
5. You'll need your app's SHA-1 fingerprint. Get it with:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey
   ```
   (Password is usually 'android')
6. Copy the OAuth Client ID

### For iOS:
1. In Google Cloud Console, go to Credentials → Create OAuth 2.0 Client ID → iOS
2. Enter your app's bundle ID (found in ios/Runner.xcodeproj/project.pbxproj)
3. Copy the OAuth Client ID

### For Web:
1. Go to Google Cloud Console → Credentials → Create OAuth 2.0 Client ID → Web
2. Add authorized JavaScript origins and redirect URIs
3. Copy the Client ID

## Step 3: Configure Supabase Auth

1. Go to your Supabase Dashboard
2. Navigate to Authentication → Providers
3. Enable Google provider:
   - Paste the Client ID from Google Cloud Console
   - Paste the Client Secret (from Google Cloud Console)
4. Set Redirect URL (usually: `https://YOUR_PROJECT.supabase.co/auth/v1/callback`)

## Step 4: Update Auth Service with Google Credentials

In `lib/services/auth_service.dart`, update the GoogleSignIn initialization:

```dart
_googleSignIn = GoogleSignIn(
  clientId: 'YOUR_GOOGLE_CLIENT_ID_HERE',
  serverClientId: 'YOUR_GOOGLE_SERVER_CLIENT_ID_HERE',
);
```

Replace with your actual credentials from Google Cloud Console.

## Step 5: Platform-Specific Configuration

### Android Configuration (android/app/build.gradle)

Ensure you have the correct signingConfigs:

```gradle
android {
    signingConfigs {
        debug {
            storeFile file('debug.keystore')
            keyAlias 'androiddebugkey'
            keyPassword 'android'
            storePassword 'android'
        }
    }
}
```

### iOS Configuration

In `ios/Runner/Info.plist`, add:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### Web Configuration

In `web/index.html`, add Google Sign-In script:

```html
<script src="https://accounts.google.com/gsi/client" async defer></script>
```

## Step 6: Database Schema (SQL)

Execute this in your Supabase SQL Editor to set up the quiz tables:

```sql
-- Create quiz table
CREATE TABLE quiz (
  id BIGSERIAL PRIMARY KEY,
  question TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create quiz_option table
CREATE TABLE quiz_option (
  id BIGSERIAL PRIMARY KEY,
  quiz_id BIGINT NOT NULL REFERENCES quiz(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT FALSE,
  option_index INT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
-- (See supabase_schema.sql file for complete data)
```

## Step 7: Run the App

```bash
flutter run
```

## File Structure

```
lib/
├── main.dart
├── models/
│   └── question.dart
├── screens/
│   ├── auth_wrapper.dart
│   ├── home_screen.dart
│   ├── quiz_screen.dart
│   ├── sign_in_screen.dart
│   └── sign_up_screen.dart
└── services/
    └── auth_service.dart
```

## Features Implemented

✅ **Sign Up with Email/Password**
- Email validation
- Password confirmation
- Password strength requirement (min 6 characters)
- User display name

✅ **Sign In with Email/Password**
- Email and password authentication
- Remember login state
- Error handling

✅ **Sign In/Up with Google**
- Single-click Google authentication
- Automatic profile creation
- Secure OAuth flow

✅ **Session Management**
- Persistent login sessions
- Sign out functionality
- User profile display

✅ **Quiz Access**
- Quiz only available to authenticated users
- Access user information in quiz

## Troubleshooting

### Google Sign In not working:
1. Verify Client ID is correct in auth_service.dart
2. Check SHA-1 fingerprint matches in Google Cloud Console
3. Ensure Google+ API is enabled

### Supabase connection errors:
1. Verify URL and anonKey in main.dart
2. Check network connectivity
3. Ensure tables are created in database

### Authentication state not persisting:
1. Check browser cookies/app cache
2. Verify Supabase session settings
3. Check for console errors in browser/app

## Security Notes

⚠️ **Important:**
- Never commit your credentials to version control
- Use environment variables for sensitive data in production
- Enable RLS (Row Level Security) on your database tables
- Implement proper API rate limiting
- Use HTTPS for all authentication flows

## Next Steps

1. Customize the UI to match your branding
2. Add additional user profile fields
3. Implement quiz result tracking
4. Add social sharing features
5. Set up push notifications
