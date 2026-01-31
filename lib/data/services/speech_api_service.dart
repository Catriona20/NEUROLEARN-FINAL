import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

/// Service for communicating with FastAPI backend
/// Handles speech-to-text analysis for dyslexia screening
class SpeechApiService {
  // Backend URL - change this if deploying to production
  static const String baseUrl = 'http://localhost:8000';
  
  /// Upload audio file for speech-to-text analysis
  /// 
  /// Parameters:
  /// - userId: User's Supabase auth ID
  /// - audioFile: Recorded audio file (WAV, MP3, etc.)
  /// 
  /// Returns:
  /// - Map with transcription, confidence, and success status
  Future<Map<String, dynamic>> uploadSpeech({
    required String userId,
    required File audioFile,
  }) async {
    try {
      developer.log('Uploading speech for user: $userId', name: 'SpeechApiService');
      
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/speech-to-text?user_id=$userId'),
      );
      
      // Add audio file
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio_file',
          audioFile.path,
        ),
      );
      
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      developer.log('Response status: ${response.statusCode}', name: 'SpeechApiService');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('Speech uploaded successfully', name: 'SpeechApiService');
        return data;
      } else {
        developer.log('Upload failed: ${response.body}', name: 'SpeechApiService');
        throw Exception('Failed to upload speech: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error uploading speech: $e', name: 'SpeechApiService');
      rethrow;
    }
  }
  
  /// Get all speech transcriptions for a user
  /// 
  /// Parameters:
  /// - userId: User's Supabase auth ID
  /// 
  /// Returns:
  /// - List of transcriptions with metadata
  Future<List<Map<String, dynamic>>> getUserTranscriptions(String userId) async {
    try {
      developer.log('Fetching transcriptions for user: $userId', name: 'SpeechApiService');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/transcriptions/$userId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['transcriptions'] ?? []);
      } else {
        throw Exception('Failed to load transcriptions');
      }
    } catch (e) {
      developer.log('Error fetching transcriptions: $e', name: 'SpeechApiService');
      rethrow;
    }
  }
  
  /// Check if FastAPI backend is running
  /// 
  /// Returns:
  /// - true if backend is healthy, false otherwise
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      developer.log('Backend health check failed: $e', name: 'SpeechApiService');
      return false;
    }
  }
}
