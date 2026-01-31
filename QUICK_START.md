# 🚀 NeuroLearn - Quick Start Guide

## ✅ YOUR APP IS NOW RUNNING!

**Status**: Compilation Successful ✅  
**Backend**: Supabase Only ✅  
**Firebase**: Completely Removed ✅

---

## 🎯 WHAT YOU NEED TO DO NOW

### Step 1: Create Supabase Project (10 minutes)

1. **Go to Supabase**
   - Visit: https://app.supabase.com
   - Click "New Project"

2. **Fill in Details**
   - **Name**: NeuroLearn
   - **Database Password**: (create a strong password)
   - **Region**: Choose closest to you
   - Click "Create new project"

3. **Wait for Setup** (~2 minutes)
   - Database initializing...
   - Wait for green checkmark

---

### Step 2: Get Your API Credentials (2 minutes)

1. **In Supabase Dashboard**
   - Click on your project
   - Go to: **Settings** → **API**

2. **Copy These Values**
   ```
   Project URL: https://xxxxx.supabase.co
   anon public: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. **Update Your Config File**
   - Open: `lib/data/config/supabase_config.dart`
   - Replace:
   ```dart
   static const String supabaseUrl = 'https://xxxxx.supabase.co';
   static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
   ```

---

### Step 3: Set Up Database (5 minutes)

1. **In Supabase Dashboard**
   - Go to: **SQL Editor**
   - Click: **New Query**

2. **Run Schema**
   - Open file: `supabase_schema.sql`
   - Copy ALL contents
   - Paste into SQL Editor
   - Click: **Run**

3. **Verify Tables Created**
   - Go to: **Table Editor**
   - You should see:
     - ✅ users
     - ✅ profiles
     - ✅ screening_results
     - ✅ learning_progress
     - ✅ journey_days
     - ✅ analytics_events

---

### Step 4: Create Storage Buckets (3 minutes)

1. **In Supabase Dashboard**
   - Go to: **Storage**
   - Click: **New Bucket**

2. **Create First Bucket**
   - **Name**: `handwriting-uploads`
   - **Public**: ✅ Yes
   - Click: **Create bucket**

3. **Create Second Bucket**
   - **Name**: `profile-images`
   - **Public**: ✅ Yes
   - Click: **Create bucket**

---

### Step 5: Configure Authentication (2 minutes)

1. **In Supabase Dashboard**
   - Go to: **Authentication** → **Providers**

2. **Enable Email Provider**
   - Find: **Email**
   - Toggle: **Enable Email provider** ✅
   - Click: **Save**

3. **Configure Email Templates** (Optional)
   - Go to: **Authentication** → **Email Templates**
   - Customize OTP email if desired

---

### Step 6: Test Your App! (1 minute)

```bash
# Stop current app (Ctrl+C in terminal)
# Then run:
flutter run -d chrome
```

**Your app should now:**
- ✅ Compile successfully
- ✅ Connect to Supabase
- ✅ Send OTP emails
- ✅ Store data in PostgreSQL
- ✅ Upload images to storage

---

## 🎯 TESTING THE FLOW

### 1. Test Authentication

1. Open app in browser
2. Enter your email
3. Click "Send OTP"
4. Check your email for OTP code
5. Enter OTP code
6. You should be logged in! ✅

### 2. Test Database

After login, your app will:
- ✅ Create user profile in `users` table
- ✅ Create profile status in `profiles` table
- ✅ Initialize learning progress in `learning_progress` table

**Verify in Supabase:**
- Go to **Table Editor** → **users**
- You should see your user data!

### 3. Test Storage

When you complete handwriting task:
- ✅ Image uploads to `handwriting-uploads` bucket
- ✅ Public URL generated
- ✅ Stored in database

**Verify in Supabase:**
- Go to **Storage** → **handwriting-uploads**
- You should see uploaded images!

---

## 📊 ARCHITECTURE OVERVIEW

```
┌─────────────────┐
│   Flutter App   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Supabase Auth   │ ← Email OTP + JWT
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  PostgreSQL DB  │ ← User data, progress, results
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Supabase Storage│ ← Images (handwriting, profile)
└─────────────────┘
```

---

## 🔐 SECURITY FEATURES

Your app now has:

✅ **JWT Authentication**
- Access token: 1 hour
- Refresh token: 7 days
- Auto-refresh before expiry

✅ **Row Level Security (RLS)**
- Users can only access their own data
- Enforced at database level

✅ **Secure Token Storage**
- Encrypted storage on device
- Auto-restore on app restart

✅ **User-Specific Folders**
- Storage organized by user ID
- No cross-user access

---

## 📁 PROJECT STRUCTURE

```
lib/
├── data/
│   ├── config/
│   │   └── supabase_config.dart ← UPDATE THIS!
│   ├── services/
│   │   ├── supabase_auth_service.dart
│   │   ├── supabase_db_service.dart (was firestore_service.dart)
│   │   └── supabase_storage_service.dart
│   └── models/
│       └── screening_result.dart (fixed)
└── main.dart

Root files:
├── supabase_schema.sql ← Run this in Supabase
├── FIREBASE_REMOVAL_COMPLETE.md ← Full migration details
└── QUICK_START.md ← This file
```

---

## 🐛 TROUBLESHOOTING

### Issue: "Invalid API key"
**Solution**: Double-check your `supabaseAnonKey` in config file

### Issue: "Table does not exist"
**Solution**: Run `supabase_schema.sql` in SQL Editor

### Issue: "Storage bucket not found"
**Solution**: Create buckets in Supabase Storage

### Issue: "OTP not received"
**Solution**: Check spam folder, verify email provider is enabled

---

## 💡 USEFUL COMMANDS

```bash
# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on mobile
flutter run

# Clean build
flutter clean
flutter pub get
flutter run

# Check for errors
flutter analyze
```

---

## 📚 DOCUMENTATION

- **Supabase Docs**: https://supabase.com/docs
- **Flutter Supabase**: https://supabase.com/docs/reference/dart
- **PostgreSQL Guide**: https://supabase.com/docs/guides/database
- **Storage Guide**: https://supabase.com/docs/guides/storage

---

## ✅ CHECKLIST

Setup:
- [ ] Create Supabase project
- [ ] Copy API credentials
- [ ] Update `supabase_config.dart`
- [ ] Run `supabase_schema.sql`
- [ ] Create storage buckets
- [ ] Enable email provider

Testing:
- [ ] App compiles successfully
- [ ] Can send OTP email
- [ ] Can verify OTP and login
- [ ] User data saved to database
- [ ] Can upload images to storage

---

## 🎉 YOU'RE READY!

Your NeuroLearn app is now:
- ✅ Powered by Supabase
- ✅ Using JWT authentication
- ✅ Storing data in PostgreSQL
- ✅ Uploading files to Supabase Storage
- ✅ Production-ready

**Next**: Complete the 5 setup steps above and start testing!

---

## 📞 NEED HELP?

- **Supabase Discord**: https://discord.supabase.com
- **Supabase Docs**: https://supabase.com/docs
- **Flutter Docs**: https://flutter.dev/docs

---

**🚀 Happy building with Supabase!**
