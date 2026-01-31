import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseStorageService {
  static final SupabaseStorageService _instance = SupabaseStorageService._internal();
  factory SupabaseStorageService() => _instance;
  SupabaseStorageService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload handwriting image
  Future<String> uploadHandwritingImage({
    required String userId,
    required File imageFile,
    required int taskNumber,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId/task_$taskNumber\_$timestamp.jpg';

      await _supabase.storage
          .from(SupabaseConfig.handwritingBucket)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(SupabaseConfig.handwritingBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload handwriting image: $e');
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId/profile_$timestamp.jpg';

      await _supabase.storage
          .from(SupabaseConfig.profileImagesBucket)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(SupabaseConfig.profileImagesBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String filePath,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Get all handwriting images for user
  Future<List<String>> getUserHandwritingImages(String userId) async {
    try {
      final files = await _supabase.storage
          .from(SupabaseConfig.handwritingBucket)
          .list(path: userId);

      return files.map((file) {
        return _supabase.storage
            .from(SupabaseConfig.handwritingBucket)
            .getPublicUrl('$userId/${file.name}');
      }).toList();
    } catch (e) {
      throw Exception('Failed to get handwriting images: $e');
    }
  }

  /// Download file
  Future<Uint8List> downloadFile({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final data = await _supabase.storage.from(bucket).download(filePath);
      return data;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }
}
