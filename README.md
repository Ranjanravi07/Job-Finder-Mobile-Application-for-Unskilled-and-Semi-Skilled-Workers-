# Job Finder Mobile Application for Unskilled and Semi-Skilled Workers

A mobile job-finding platform designed to connect **unskilled and semi-skilled workers with employers in Nepal**.

The project provides a simple and accessible way for workers to create profiles, identify their skills and work preferences, discover suitable employment opportunities, and communicate with employers. Employers can create profiles, post jobs, and manage applicants through the platform.

The project also includes a web-based **Admin Dashboard** for managing and monitoring the platform.

> **Project Status:** Active development

---

## 📌 Project Overview

Many unskilled and semi-skilled workers find employment through informal networks, personal contacts, contractors, or physical visits to workplaces. This can make finding suitable jobs difficult, especially when workers have limited digital literacy.

This project aims to provide a centralized digital platform where:

* Workers can create simple profiles.
* Workers can select their job category and work preferences.
* Employers can publish job opportunities.
* Workers can discover jobs relevant to their skills and preferences.
* Workers can apply for jobs.
* Workers and employers can communicate through chat.
* Administrators can monitor and manage the platform.

The application is specifically designed with **simplicity, accessibility, and low-literacy users** in mind.

---

## 🎯 Objectives

The main objectives of the project are:

* Connect workers with suitable employers.
* Make job searching easier for unskilled and semi-skilled workers.
* Reduce dependency on informal job-search methods.
* Allow employers to find suitable workers more efficiently.
* Provide category- and preference-based job discovery.
* Support bilingual and accessibility-oriented interaction.
* Provide secure user authentication and profile management.
* Provide an administrative interface for platform management.

---

## 👥 Target Users

### Workers

The application targets unskilled and semi-skilled workers such as:

* Laborers
* Electricians
* Plumbers
* Drivers
* Painters
* Carpenters
* Masons
* Cleaners
* Farmers
* Cooks
* Welders
* Tailors
* Other workers

### Employers

Employers, contractors, businesses, and individuals who need workers can use the platform to:

* Create an employer profile
* Post jobs
* Specify job requirements
* Review applicants
* Communicate with workers

### Administrators

Administrators can manage and monitor the platform through the web-based Admin Dashboard.

---

# ✨ Key Features

## 👷 Worker Application

### Authentication

* Phone-number based authentication
* OTP verification
* Role selection
* Worker and Employer account flows

### Worker Profile

Workers can create and manage their profiles including:

* Name
* Profile photo
* Primary skill
* Experience
* Location
* Government ID/KYC information
* Job category
* Preferred location
* Work type
* Expected salary
* Shift preference

### Job Category

Workers can select the type of work they are looking for using a visual, easy-to-understand interface.

Example categories:

* 👷 Laborer
* ⚡ Electrician
* 🔧 Plumber
* 🚗 Driver
* 🎨 Painter
* 🪚 Carpenter
* 🧱 Mason
* 🧹 Cleaner
* 🌾 Farmer
* 🍳 Cook
* 🔩 Welder
* 🧵 Tailor
* 🛠️ Other

### Work Preferences

Workers can specify:

* Preferred location
* Work type
* Expected salary
* Shift preference

Supported work types include:

* Daily Wage
* Full Time
* Part Time
* Contract

Supported shift preferences include:

* Day Shift
* Night Shift
* Flexible

### Job Discovery

Jobs can be presented according to worker information such as:

* Job category
* Location
* Work type
* Salary
* Shift

The intended matching flow is:

```text
Worker Profile
      │
      ├── Job Category
      ├── Preferred Location
      ├── Work Type
      ├── Expected Salary
      └── Shift Preference
             │
             ▼
       Job Matching
             │
             ▼
      Suitable Jobs
```

Category should be treated as the primary matching factor, while other preferences can be used to rank and prioritize suitable jobs.

---

## 🏢 Employer Application

Employers can:

* Create an employer profile
* Manage employer information
* Post job vacancies
* Specify job category
* Specify location
* Specify salary
* Specify work type
* Specify shift
* Review applicants
* View applicant information
* Communicate with workers

---

## 💼 Job Management

A job posting can contain information such as:

* Job title
* Job category
* Job description
* Employer
* Location
* Salary
* Work type
* Shift
* Posting information
* Application information

Example:

```text
Job:
Electrician

Location:
Lalitpur

Salary:
NPR 25,000–30,000

Work Type:
Full Time

Shift:
Day
```

---

## 📝 Job Applications

Workers can apply for available jobs.

The application workflow is designed around:

```text
Worker
   │
   ▼
View Job
   │
   ▼
Apply
   │
   ▼
Employer Reviews Application
   │
   ├── Pending
   ├── Accepted
   └── Rejected
```

---

## 💬 Chat

