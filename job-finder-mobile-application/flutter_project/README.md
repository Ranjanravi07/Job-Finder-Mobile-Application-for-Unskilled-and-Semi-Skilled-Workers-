# Job Finder Mobile Application

This is the native **Flutter Mobile Application** for **Unskilled and Semi-Skilled Workers in Nepal**, designed to reduce dependency on middlemen and directly connect workers with local employers. This codebase is fully ready to be opened in **VS Code** (Visual Studio Code).

## 🚀 How to Export and Open in VS Code

1. **Download the ZIP**: 
   - Click on the **Settings** menu in the top right of the Google AI Studio interface.
   - Choose **Export as ZIP** (or export to your GitHub repository).
   - Unzip the downloaded folder on your local machine.

2. **Open in VS Code**:
   - Open VS Code.
   - Go to `File` -> `Open Folder...`.
   - Select the `flutter_project` directory from your unzipped files.

3. **Install Flutter Extensions**:
   - Make sure you have the official **Flutter** and **Dart** extensions installed in VS Code.

4. **Install Dependencies**:
   - Open the VS Code terminal (`Ctrl+` ` ` or `Cmd+` ` `).
   - Run the following command:
     ```bash
     flutter pub get
     ```

5. **Launch the App**:
   - Select a target device (Android Emulator, iOS Simulator, or Chrome/Web).
   - Press `F5` or click the **Run and Debug** play button to launch!

---

## 📱 Running on Android / iOS Simulators

The app runs as a native mobile app — the same phone-form experience as the original React mobile simulator.

### Android

```bash
# Build a debug APK (ready to install on an emulator or device)
flutter build apk --debug

# Or launch directly on a running Android emulator / connected device
flutter run
```

- The built APK is at `build/app/outputs/flutter-apk/app-debug.apk`.
- Install it with `adb install build/app/outputs/flutter-apk/app-debug.apk`.
- Minimum supported Android version: 7.0 (API 24).

### iOS (requires macOS with Xcode)

```bash
# Open in Xcode and run on a simulator, or:
open ios/Runner.xcworkspace
flutter run
```

- All plugins used (`shared_preferences`, `flutter_tts`, `image_picker`, `url_launcher`) support both Android and iOS.
- Photo uploads, voice read-aloud (TTS), WhatsApp deep links, and simulated phone dialing all work on-device.

---

## 📱 Application Flow & Features (Based on Project Proposal)

This application matches the workflow described in your Minor Project Proposal:

1. **Language Selection Screen (`lib/screens/language_selection.dart`)**:
   - Simple visual-centric selection between **English** and **नेपाली (Nepali)**.
   - High-contrast, friendly layout suitable for users with different literacy levels.

2. **Secure OTP Login (`lib/screens/login.dart`)**:
   - No passwords or email addresses are required.
   - Log in directly using your 10-digit Nepali mobile number with an OTP code verification (preset code for testing: `123456`).

3. **Role/Account Type Selection (`lib/screens/role_selection.dart`)**:
   - Dual-mode workflow within a single application (as described in Page 12 of the proposal).
   - **Job Seeker (Worker)**: For plumbers, electricians, painters, carpenters, drivers, masons, and general laborers.
   - **Employer/Contractor**: For posting jobs and managing applicants.
   - Existing users are routed straight to their home screen; new users continue to profile creation.
   - Direct toggles allow switching between roles seamlessly.

4. **Profile Creation (`lib/screens/worker_profile_creation.dart` / `lib/screens/employer_profile_creation.dart`)**:
   - Photo upload, skill selection, expected daily wage, preferred location, and experience.
   - Government ID upload (Citizenship, NID, License, PAN/VAT, Business Registry) via `lib/widgets/gov_id_section.dart`.
   - **Smart Voice Onboarding** wizard (`lib/widgets/voice_parse_dialog.dart`) that extracts name, skill, location, and wages from spoken/text descriptions.

5. **Worker Experience (`lib/screens/worker_home.dart`)**:
   - **Icon-Based Filter Navigation**: Easy classification for quick navigation.
   - **Map View & List Toggle**: Visually explore daily wage jobs nearby.
   - **Audio Read-Aloud**: A speaker icon on job details lets low-literacy users listen to details audibly via Text-to-Speech!
   - **One-Tap Direct Connection**: Instantly make a phone call (`tel:`) or open WhatsApp directly from the app to talk with the employer.

6. **Employer Experience (`lib/screens/employer_home.dart`)**:
   - **Simple Job Poster Form**: Specify job titles, required skills, and daily wage expectations (in NPR).
   - **Applicant Tracker**: View who applied to your job, review their skill sets, and accept or decline their requests.
   - **Verified Checkmark**: Visual indicators demonstrating trust.

---

## 🗄️ Data Storage

All state is kept in memory via the central `lib/services/app_store.dart` `ChangeNotifier` and persisted locally with `shared_preferences` (mirroring the React app's `localStorage` under the `sim_*` keys). To swap in live cloud data:

1. Create a Firebase project at the [Firebase Console](https://console.firebase.google.com/).
2. Add an **Android app** and **iOS app** to your Firebase project.
3. Download `google-services.json` (for Android) and put it inside `android/app/`.
4. Download `GoogleService-Info.plist` (for iOS) and put it inside `ios/Runner/`.
5. Re-add the Firebase packages (`firebase_core`, `firebase_auth`, `cloud_firestore`) to `pubspec.yaml` and initialize Firebase in `lib/main.dart`.
6. Implement `FirebaseAuth.instance` calls in `login.dart` and `FirebaseFirestore.instance` in the home screens to retrieve/save live data.
