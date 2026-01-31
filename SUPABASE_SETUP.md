# NeuroLearn Supabase Migration Guide

## 🚀 Complete Firebase → Supabase Migration

This guide covers the complete migration from Firebase to Supabase for the NeuroLearn app.

---

## 📋 Prerequisites

1. **Supabase Account**: Sign up at [supabase.com](https://supabase.com)
2. **Flutter SDK**: Version 3.8.1 or higher
3. **Dart SDK**: Version 3.8.1 or higher

---

## 🔧 Step 1: Create Supabase Project

1. Go to [app.supabase.com](https://app.supabase.com)
2. Click "New Project"
3. Fill in project details:
   - **Name**: NeuroLearn
   - **Database Password**: (save this securely)
   - **Region**: Choose closest to your users
4. Wait for project to be created (~2 minutes)

---

## 🗄️ Step 2: Set Up Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Click "New Query"
3. Copy the entire contents of `supabase_schema.sql`
4. Paste and click "Run"
5. Verify all tables are created in **Table Editor**

### Tables Created:
- ✅ `users`
- ✅ `profiles`
- ✅ `screening_results`
- ✅ `learning_progress`
- ✅ `journey_days`
- ✅ `analytics_events`

---

## 📦 Step 3: Create Storage Buckets

1. Go to **Storage** in Supabase dashboard
2. Click "New Bucket"

### Bucket 1: handwriting-uploads
- **Name**: `handwriting-uploads`
- **Public**: ✅ Yes
- **File size limit**: 5MB
- **Allowed MIME types**: `image/jpeg, image/png`

### Bucket 2: profile-images
- **Name**: `profile-images`
- **Public**: ✅ Yes
- **File size limit**: 2MB
- **Allowed MIME types**: `image/jpeg, image/png`

### Storage Policies:

For each bucket, add these policies:

```sql
-- Allow authenticated users to upload their own files
CREATE POLICY "Users can upload own files"
ON storage.objects FOR INSERT
WITH CHECK (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to view their own files
CREATE POLICY "Users can view own files"
ON storage.objects FOR SELECT
USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to delete their own files
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING (auth.uid()::text = (storage.foldername(name))[1]);
```

---

## 🔐 Step 4: Configure Authentication

1. Go to **Authentication** → **Settings**
2. Enable **Email** provider
3. Configure **Email Templates**:

### OTP Email Template:
```html
<h2>Your NeuroLearn Login Code</h2>
<p>Hi there!</p>
<p>Your verification code is:</p>
<h1 style="font-size: 32px; color: #8B5CF6;">{{ .Token }}</h1>
<p>This code will expire in 5 minutes.</p>
<p>If you didn't request this code, please ignore this email.</p>
```

4. Set **Site URL**: `http://localhost:3000` (for development)
5. Add **Redirect URLs**: 
   - `http://localhost:3000/**`
   - Your production URL when ready

---

## 🔑 Step 5: Get API Credentials

1. Go to **Settings** → **API**
2. Copy these values:

```
Project URL: https://xxxxx.supabase.co
anon public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

3. Open `lib/core/config/supabase_config.dart`
4. Replace placeholders:

```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## 📱 Step 6: Install Dependencies

Run in terminal:

```bash
flutter pub get
```

This will install:
- ✅ `supabase_flutter` - Supabase SDK
- ✅ `flutter_secure_storage` - Secure token storage
- ✅ `jwt_decoder` - JWT token validation

---

## 🏗️ Architecture Overview

### Authentication Flow:

```
User enters email
    ↓
Send OTP via Supabase Auth
    ↓
User enters OTP
    ↓
Verify OTP
    ↓
JWT tokens issued (access + refresh)
    ↓
Tokens stored in secure storage
    ↓
User authenticated
```

### JWT Token Management:

- **Access Token**: Valid for 1 hour
- **Refresh Token**: Valid for 7 days
- **Auto-refresh**: When token expires in < 5 minutes
- **Secure Storage**: Tokens stored using `flutter_secure_storage`

---

## 🔒 Security Features

### Row Level Security (RLS)

All tables have RLS enabled. Users can only:
- ✅ View their own data
- ✅ Update their own data
- ✅ Insert their own data
- ❌ Cannot access other users' data

### JWT Validation

- Tokens validated on every request
- Automatic refresh before expiry
- Secure storage prevents token theft

### Storage Security

- User-specific folders
- Public read, authenticated write
- File size limits enforced

---

## 📊 Database Structure

### users
```sql
id (uuid) - Primary key
name (text) - User's full name
age (integer) - User's age (3-18)
class (text) - User's grade/class
language (text) - Preferred language
created_at (timestamp)
updated_at (timestamp)
```

### profiles
```sql
id (uuid) - Primary key
user_id (uuid) - Foreign key to users
onboarding_completed (boolean)
screening_completed (boolean)
created_at (timestamp)
updated_at (timestamp)
```

### screening_results
```sql
id (uuid) - Primary key
user_id (uuid) - Foreign key to users
handwriting_score (decimal 0-1)
speech_score (decimal 0-1)
typing_score (decimal 0-1)
accuracy (decimal 0-1)
created_at (timestamp)
```

### learning_progress
```sql
id (uuid) - Primary key
user_id (uuid) - Foreign key to users
stage (text) - Current learning stage
level (integer) - Current level
xp (integer) - Experience points
streak (integer) - Daily streak count
last_active (timestamp)
created_at (timestamp)
updated_at (timestamp)
```

### journey_days
```sql
id (uuid) - Primary key
user_id (uuid) - Foreign key to users
day_number (integer) - Day in journey
stage (text) - Learning stage
topic (text) - Day topic
description (text) - Day description
is_unlocked (boolean)
is_completed (boolean)
total_tasks (integer)
completed_tasks (integer)
created_at (timestamp)
updated_at (timestamp)
```

---

## 🧪 Testing the Setup

### 1. Test Authentication

```dart
final authService = SupabaseAuthService();

// Send OTP
await authService.sendOTP('test@example.com');

// Verify OTP
final response = await authService.verifyOTP(
  email: 'test@example.com',
  otp: '123456',
);

print('Authenticated: ${authService.isAuthenticated}');
```

### 2. Test Database

```dart
final dbService = SupabaseDbService();

// Get user profile
final profile = await dbService.getUserProfile(userId);
print('User: ${profile?['name']}');

// Save screening result
await dbService.saveScreeningResult(
  userId: userId,
  handwritingScore: 0.85,
  speechScore: 0.92,
  typingScore: 0.78,
  accuracy: 0.85,
);
```

### 3. Test Storage

```dart
final storageService = SupabaseStorageService();

// Upload handwriting image
final url = await storageService.uploadHandwritingImage(
  userId: userId,
  imageFile: File('path/to/image.jpg'),
  taskNumber: 1,
);

print('Uploaded to: $url');
```

---

## 🚀 Running the App

```bash
# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Or run on mobile
flutter run
```

---

## 🔄 Migration Checklist

- [x] Remove Firebase dependencies
- [x] Add Supabase dependencies
- [x] Create Supabase project
- [x] Set up database schema
- [x] Create storage buckets
- [x] Configure authentication
- [x] Update API credentials
- [x] Create auth service
- [x] Create database service
- [x] Create storage service
- [x] Update main.dart
- [x] Test authentication flow
- [x] Test database operations
- [x] Test file uploads

---

## 📝 Environment Variables (Production)

For production, use environment variables:

```dart
// lib/core/config/env.dart
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_DEV_URL',
  );
  
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_DEV_KEY',
  );
}
```

Run with:
```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx
```

---

## 🐛 Troubleshooting

### Issue: "Invalid API key"
**Solution**: Double-check your `supabaseAnonKey` in `supabase_config.dart`

### Issue: "Row Level Security policy violation"
**Solution**: Ensure RLS policies are created for all tables

### Issue: "Storage bucket not found"
**Solution**: Verify bucket names match exactly in config and dashboard

### Issue: "JWT token expired"
**Solution**: Token auto-refresh should handle this. Check `shouldRefreshToken()` logic

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)

---

## ✅ Next Steps

1. ✅ Complete Supabase setup
2. ✅ Test all authentication flows
3. ✅ Test database operations
4. ✅ Test file uploads
5. ⬜ Deploy to production
6. ⬜ Set up monitoring
7. ⬜ Configure backups

---

**🎉 Migration Complete!**

Your NeuroLearn app is now powered by Supabase with:
- JWT-based authentication
- PostgreSQL database
- Secure file storage
- Row-level security
- Real-time capabilities