The Flutter application includes a dedicated chat service for communication between workers and employers.

The chat architecture is designed around Firebase/Firestore and supports storing conversation and message data.

The recommended relationship is:

```text
Worker
   │
   ├── Employer
   │
   └── Job
        │
        ▼
       Chat
        │
        ▼
     Messages
```

Keeping the `jobId` associated with a conversation helps prevent confusion when the same worker and employer interact regarding different jobs.

---

## 🪪 KYC / Identity Information

The application includes government ID/KYC-related profile information.

The purpose is to support:

* User verification
* Identity information management
* Safer interaction between workers and employers
* Administrative review

Sensitive documents should be stored securely and should never be exposed through publicly accessible storage URLs.

---

## 🔊 Accessibility

Because the target users may have limited literacy or digital experience, accessibility is an important part of the application design.

The project includes/targets:

* Simple interfaces
* Large touch-friendly controls
* Visual job categories
* Minimal typing
* English/Nepali support
* Text-to-speech
* Voice-related services
* Clear labels
* Easy navigation

The Flutter project includes `flutter_tts`, `speech_service.dart`, and `voice_parser.dart` for voice-oriented functionality.

---

# 🌓 Theme Support

The Flutter application uses a centralized theme architecture.

Supported theme modes:

* System
* Light
* Dark

### System Mode

When System mode is selected:

```text
Android Light Mode
       ↓
Flutter Light Theme

Android Dark Mode
       ↓
Flutter Dark Theme
```

The theme system is designed to maintain readable:

* Text
* Cards
* Input fields
* Dropdowns
* Buttons
* Borders
* Secondary text
* Labels

Theme-related code is organized separately under the Flutter project's `theme` directory.

---

# 🔐 Authentication & Security

The Flutter application uses Firebase Authentication.

Current Flutter dependencies include:

* `firebase_core`
* `firebase_auth`
* `cloud_firestore`
* `firebase_storage`

Security should be enforced at the Firebase Rules level rather than relying only on client-side checks.

Important security principles:

* Users should only modify their own profiles.
* Workers should not modify employer records.
* Employers should not modify worker records.
* Users should not access another user's private KYC documents.
* Job ownership must be validated before editing/deleting jobs.
* Application status changes should be restricted to authorized users.
* Chat messages should only be accessible to participants in the conversation.
* Admin operations should use appropriate privileged access controls.

---

# ☁️ Firebase Architecture

The project uses Firebase as its backend infrastructure.

### Firebase Services

| Service                 | Purpose                       |
| ----------------------- | ----------------------------- |
| Firebase Authentication | User authentication and OTP   |
| Cloud Firestore         | Application data              |
| Firebase Storage        | Profile images and documents  |
| SharedPreferences       | Local application preferences |
| Firebase Core           | Firebase initialization       |

The Flutter project's `pubspec.yaml` confirms Firebase Authentication, Firestore, Storage, SharedPreferences, and related packages.

### Recommended Firestore Structure

```text
users/
  userId/

workers/
  workerId/

employers/
  employerId/

jobs/
  jobId/

applications/
  applicationId/

chats/
  chatId/

  messages/
    messageId/

categories/
  categoryId/
```

The exact production structure should remain synchronized with the implementation and Firebase Security Rules.

---

# 🏗️ Project Architecture

The repository contains multiple application components:

```text
Job-Finder-Mobile-Application-for-Unskilled-and-Semi-Skilled-Workers-
│
├── admin-dashboard/
│
├── flutter/
│
└── job-finder-mobile-application/
    │
    ├── backend-server/
    ├── flutter/
    ├── flutter_project/
    ├── src/
    ├── firebase.json
    ├── .firebaserc
    └── ...
```

The repository currently contains both the React implementation and Flutter implementation, together with the Admin Dashboard.

---

# 📱 Flutter Application Structure

The main Flutter application is located at:

```text
job-finder-mobile-application/flutter_project/
```

Its `lib` directory is organized into:

```text
lib/
├── data/
├── models/
├── providers/
├── screens/
├── services/
├── theme/
├── widgets/
└── main.dart
```

This separation provides a foundation for maintaining:

* Data access
* Models
* State management
* Screens
* Services
* Theme
* Reusable UI components

---

# 📂 Important Flutter Screens

The current Flutter project includes screens such as:

```text
screens/
├── employer_home.dart
├── employer_profile_creation.dart
├── job_applicants_screen.dart
├── job_details_sheet.dart
├── language_selection.dart
├── login.dart
├── phone_dialer.dart
├── profile_edit.dart
├── profile_setup.dart
├── profile_view.dart
├── role_selection.dart
├── worker_home.dart
└── worker_profile_creation.dart
```

---

# 🧩 Flutter Services

The project contains dedicated services for:

