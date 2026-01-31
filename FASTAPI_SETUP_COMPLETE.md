# 🎤 FastAPI Speech-to-Text Backend - COMPLETE SETUP

## ✅ **What I've Created**

### **Backend Structure:**
```
backend/
├── main.py                          # FastAPI application
├── requirements.txt                 # Python dependencies
├── .env                            # Environment configuration
├── .env.example                    # Template for .env
├── .gitignore                      # Git ignore rules
├── README.md                       # Full documentation
└── migrations/
    └── 001_speech_transcriptions.sql  # Database table
```

---

## 🚀 **Quick Start (Copy-Paste Commands)**

### **1. Install Dependencies**
```bash
cd backend
pip install -r requirements.txt
```

### **2. Create Database Table**
1. Open Supabase Dashboard: https://supabase.com/dashboard
2. Go to **SQL Editor**
3. Copy contents of `backend/migrations/001_speech_transcriptions.sql`
4. Click **Run**

### **3. Start FastAPI Server**
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

✅ **Server running at:** http://localhost:8000
✅ **API Docs:** http://localhost:8000/docs

---

## 📊 **How It Works**

### **Flow:**
```
Flutter App (Signup)
    ↓
User records speech
    ↓
Audio file sent to FastAPI
    ↓
POST /api/speech-to-text
    ↓
Google Speech Recognition
    ↓
Text transcription
    ↓
Stored in Supabase (speech_transcriptions table)
    ↓
Response sent back to Flutter
    ↓
Display transcription to user
```

---

## 🎯 **API Endpoint**

### **POST /api/speech-to-text**

**Request:**
```bash
curl -X POST "http://localhost:8000/api/speech-to-text?user_id=USER_UUID" \
  -F "audio_file=@recording.wav"
```

**Response:**
```json
{
  "success": true,
  "transcription": "Hello, my name is John",
  "user_id": "abc-123-def-456",
  "confidence": 0.85,
  "message": "Speech processed and stored successfully"
}
```

**Database Entry (Supabase):**
```
Table: speech_transcriptions
-----------------------------------
id:              uuid-generated
user_id:         abc-123-def-456
transcription:   "Hello, my name is John"
confidence:      0.85
audio_filename:  recording.wav
created_at:      2026-01-31 08:43:00
```

---

## 🔧 **Technology Stack**

| Component | Technology |
|-----------|-----------|
| **Framework** | FastAPI (Python) |
| **Speech Recognition** | Google Speech Recognition API |
| **Database** | Supabase (PostgreSQL) |
| **Audio Processing** | SpeechRecognition library |
| **Server** | Uvicorn (ASGI) |

---

## 📱 **Next: Flutter Integration**

### **Step 1: Add HTTP Package**
In `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
  file_picker: ^6.1.1  # For audio file selection
```

### **Step 2: Create API Service**
Create `lib/data/services/speech_api_service.dart`:
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class SpeechApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  Future<Map<String, dynamic>> uploadSpeechForAnalysis({
    required String userId,
    required File audioFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/speech-to-text?user_id=$userId'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio_file',
          audioFile.path,
        ),
      );
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to process speech');
      }
    } catch (e) {
      throw Exception('Error uploading speech: $e');
    }
  }
  
  Future<Map<String, dynamic>> getUserTranscriptions(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/transcriptions/$userId'),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load transcriptions');
    }
  }
}
```

### **Step 3: Use in Screening Screen**
```dart
// In your screening/signup flow
final speechApi = SpeechApiService();

// After user records audio
final result = await speechApi.uploadSpeechForAnalysis(
  userId: currentUser.id,
  audioFile: recordedAudioFile,
);

// Display result
print('Transcription: ${result['transcription']}');
print('Confidence: ${result['confidence']}');
```

---

## 🧪 **Testing**

### **Test 1: Health Check**
```bash
curl http://localhost:8000/health
```

### **Test 2: Upload Audio**
```bash
curl -X POST "http://localhost:8000/api/speech-to-text?user_id=test-user-123" \
  -F "audio_file=@test.wav"
```

### **Test 3: View in Database**
1. Go to Supabase **Table Editor**
2. Open `speech_transcriptions` table
3. See your transcription!

---

## 🎉 **You're Ready!**

Your FastAPI backend is now ready for speech-to-text analysis!

**Start the server and test:**
```bash
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Then visit: http://localhost:8000/docs for interactive API documentation!

---

## 📝 **What's Next?**

1. ✅ **Speech-to-Text** - DONE!
2. 🔜 **Handwriting Analysis** - Upload image, analyze writing
3. 🔜 **Typing Test** - Analyze typing patterns
4. 🔜 **Dyslexia Score Calculation** - Combine all three tests

Let me know when you're ready to test or add the next feature! 🚀
