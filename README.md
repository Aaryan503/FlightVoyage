# FlightVoyage - A Flight Booking App

A Flutter app for booking flights with features like seat selection, user profiles, flight history, and map selection

## Prerequisites

Before you begin, ensure you have the following installed:
 - Flutter and Dart (obviously)
 - Android Emulator to run it on your PC
 - Firebase CLI(https://firebase.google.com/docs/cli) (for Firebase setup)

## Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication and Firestore Database
3. Add your Android/iOS app to the Firebase project, by getting the SHA1 and SHA256 keys
4. Download the configuration files for Android `google-services.json` (place in `android/app/`)

## Project Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/flightbooking_app.git
cd flightbooking_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
```bash
flutterfire configure
```

Also select your firebase project here, and then install android dependencies