```text
services/
├── app_store.dart
├── chat_service.dart
├── firebase_service.dart
├── image_pick_service.dart
├── speech_service.dart
├── storage_service.dart
├── voice_parser.dart
└── otp/
```

---

# 🛠️ Technology Stack

## Mobile Application

* Flutter
* Dart
* Material Design

## Backend

* Firebase
* Firebase Authentication
* Cloud Firestore
* Firebase Storage

## State Management

* Provider

## Local Storage

* SharedPreferences

## Accessibility / Voice

* Flutter TTS
* Speech/voice services

## UI / Utilities

* Google Fonts
* Image Picker
* PInput
* URL Launcher
* Intl

The current Flutter dependencies are defined in `job-finder-mobile-application/flutter_project/pubspec.yaml`.

---

# 🖥️ Admin Dashboard

The repository also contains a separate web-based Admin Dashboard:

```text
admin-dashboard/
├── public/
├── src/
├── dist/
├── package.json
├── vite.config.ts
└── ...
```

The dashboard has its own React/TypeScript frontend structure and Firebase integration.

The Admin Dashboard is intended to provide centralized management of the platform, including user and application data.

---

# 🌐 React Version

The repository also contains the earlier React implementation:

```text
job-finder-mobile-application/
└── src/
    ├── components/
    ├── services/
    ├── App.tsx
    ├── data.ts
    ├── index.css
    ├── main.tsx
    └── types.ts
```

The React version serves as an important UI/functional reference for the Flutter migration.

---

# ⚙️ Requirements

## Flutter

Install the Flutter SDK and configure an Android development environment.

Verify:

```bash
flutter doctor
```

The Flutter application requires Dart SDK version:

```text
>=3.0.0 <4.0.0
```

according to the current project configuration.

## Android

You need:

* Android Studio
* Android SDK
* Android emulator or physical Android device
* USB debugging enabled for physical-device testing

---

# 🚀 Running the Flutter Application

Clone the repository:

```bash
git clone https://github.com/Ranjanravi07/Job-Finder-Mobile-Application-for-Unskilled-and-Semi-Skilled-Workers-.git
```

Enter the Flutter application:

```bash
cd Job-Finder-Mobile-Application-for-Unskilled-and-Semi-Skilled-Workers-/job-finder-mobile-application/flutter_project
```

Install dependencies:

```bash
flutter pub get
```

Check the environment:

```bash
flutter doctor
```

Run the application:

```bash
flutter run
```

To see available devices:

```bash
flutter devices
```

---

# 🔥 Firebase Configuration

Before running the production application, configure Firebase for the Android application.

The project repository contains Firebase configuration files and Firebase-related application code.

You should configure:

1. Firebase project
2. Android application
3. Firebase Authentication
4. Cloud Firestore
5. Firebase Storage
6. Appropriate Firebase Security Rules

Never commit private credentials, service-account keys, or sensitive secrets to GitHub.

---

# 🗄️ Database Design

A recommended production-oriented structure is:

```text
users
 └── userId
      ├── name
      ├── phone
      ├── role
      └── status

workers
 └── workerId
      ├── profile
      ├── category
      ├── experience
      ├── location
      └── workPreferences

employers
 └── employerId
      ├── businessName
      ├── location
      └── verification

jobs
 └── jobId
      ├── employerId
      ├── category
      ├── title
      ├── location
      ├── salary
      ├── workType
      ├── shift
      └── status

applications
 └── applicationId
      ├── jobId
      ├── workerId
      ├── employerId
      ├── status
      └── createdAt

chats
 └── chatId
      ├── workerId
      ├── employerId
      └── jobId
```

This structure should be adapted to the actual Firestore implementation before production deployment.

---

# 🎯 Job Matching

The platform is designed to help workers find jobs that match their requirements.

For example:

### Worker

```text
Category: Electrician
Location: Lalitpur
Work Type: Full Time
Expected Salary: NPR 25,000
Shift: Day
```

### Job

```text
Category: Electrician
Location: Lalitpur
Work Type: Full Time
Salary: NPR 28,000
Shift: Day
```

### Result

```text
✅ Strong Match
```

A practical matching system should use:

```text
Category       → Primary match
Location       → Strong preference
Work Type      → Preference
Shift           → Preference
Salary          → Compatibility
```

This prevents the system from unnecessarily hiding suitable jobs when a non-critical preference does not exactly match.

---

# 🧪 Testing

Before production deployment, test:

### Worker

* Registration
* OTP verification
* Profile creation
* Profile editing
* Job category selection
* Work preference selection
* Job discovery
* Job details
* Job application
* Application status
* Chat
* Voice features
* Language selection
* Light/Dark/System theme

### Employer

* Registration
* Profile creation
* Job posting
* Job editing
* Job management
* Applicant management
* Applicant details
* Chat
* Theme behavior

