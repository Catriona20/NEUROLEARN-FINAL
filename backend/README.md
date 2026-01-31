# 🚀 FastAPI Backend Setup Guide

## 📋 **What This Does**

This FastAPI backend provides:
- 🎤 **Speech-to-Text** conversion using Google Speech Recognition
- 💾 **Database Storage** in Supabase
- 🔗 **REST API** for Flutter app integration
- 🔐 **Secure** user-specific data storage

---

## ⚡ **Quick Setup (3 Steps)**

### **Step 1: Install Python Dependencies**

Open terminal in the `backend` folder:

```bash
cd backend
pip install -r requirements.txt
```

### **Step 2: Create Database Table**

1. Go to Supabase SQL Editor
2. Copy contents of `migrations/001_speech_transcriptions.sql`
3. Run the script

### **Step 3: Start the Server**

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Server will run at: **http://localhost:8000**

---

## 🧪 **Test the API**

### **1. Health Check**
```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "message": "API and Database connected",
  "timestamp": "2026-01-31T08:43:00"
}
```

### **2. Test Speech-to-Text**

Using curl:
```bash
curl -X POST "http://localhost:8000/api/speech-to-text?user_id=YOUR_USER_ID" \
  -F "audio_file=@test_audio.wav"
```

Expected response:
```json
{
  "success": true,
  "transcription": "Hello, this is a test",
  "user_id": "abc-123-def",
  "confidence": 0.85,
  "message": "Speech processed and stored successfully"
}
```

### **3. Get User Transcriptions**
```bash
curl http://localhost:8000/api/transcriptions/YOUR_USER_ID
```

---

## 📊 **API Endpoints**

### **GET /** 
Health check

### **GET /health**
Detailed health check with database connection test

### **POST /api/speech-to-text**
Convert speech to text and store in database

**Parameters:**
- `audio_file` (file): Audio file (WAV, MP3, FLAC)
- `user_id` (query): User UUID from Supabase auth

**Response:**
```json
{
  "success": true,
  "transcription": "transcribed text",
  "user_id": "user-uuid",
  "confidence": 0.85,
  "message": "Speech processed and stored successfully"
}
```

### **GET /api/transcriptions/{user_id}**
Get all transcriptions for a user

**Response:**
```json
{
  "success": true,
  "user_id": "user-uuid",
  "transcriptions": [...],
  "count": 5
}
```

---

## 🔧 **Configuration**

### **Environment Variables (.env)**
```env
SUPABASE_URL=https://njptrgkgvrzlpsepswul.supabase.co
SUPABASE_KEY=your_supabase_anon_key
HOST=0.0.0.0
PORT=8000
DEBUG=True
```

---

## 🎯 **Integration with Flutter**

### **1. Add HTTP Package**
In `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

### **2. Create API Service**
```dart
import 'package:http/http.dart' as http;

class SpeechApiService {
  final String baseUrl = 'http://localhost:8000';
  
  Future<Map<String, dynamic>> uploadSpeech(
    String userId, 
    File audioFile
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/speech-to-text?user_id=$userId'),
    );
    
    request.files.add(
      await http.MultipartFile.fromPath('audio_file', audioFile.path)
    );
    
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    return json.decode(responseData);
  }
}
```

### **3. Use in Screening Flow**
```dart
// In your screening screen
final apiService = SpeechApiService();
final result = await apiService.uploadSpeech(userId, audioFile);

print('Transcription: ${result['transcription']}');
```

---

## 🗄️ **Database Schema**

### **speech_transcriptions table:**
```sql
id              UUID (primary key)
user_id         UUID (references auth.users)
transcription   TEXT (the converted text)
confidence      DECIMAL (0.0 - 1.0)
audio_filename  TEXT (original filename)
created_at      TIMESTAMP
updated_at      TIMESTAMP
```

---

## 🚨 **Troubleshooting**

### **Error: "Module not found"**
```bash
pip install -r requirements.txt
```

### **Error: "Could not find the table speech_transcriptions"**
Run the migration SQL in Supabase SQL Editor

### **Error: "Speech recognition service unavailable"**
- Check internet connection (Google Speech API requires internet)
- Try a different audio file format

### **CORS Error from Flutter**
- Make sure backend is running
- Check CORS settings in `main.py`

---

## 📝 **Next Steps**

1. ✅ **Test the API** with curl or Postman
2. ✅ **Verify data** appears in Supabase `speech_transcriptions` table
3. ✅ **Integrate** with Flutter signup flow
4. 🔜 Add handwriting analysis
5. 🔜 Add typing test analysis

---

## 🎉 **You're Ready!**

Your FastAPI backend is now ready to process speech for dyslexia screening!

**Start the server:**
```bash
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Access API docs:**
http://localhost:8000/docs (Swagger UI)
