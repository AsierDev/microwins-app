# MicroWins 🚀

A Flutter habit-tracking app focused on **micro-habits** (2-5 minutes) with gamification, AI suggestions, and reliable background notifications.

## ✨ Features

### Core Functionality
- **Habit Management**: Create, track, and manage daily micro-habits
- **Smart Notifications**: Reliable WorkManager-based reminders (15-min intervals)
- **Offline-First**: Full offline support with Hive local storage
- **Cloud Sync**: Firebase Firestore synchronization when online
- **AI-Powered**: Personalized habit suggestions via OpenRouter API

### Gamification System
- 🔥 **Streak Tracking**: Build momentum with daily consecutive streaks
- 🎯 **Achievement System**: Unlock 15+ badges across 5 categories (Streak Master, Consistency Champion, Weekly Warrior, Milestone Master, Perfect Week)
- 📊 **Progress Dashboard**: Interactive charts with weekly trends and comparative statistics
- ⭐ **Level System**: Progress through 10 levels from "Beginner" to "Legend" with experience points
- 🏆 **Badge Rarity**: 5 rarity tiers (Common, Uncommon, Rare, Epic, Legendary) with visual distinctions
- 🎉 **Celebrations**: Confetti animations and notifications on habit completion and achievement unlocks
- 📈 **Statistics**: Comprehensive tracking of current streak, best streak, total completions, and weekly progress

