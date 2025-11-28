# Firebase Setup Guide

Follow these steps to set up Firebase for your Attendance System:

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" or "Create a project"
3. Enter project name: **attendance-system** (or your preferred name)
4. Click "Continue"
5. Disable Google Analytics (optional) and click "Create project"
6. Wait for project creation, then click "Continue"

## Step 2: Enable Firestore Database

1. In your Firebase project dashboard, click "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in **test mode**" (for development)
4. Select your Cloud Firestore location (closest to you)
5. Click "Enable"

## Step 3: Register Your App

### For Android:
1. Click the Android icon in Firebase Console
2. Android package name: `com.example.attendance` (or check `android/app/build.gradle`)
3. Click "Register app"
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

### For Web (Optional):
1. Click the Web icon (</>)
2. App nickname: "Attendance Web"
3. Click "Register app"
4. Copy the Firebase configuration object

## Step 4: Get Firebase Configuration

1. Go to Project Settings (gear icon) → General
2. Scroll down to "Your apps"
3. For each platform you added, you'll see configuration details

### Copy these values to `lib/firebase_options.dart`:

- **apiKey**: Your API key
- **appId**: Your app ID
- **messagingSenderId**: Your messaging sender ID
- **projectId**: Your project ID
- **storageBucket**: Your storage bucket

## Step 5: Update firebase_options.dart

Open `lib/firebase_options.dart` and replace:
- `YOUR_PROJECT_ID` → your actual project ID
- `YOUR_API_KEY` → your actual API key
- `YOUR_APP_ID` → your actual app ID
- `YOUR_MESSAGING_SENDER_ID` → your actual sender ID

## Step 6: Set up Firestore Security Rules

1. In Firebase Console → Firestore Database → Rules
2. Replace with these rules for development:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // Open for development
    }
  }
}
```

⚠️ **Important**: Change these rules for production!

## Step 7: Run the App

```bash
flutter pub get
flutter run
```

## Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
- Make sure you updated `firebase_options.dart` with your actual credentials

### Error: "PERMISSION_DENIED"
- Check your Firestore security rules
- Make sure they allow read/write access

### Can't find google-services.json
- Make sure it's in `android/app/` directory
- Check the file name is exactly `google-services.json`

## Quick Test

Once set up, the app will:
- Show Teachers Portal (no login required)
- Allow adding students/teachers
- Track attendance via Firebase Firestore
- Handle participation requests in real-time

## Need Help?

Check [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview/)
