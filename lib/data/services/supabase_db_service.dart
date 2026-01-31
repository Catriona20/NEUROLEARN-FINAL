import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/screening_result.dart';
import '../models/user_profile.dart';
import '../models/learning_progress.dart';
import '../models/journey_day.dart';

class SupabaseDbService {
  static final SupabaseDbService _instance = SupabaseDbService._internal();
  factory SupabaseDbService() => _instance;
  SupabaseDbService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== USER PROFILE ====================

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Get profile status
  Future<Map<String, dynamic>?> getProfileStatus(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to get profile status: $e');
    }
  }

  // ==================== SCREENING RESULTS ====================

  /// Save screening result
  Future<void> saveScreeningResult({
    required String userId,
    required double handwritingScore,
    required double speechScore,
    required double typingScore,
    required double accuracy,
  }) async {
    try {
      await _supabase.from('screening_results').insert({
        'user_id': userId,
        'handwriting_score': handwritingScore,
        'speech_score': speechScore,
        'typing_score': typingScore,
        'accuracy': accuracy,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save screening result: $e');
    }
  }

  /// Get screening result
  Future<Map<String, dynamic>?> getScreeningResult(String userId) async {
    try {
      final response = await _supabase
          .from('screening_results')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Get all screening results (history)
  Future<List<Map<String, dynamic>>> getScreeningHistory(String userId) async {
    try {
      final response = await _supabase
          .from('screening_results')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get screening history: $e');
    }
  }

  // ==================== LEARNING PROGRESS ====================

  /// Get learning progress
  Future<Map<String, dynamic>?> getLearningProgress(String userId) async {
    try {
      final response = await _supabase
          .from('learning_progress')
          .select()
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to get learning progress: $e');
    }
  }

  /// Update learning progress
  Future<void> updateLearningProgress({
    required String userId,
    String? stage,
    int? level,
    int? xp,
    int? streak,
  }) async {
    try {
      final updates = <String, dynamic>{
        'last_active': DateTime.now().toIso8601String(),
      };

      if (stage != null) updates['stage'] = stage;
      if (level != null) updates['level'] = level;
      if (xp != null) updates['xp'] = xp;
      if (streak != null) updates['streak'] = streak;

      await _supabase
          .from('learning_progress')
          .update(updates)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to update learning progress: $e');
    }
  }

  /// Add XP to user
  Future<void> addXP(String userId, int xpToAdd) async {
    try {
      final current = await getLearningProgress(userId);
      if (current != null) {
        final currentXP = current['xp'] as int? ?? 0;
        await updateLearningProgress(
          userId: userId,
          xp: currentXP + xpToAdd,
        );
      }
    } catch (e) {
      throw Exception('Failed to add XP: $e');
    }
  }

  /// Update streak
  Future<void> updateStreak(String userId) async {
    try {
      final progress = await getLearningProgress(userId);
      if (progress != null) {
        final lastActive = DateTime.parse(progress['last_active']);
        final now = DateTime.now();
        final difference = now.difference(lastActive).inDays;

        int newStreak = progress['streak'] as int? ?? 0;

        if (difference == 1) {
          // Consecutive day
          newStreak++;
        } else if (difference > 1) {
          // Streak broken
          newStreak = 1;
        }
        // If difference == 0, same day, don't change streak

        await updateLearningProgress(
          userId: userId,
          streak: newStreak,
        );
      }
    } catch (e) {
      throw Exception('Failed to update streak: $e');
    }
  }

  // ==================== JOURNEY DAYS ====================

  /// Get all journey days for user
  Future<List<Map<String, dynamic>>> getJourneyDays(String userId) async {
    try {
      final response = await _supabase
          .from('journey_days')
          .select()
          .eq('user_id', userId)
          .order('day_number', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // If no journey days exist, return empty list
      return [];
    }
  }

  /// Initialize journey for user
  Future<void> initializeJourney(String userId) async {
    try {
      final defaultJourney = JourneyDay.getDefaultJourney();
      
      for (var day in defaultJourney) {
        await _supabase.from('journey_days').insert({
          'user_id': userId,
          'day_number': day.dayNumber,
          'stage': day.stage,
          'topic': day.topic,
          'description': day.description,
          'is_unlocked': day.isUnlocked,
          'is_completed': day.isCompleted,
          'total_tasks': day.totalTasks,
          'completed_tasks': day.completedTasks,
        });
      }
    } catch (e) {
      throw Exception('Failed to initialize journey: $e');
    }
  }

  /// Update journey day progress
  Future<void> updateJourneyDay({
    required String userId,
    required int dayNumber,
    bool? isUnlocked,
    bool? isCompleted,
    int? completedTasks,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (isUnlocked != null) updates['is_unlocked'] = isUnlocked;
      if (isCompleted != null) updates['is_completed'] = isCompleted;
      if (completedTasks != null) updates['completed_tasks'] = completedTasks;

      await _supabase
          .from('journey_days')
          .update(updates)
          .eq('user_id', userId)
          .eq('day_number', dayNumber);
    } catch (e) {
      throw Exception('Failed to update journey day: $e');
    }
  }

  // ==================== ANALYTICS ====================

  /// Save analytics event
  Future<void> saveAnalyticsEvent({
    required String userId,
    required String eventType,
    required Map<String, dynamic> eventData,
  }) async {
    try {
      await _supabase.from('analytics_events').insert({
        'user_id': userId,
        'event_type': eventType,
        'event_data': eventData,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save analytics event: $e');
    }
  }

  /// Get analytics for user
  Future<List<Map<String, dynamic>>> getAnalytics(
    String userId, {
    int limit = 30,
  }) async {
    try {
      final response = await _supabase
          .from('analytics_events')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get analytics: $e');
    }
  }

  // ==================== REALTIME SUBSCRIPTIONS ====================

  /// Subscribe to learning progress changes
  RealtimeChannel subscribeLearningProgress(
    String userId,
    void Function(Map<String, dynamic>) onUpdate,
  ) {
    return _supabase
        .channel('learning_progress:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'learning_progress',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }
}