### Technical Highlights
- **Multi-Process Notifications**: WorkManager + Firestore for reliable background tasks
- **Firebase Auth**: Email/password and Google Sign-In
- **AdMob Integration**: Banner ads for monetization

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.19+ / Dart 3.3+ |
| **State Management** | Riverpod (Code Generation) |
| **Navigation** | GoRouter |
| **Local Storage** | Hive |
| **Backend** | Firebase (Auth, Firestore) |
| **Notifications** | WorkManager + flutter_local_notifications |
| **AI** | OpenRouter API (Gemini, GPT-4, etc.) |
| **Ads** | Google Mobile Ads (AdMob) |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.19+
- Firebase Project ([Create one](https://console.firebase.google.com/))
- OpenRouter API Key ([Get one](https://openrouter.ai/))
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/microwins.git
   cd microwins
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   
   a. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)
   
   b. Add Android/iOS apps to your Firebase project
   
   c. Download configuration files:
      - Android: `google-services.json` → `android/app/`
      - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   
   d. Enable Authentication methods in Firebase Console:
      - Email/Password
      - Google Sign-In
   
   e. Create Firestore database (start in test mode)

4. **Environment Setup:**
   
   Create a `.env` file in the root directory:
   ```env
   OPENROUTER_API_KEY=your_api_key_here
   ```

5. **Code Generation:**
   
   Run build_runner to generate Riverpod and Hive code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

6. **Run the App:**
   ```bash
   # Android
   flutter run

   # iOS
   flutter run -d ios

   # Specific device
   flutter run -d <device-id>
   ```

---

## 📱 Architecture

### Clean Architecture

```
lib/
├── core/                    # Shared utilities
│   ├── notifications/       # WorkManager + Firestore notifications
│   ├── sync/               # Firebase sync manager
│   ├── local/              # Hive setup and configuration
│   └── theme/              # App theming
├── features/
│   ├── auth/               # Authentication (Firebase)
│   ├── habits/             # Habit CRUD operations
│   ├── gamification/       # Achievements, levels, and progress tracking
│   │   ├── domain/         # Services (AchievementService, GamificationService)
│   │   ├── data/           # Repository and models (HabitCompletionModel)
│   │   └── presentation/   # UI (ProgressScreen, BadgesScreen)
│   ├── ai_suggestions/     # OpenRouter AI integration
│   └── profile/            # User settings
└── firebase_options.dart   # Firebase configuration
```

### Notification System

**Problem Solved:** Android 12+ blocks recurring exact alarms, making traditional notification scheduling unreliable.

**Solution:** WorkManager + Firestore multi-process architecture

```
Main App Process              WorkManager Process
================              ===================
User creates habit            (every 15 minutes)
    ↓                                ↓
Save to Firestore  ←─────→  Read from Firestore
    ↓                                ↓
Save userId to          Read userId from
SharedPreferences       SharedPreferences
                                     ↓
                            Check for due habits
                                     ↓
                            Show notifications
```

**Key Features:**
- ✅ Works across app restarts
- ✅ Survives phone reboots
- ✅ Multi-process safe (Firestore + SharedPreferences)
- ✅ Notifications arrive within 0-15 minutes of scheduled time

**Trade-off:** Notifications may arrive up to 15 minutes late (Android WorkManager limitation)

---

## 🎮 Gamification System

### Overview

MicroWins features a comprehensive gamification system designed to maximize user engagement and habit consistency through psychological reinforcement mechanics.

### Achievement Categories

| Category | Icon | Focus | Badges |
|----------|------|-------|---------|
| **Streak Master** | 🔥 | Daily consecutive completions | 4 badges (3, 7, 30, 100 days) |
| **Consistency Champion** | 📅 | Monthly completion frequency | 3 badges (7, 20, 28+ days/month) |
| **Weekly Warrior** | 📈 | Weekly volume | 3 badges (5, 10, 20 habits/week) |
| **Milestone Master** | 🏆 | Cumulative achievements | 4 badges (10, 50, 100, 500 total) |
| **Perfect Week** | ⭐ | Weekly perfection | 2 badges (3+, 5+ habits) |

### Level Progression

- **10 Levels**: Principiante → Novato → Aprendiz → Practicante → Dedicado → Comprometido → Experto → Maestro → Gran Maestro → Leyenda
- **EXP Formula**: Each level requires `100 * level` additional EXP
- **Bonuses**: Streak bonuses (+5 to +20 EXP), first of day (+5 EXP), perfect week (+15 EXP)

---

## 🔔 Notification Behavior

| Scenario | Behavior |
|----------|----------|
| App open | Notification arrives 0-15 min after scheduled time |
| App closed | WorkManager continues checking every 15 min |
| Phone restart | WorkManager resumes automatically |
| No internet | Works offline (reads from Firestore cache) |

**Why 15 minutes?**
- Android restricts background tasks to save battery
- WorkManager is the only reliable solution on Android 12+
- Same approach used by Todoist, Microsoft To-Do, Google Keep

---

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Testing Notifications

1. **Sign in** to the app (saves userId to SharedPreferences)
2. **Create a habit** with a reminder time 5-10 minutes from now
3. **Close the app** completely
4. **Wait** for the notification (arrives within 15 min)

**View logs:**
```bash
flutter logs --device-id=<device-id> | grep -i "workmanager\|flutter"
```

Expected output:
```
🔔 WorkManager: Checking for due notifications...
📦 Found 1 habits in Firestore
✅ Showed notification for: [habit name]
```

---

## 🔧 Configuration

### Firebase
- `android/app/google-services.json` - Android config
- `ios/Runner/GoogleService-Info.plist` - iOS config
- `lib/firebase_options.dart` - Generated by FlutterFire CLI

### Environment Variables
- `OPENROUTER_API_KEY` - AI suggestions API key

### Android Permissions
Required permissions in `AndroidManifest.xml`:
- `INTERNET` - Network access
- `POST_NOTIFICATIONS` - Show notifications (Android 13+)
- `RECEIVE_BOOT_COMPLETED` - Restart WorkManager after reboot
- `WAKE_LOCK` - Keep WorkManager running

---

## 📦 Dependencies

### Core
- `flutter_riverpod` - State management
- `riverpod_annotation` - Code generation
- `go_router` - Navigation
- `hive_flutter` - Local storage

### Firebase
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Cloud database
- `google_sign_in` - Google OAuth

### Notifications
- `flutter_local_notifications` - Show notifications
- `workmanager` - Background task scheduling
- `shared_preferences` - Multi-process data sharing
- `permission_handler` - Runtime permissions

### AI & Ads
- `http` - OpenRouter API calls
- `google_mobile_ads` - AdMob integration

---

## 🚢 Deployment

### Android

1. **Build release APK:**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle (for Play Store):**
   ```bash
   flutter build appbundle --release
   ```

3. **Install on device:**
   ```bash
   flutter install --device-id=<device-id>
   ```

### iOS

1. **Build for iOS:**
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode** for App Store submission

---

## 🐛 Troubleshooting

### Notifications not arriving

**Issue:** "Found 0 habits in Firestore" in logs

**Solution:**
1. Sign out and sign in again (saves userId to SharedPreferences)
2. Verify habit has a `reminderTime` set
3. Check Firestore rules allow read access

**Issue:** Notifications delayed more than 15 minutes

**Solution:**
- Check battery optimization settings (Settings → Apps → MicroWins → Battery → Unrestricted)
- Verify WorkManager is running: `adb shell dumpsys jobscheduler | grep microwins`

### Firebase connection issues

**Issue:** "No user logged in" in WorkManager logs

**Solution:**
- Ensure user is signed in before creating habits
- Check `SharedPreferences` has `current_user_id` key

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Follow [Conventional Commits](https://www.conventionalcommits.org/)
4. Submit a pull request

---

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Check existing documentation in `/docs`

---

**Built with ❤️ using Flutter**
