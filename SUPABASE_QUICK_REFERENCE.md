# 🎯 NeuroLearn Supabase Quick Reference

## 🔐 Authentication Examples

### Send OTP
```dart
final authService = SupabaseAuthService();

try {
  await authService.sendOTP('user@example.com');
  // Show success message
  print('OTP sent successfully!');
} catch (e) {
  print('Error: $e');
}
```

### Verify OTP
```dart
try {
  final response = await authService.verifyOTP(
    email: 'user@example.com',
    otp: '123456',
  );
  
  if (response.session != null) {
    // User authenticated
    final userId = response.session!.user.id;
    print('Logged in: $userId');
  }
} catch (e) {
  print('Invalid OTP: $e');
}
```

### Check Auth Status
```dart
if (authService.isAuthenticated) {
  final user = authService.currentUser;
  print('User: ${user?.email}');
} else {
  // Redirect to login
}
```

### Sign Out
```dart
await authService.signOut();
```

---

## 💾 Database Examples

### Get User Profile
```dart
final dbService = SupabaseDbService();
final userId = await authService.getUserId();

final profile = await dbService.getUserProfile(userId!);
print('Name: ${profile?['name']}');
print('Age: ${profile?['age']}');
```

### Save Screening Result
```dart
await dbService.saveScreeningResult(
  userId: userId,
  handwritingScore: 0.85,
  speechScore: 0.92,
  typingScore: 0.78,
  accuracy: 0.85,
);
```

### Update Learning Progress
```dart
await dbService.updateLearningProgress(
  userId: userId,
  stage: 'Phonics',
  level: 2,
  xp: 150,
  streak: 5,
);
```

### Add XP
```dart
await dbService.addXP(userId, 50); // Add 50 XP
```

### Update Streak
```dart
await dbService.updateStreak(userId);
```

### Initialize Journey
```dart
await dbService.initializeJourney(userId);
```

### Update Journey Day
```dart
await dbService.updateJourneyDay(
  userId: userId,
  dayNumber: 2,
  isUnlocked: true,
  completedTasks: 3,
);
```

---

## 📦 Storage Examples

### Upload Handwriting Image
```dart
final storageService = SupabaseStorageService();

final imageFile = File('path/to/image.jpg');

final url = await storageService.uploadHandwritingImage(
  userId: userId,
  imageFile: imageFile,
  taskNumber: 1,
);

print('Uploaded to: $url');
```

### Upload Profile Image
```dart
final url = await storageService.uploadProfileImage(
  userId: userId,
  imageFile: File('path/to/profile.jpg'),
);
```

### Get User's Handwriting Images
```dart
final images = await storageService.getUserHandwritingImages(userId);
for (var url in images) {
  print('Image: $url');
}
```

---

## 🔄 Realtime Subscriptions

### Subscribe to Learning Progress
```dart
final channel = dbService.subscribeLearningProgress(
  userId,
  (data) {
    print('Progress updated: ${data['xp']}');
    // Update UI
  },
);

// Later, unsubscribe
await dbService.unsubscribe(channel);
```

---

## 🎨 UI Integration Examples

### Login Screen
```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = SupabaseAuthService();
  bool _otpSent = false;

  Future<void> _sendOTP() async {
    try {
      await _authService.sendOTP(_emailController.text);
      setState(() => _otpSent = true);
    } catch (e) {
      // Show error
    }
  }

  Future<void> _verifyOTP() async {
    try {
      await _authService.verifyOTP(
        email: _emailController.text,
        otp: _otpController.text,
      );
      // Navigate to dashboard
      context.go('/dashboard');
    } catch (e) {
      // Show error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          if (_otpSent)
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: 'OTP Code'),
            ),
          ElevatedButton(
            onPressed: _otpSent ? _verifyOTP : _sendOTP,
            child: Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
          ),
        ],
      ),
    );
  }
}
```

