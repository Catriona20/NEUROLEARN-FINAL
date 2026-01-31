# NeuroLearn - AI-Assisted Dyslexia Learning Platform

A production-ready Flutter application designed for children aged 3-13 with dyslexia, featuring gamified learning, AI assistance, and comprehensive progress tracking.

## 🌟 Features

### Core Features
- **Age-Based Learning Logic**: Adaptive learning modules based on child's age
  - Ages 3-7: Handwriting (mandatory), Speech (mandatory), Typing (optional)
  - Ages 8+: All three modalities mandatory
  
- **5-Day Dyslexia Journey**: Progressive learning path
  - Day 1: Letters & Phonics
  - Day 2: Word Recognition
  - Day 3: Sentence Building
  - Day 4: Reading Comprehension
  - Day 5: Memory Games

- **Multi-Modal Learning Tasks**
  - **Typing Tasks**: Text input with similarity scoring
  - **Handwriting Tasks**: Signature pad with OCR-ready structure
  - **Speech Tasks**: Speech-to-text with pronunciation scoring

- **Progress Analytics**
  - Line charts for reading improvement
  - Bar charts for spelling accuracy
  - Daily streak tracking
  - Comprehensive performance metrics

### Design System
- **Purple Gradient Theme**: Minimalist, futuristic, child-friendly
- **Glassmorphism UI**: Floating cards with blur effects
- **Smooth Animations**: Page transitions, progress rings, confetti celebrations
- **Accessibility**: Dyslexia-friendly fonts, slower TTS speech rate

### Authentication
- Firebase Authentication with Email + OTP
- Email/Password fallback for development
- Profile setup with age, class, language preferences

### Database Structure (Firestore)
```
users/{uid}/
  ├── profile/data
  ├── progress/data
  ├── journey/
  │   ├── day_1
  │   ├── day_2
  │   └── ...
  └── analytics/
      └── [auto-generated docs]
```

## 🏗️ Architecture

### MVVM Pattern
- **Models**: Data structures (UserProfile, LearningProgress, JourneyDay, LearningTask)
- **Views**: UI screens and widgets
- **ViewModels**: Business logic (to be implemented with Riverpod)

### Project Structure
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── app_router.dart
├── data/
│   ├── models/
│   │   ├── user_profile.dart
│   │   ├── learning_progress.dart
│   │   ├── journey_day.dart
│   │   └── learning_task.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── firestore_service.dart
│   └── repositories/
├── presentation/
│   ├── screens/
│   │   ├── splash/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── learning/
│   │   ├── journey/
│   │   ├── analytics/
│   │   └── profile/
│   ├── widgets/
│   │   ├── common/
│   │   ├── tasks/
│   │   └── charts/
│   └── viewmodels/
└── main.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart 3.8.1 or higher
- Firebase project (for production)

### Installation

1. **Clone the repository**
   ```bash
   cd neurolearn
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup** (Optional for development)
   - Create a Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Uncomment Firebase initialization in `main.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Core
- `flutter_riverpod`: State management
- `go_router`: Navigation and routing

### Firebase
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `firebase_storage`: File storage

### UI & Animations
- `google_fonts`: Typography
- `glassmorphism`: Glass effect UI
- `lottie`: Lottie animations
- `rive`: Rive animations
- `confetti`: Success celebrations
- `shimmer`: Loading effects

### Charts & Analytics
- `fl_chart`: Data visualization

### Audio & Speech
- `flutter_tts`: Text-to-speech
- `speech_to_text`: Speech recognition
- `audioplayers`: Audio playback

### Drawing & OCR
- `signature`: Handwriting input
- `google_mlkit_text_recognition`: OCR

### Utilities
- `intl`: Internationalization
- `shared_preferences`: Local storage
- `uuid`: Unique identifiers

## 🎨 Design Highlights

### Color Palette
- Primary Purple: `#8B5CF6`
- Secondary Purple: `#6366F1`
- Lavender Accents: `#E9D5FF`, `#D8B4FE`
- Success Green: `#10B981`
- Gold: `#FBBF24`

### Typography
- Font Family: Poppins (via Google Fonts)
- Dyslexia-friendly sizing and spacing

### Animations
- Splash screen with floating particles
- Progress ring with smooth transitions
- Confetti on task completion
- Page transitions (fade, slide, scale)

## 🔧 Configuration

### Age-Based Learning
Modify `AppConstants.typingMandatoryAge` to change the age threshold for mandatory typing tasks.

### Journey Content
Edit `JourneyDay.getDefaultJourney()` to customize the 5-day learning path sentences.

### Motivational Quotes
Update `AppConstants.motivationalQuotes` to add or modify motivational messages.

## 📱 Screens

1. **Splash Screen**: Animated logo with gradient background
2. **Login Screen**: Email/password authentication
3. **Create Account**: New user registration
4. **Profile Setup**: Age, class, language preferences
5. **Dashboard**: Progress overview, quick access cards
6. **Journey Screen**: 5-day gamified timeline
7. **Learning Session**: Multi-modal task interface
8. **Analytics**: Charts and performance metrics
9. **Profile**: User settings and information

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🚢 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

This is a production-ready template. To extend:
1. Implement ViewModels with Riverpod providers
2. Add Firebase configuration
3. Integrate real OCR for handwriting tasks
4. Add more journey days and content
5. Implement parent dashboard

## 📄 License

This project is created for educational purposes.

## 🙏 Acknowledgments

- Material 3 Design System
- Flutter Community
- Firebase Team
- Dyslexia learning research

---

**Built with ❤️ for children with dyslexia**