### Firebase

* Authentication
* Firestore reads/writes
* Storage uploads
* Security Rules
* Unauthorized access
* Data ownership
* Application permissions

---

# 🔒 Security Recommendations

Before production deployment:

* Enable strict Firestore Security Rules.
* Protect KYC documents.
* Validate all user input.
* Do not trust client-side role values.
* Verify ownership before modifying jobs.
* Restrict application updates.
* Restrict chat access to participants.
* Avoid exposing private Firebase configuration or service-account credentials.
* Do not commit `.env` files containing secrets.
* Implement proper admin authorization.

---

# ♿ Accessibility & Low-Literacy Design

The application is intentionally designed for users who may have limited reading and digital skills.

Design principles include:

* Large touch targets
* Simple navigation
* Visual job categories
* Minimal typing
* Clear labels
* Bilingual support
* Voice assistance
* Text-to-speech
* High-contrast themes
* Simple selection controls

The goal is not merely to make the application technically functional, but to make it usable by the actual target population.

---

# 🗺️ Future Enhancements

Potential future improvements include:

* Push notifications using Firebase Cloud Messaging
* Advanced job recommendation
* Location-based job discovery
* Nearby job map
* Worker availability status
* Employer verification badges
* Worker verification badges
* Rating and review system
* Report/block functionality
* Improved chat features
* Voice-based job search
* Voice-based job application assistance
* AI-assisted job matching
* Analytics for employers
* Advanced admin moderation
* Fraud and duplicate-account detection

These should be implemented incrementally rather than adding unnecessary complexity to the first production release.

---

# 📌 Current Development Notes

The repository contains both the React implementation and a Flutter implementation. The Flutter implementation is organized as a native Flutter project and already includes Firebase-related services, worker/employer screens, chat service, profile flows, voice services, and a dedicated theme structure.

The repository also contains implementation documentation for the Job Category and Work Preferences functionality, including category selection, preferred location, work type, expected salary, and shift preference.

---

# 📁 Repository Structure

```text
Job-Finder-Mobile-Application-for-Unskilled-and-Semi-Skilled-Workers-
│
├── admin-dashboard/
│   ├── public/
│   ├── src/
│   ├── dist/
│   └── package.json
│
├── flutter/
│
├── job-finder-mobile-application/
│   ├── backend-server/
│   ├── flutter/
│   ├── flutter_project/
│   │   ├── android/
│   │   ├── assets/
│   │   ├── lib/
│   │   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── providers/
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   ├── theme/
│   │   │   └── widgets/
│   │   ├── test/
│   │   └── pubspec.yaml
│   │
│   ├── src/
│   │   ├── components/
│   │   ├── services/
│   │   ├── App.tsx
│   │   ├── data.ts
│   │   ├── index.css
│   │   └── types.ts
│   │
│   ├── firebase.json
│   └── .firebaserc
│
├── .gitignore
├── package.json
└── package-lock.json
```

---

# 🤝 Contributing

Contributions and suggestions are welcome.

Recommended workflow:

```bash
git checkout -b feature/your-feature
```

Make your changes, test them, and commit:

```bash
git add .
git commit -m "Add your feature"
git push origin feature/your-feature
```

Then create a Pull Request.

---

# 📄 License

License information should be added before public production distribution.

If this project is intended to remain an academic/student project, the repository owner should explicitly define the terms under which the source code can be reused.

---

# 👨‍💻 Project

**Job Finder Mobile Application for Unskilled and Semi-Skilled Workers**

Built with:

**Flutter + Dart + Firebase + React/TypeScript + Admin Dashboard**

Repository:

https://github.com/Ranjanravi07/Job-Finder-Mobile-Application-for-Unskilled-and-Semi-Skilled-Workers-

---

## ⭐ Project Vision

> **Connect workers with opportunities and employers with the right workers.**

The long-term goal is to create a simple, accessible, and reliable digital employment platform for unskilled and semi-skilled workers in Nepal.

## 👨‍💻 Author

**Ravi Ranjan Sah**

**Role:** Full-Stack Mobile Application Developer

### Responsibilities

- Flutter mobile application development
- Worker and Employer modules
- Firebase Authentication
- Cloud Firestore database
- Firebase Storage
- Job posting and job matching
- Application management
- Worker/Employer chat
- KYC/profile management
- Accessibility and voice features
- UI/UX implementation
- Testing and debugging
- Admin Dashboard integration

### Academic Information

- **Program:** Bachelor of Engineering In Information Technology (BEIT)
- **Institution:** Nepal College Of Information Technology
- **University:** Pokhara University 
- **Country:** Nepal

### Contact

- **Email:** sahranjanravi@gmail.com
- **GitHub:** https://github.com/Ranjanravi07
- **LinkedIn:** www.linkedin.com/in/ravi-ranjansah