### Dashboard with Progress
```dart
class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dbService = SupabaseDbService();
  final _authService = SupabaseAuthService();
  Map<String, dynamic>? _progress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final userId = await _authService.getUserId();
    if (userId != null) {
      final progress = await _dbService.getLearningProgress(userId);
      setState(() => _progress = progress);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_progress == null) {
      return CircularProgressIndicator();
    }

    return Scaffold(
      body: Column(
        children: [
          Text('Level: ${_progress!['level']}'),
          Text('XP: ${_progress!['xp']}'),
          Text('Streak: ${_progress!['streak']}'),
          Text('Stage: ${_progress!['stage']}'),
        ],
      ),
    );
  }
}
```

---

## 🔒 Session Management

### Auto-Restore Session
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseAuthService.initialize();

  final authService = SupabaseAuthService();
  final restored = await authService.restoreSession();

  runApp(MyApp(isAuthenticated: restored));
}
```

### Check Token Expiry
```dart
if (await authService.shouldRefreshToken()) {
  await authService.refreshSession();
}
```

---

## 📊 Analytics Tracking

### Save Event
```dart
await dbService.saveAnalyticsEvent(
  userId: userId,
  eventType: 'task_completed',
  eventData: {
    'task_name': 'handwriting',
    'score': 0.85,
    'duration': 120, // seconds
  },
);
```

### Get Analytics
```dart
final events = await dbService.getAnalytics(userId, limit: 30);
for (var event in events) {
  print('${event['event_type']}: ${event['event_data']}');
}
```

---

## 🚨 Error Handling

### Try-Catch Pattern
```dart
try {
  await authService.sendOTP(email);
} on Exception catch (e) {
  if (e.toString().contains('Invalid email')) {
    // Show email error
  } else if (e.toString().contains('Rate limit')) {
    // Show rate limit error
  } else {
    // Show generic error
  }
}
```

### Loading States
```dart
bool _isLoading = false;

Future<void> _performAction() async {
  setState(() => _isLoading = true);
  try {
    await someAsyncOperation();
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

## 🎯 Common Patterns

### Complete Registration Flow
```dart
// 1. Send OTP
await authService.sendOTP(email);

// 2. Verify OTP
final response = await authService.verifyOTP(
  email: email,
  otp: otp,
);

// 3. Create profile
await authService.createUserProfile(
  userId: response.session!.user.id,
  name: name,
  age: age,
  className: className,
  language: language,
);

// 4. Initialize journey
await dbService.initializeJourney(response.session!.user.id);

// 5. Navigate to dashboard
context.go('/dashboard');
```

### Complete Screening Flow
```dart
// 1. Complete tasks and collect scores
final handwritingScore = await completeHandwritingTask();
final speechScore = await completeSpeechTask();
final typingScore = await completeTypingTask();

// 2. Save results
await dbService.saveScreeningResult(
  userId: userId,
  handwritingScore: handwritingScore,
  speechScore: speechScore,
  typingScore: typingScore,
  accuracy: (handwritingScore + speechScore + typingScore) / 3,
);

// 3. Update profile status
await authService.updateProfileStatus(
  userId: userId,
  screeningCompleted: true,
);

// 4. Navigate to results
context.go('/screening-result');
```

---

## 🔧 Configuration

### Update Supabase Credentials
```dart
// lib/core/config/supabase_config.dart

class SupabaseConfig {
  static const String supabaseUrl = 'https://xxxxx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
```

### Environment-Specific Config
```dart
class Env {
  static bool get isProduction => const bool.fromEnvironment('PRODUCTION');
  
  static String get supabaseUrl => isProduction
      ? 'https://prod.supabase.co'
      : 'https://dev.supabase.co';
}
```

---

## 📱 Platform-Specific Notes

### Web
- Secure storage uses browser's localStorage
- Session persists across page refreshes

### Mobile (iOS/Android)
- Secure storage uses Keychain/Keystore
- Biometric authentication possible

### Desktop
- Secure storage uses OS credential manager
- Session persists across app restarts

---

## 🎉 Quick Start Checklist

- [ ] Create Supabase project
- [ ] Run SQL schema
- [ ] Create storage buckets
- [ ] Update `supabase_config.dart`
- [ ] Test authentication
- [ ] Test database operations
- [ ] Test file uploads
- [ ] Deploy to production

---

**🚀 You're ready to build with Supabase!**
