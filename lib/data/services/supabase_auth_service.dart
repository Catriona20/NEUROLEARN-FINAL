import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/supabase_config.dart';
import 'dart:developer' as developer;

class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _accessTokenKey = 'supabase_access_token';
  static const String _refreshTokenKey = 'supabase_refresh_token';
  static const String _userIdKey = 'user_id';

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    developer.log('✅ Supabase initialized', name: 'SupabaseAuth');
  }

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// 🔥 SEND OTP - TRUE OTP MODE (NO MAGIC LINKS)
  /// This sends a 6-digit numeric code to the email
  Future<void> sendOTP(String email) async {
    try {
      developer.log('📧 Sending OTP to: $email', name: 'SupabaseAuth');
      
      // CRITICAL: Do NOT pass emailRedirectTo to force OTP mode
      // Added retry logic for "ClientFailed to fetch" errors
      int attempts = 0; 
      while (attempts < 3) {
        try {
          await _supabase.auth.signInWithOtp(
            email: email,
            shouldCreateUser: true,  // Auto-create user if doesn't exist
            // channel logic is handled automatically by providing 'email'
          );
          break; // Success, exit loop
        } catch (e) {
          attempts++;
          final message = e.toString();
          
          // Only retry if it's a fetch/network exception or retryable error
          if (attempts < 3 && (message.contains('FetchException') || message.contains('ClientFailed') || message.contains('Network'))) {
            developer.log('⚠️ Network error, retrying OTP ($attempts/3)...', name: 'SupabaseAuth');
            await Future.delayed(const Duration(seconds: 1));
            continue;
          }
          rethrow; // Re-throw other errors immediately
        }
      }
      
      developer.log('✅ OTP sent successfully to: $email', name: 'SupabaseAuth');
    } catch (e) {
      developer.log('❌ Failed to send OTP: $e', name: 'SupabaseAuth', error: e);
      
      // User-friendly error handling
      final message = e.toString().toLowerCase();
      if (message.contains('rate limit') || message.contains('429')) {
        throw Exception('⏳ Too many login attempts. Please wait a while or try a different email.');
      }
      if (message.contains('fetch') || message.contains('clientfailed')) {
        throw Exception('📶 Connection failed. Please check your internet or try again.');
      }
      
      throw Exception('Failed to send OTP. Please try again.');
    }
  }

  /// 🔥 VERIFY OTP - Verify the 6-digit code
  Future<AuthResponse> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      developer.log('🔐 Verifying OTP for: $email', name: 'SupabaseAuth');
      developer.log('📝 OTP Code: $otp', name: 'SupabaseAuth');
      
      AuthResponse response;
      
      try {
        // Attempt 1: Try as standard Email Login (Magic Link/OTP)
        developer.log('🔄 Attempting verification as Login (OtpType.email)...', name: 'SupabaseAuth');
        response = await _supabase.auth.verifyOTP(
          email: email,
          token: otp,
          type: OtpType.email, 
        );
      } catch (loginError) {
        // Attempt 2: If Login fails, try as New User Signup
        developer.log('⚠️ Login verification failed, trying as Signup (OtpType.signup)...', name: 'SupabaseAuth');
        response = await _supabase.auth.verifyOTP(
          email: email,
          token: otp,
          type: OtpType.signup,
        );
      }

      if (response.session != null) {
        developer.log('✅ OTP verified successfully', name: 'SupabaseAuth');
        developer.log('👤 User ID: ${response.session!.user.id}', name: 'SupabaseAuth');
        await _saveSession(response.session!);
      } else {
        developer.log('⚠️ OTP verification returned no session', name: 'SupabaseAuth');
      }

      return response;
    } catch (e) {
      developer.log('❌ OTP verification failed: $e', name: 'SupabaseAuth', error: e);
      
      // Provide user-friendly error messages
      if (e.toString().contains('Invalid token') || e.toString().contains('403')) {
        throw Exception('Invalid OTP. Please check the code and try again.');
      } else if (e.toString().contains('expired')) {
        throw Exception('OTP code has expired. Please request a new one.');
      } else {
        throw Exception('Failed to verify OTP: $e');
      }
    }
  }

  /// Save session tokens securely
  Future<void> _saveSession(Session session) async {
    try {
      await _secureStorage.write(
        key: _accessTokenKey,
        value: session.accessToken,
      );
      await _secureStorage.write(
        key: _refreshTokenKey,
        value: session.refreshToken,
      );
      await _secureStorage.write(
        key: _userIdKey,
        value: session.user.id,
      );
      developer.log('💾 Session saved securely', name: 'SupabaseAuth');
    } catch (e) {
      developer.log('❌ Failed to save session: $e', name: 'SupabaseAuth', error: e);
    }
  }

  /// Restore session from secure storage
  Future<bool> restoreSession() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (accessToken == null || refreshToken == null) {
        developer.log('⚠️ No session found', name: 'SupabaseAuth');
        return false;
      }

      // Check if token is expired
      if (JwtDecoder.isExpired(accessToken)) {
        developer.log('🔄 Token expired, refreshing...', name: 'SupabaseAuth');
        return await refreshSession();
      }

      // Set the session
      await _supabase.auth.setSession(accessToken);
      developer.log('✅ Session restored', name: 'SupabaseAuth');
      return true;
    } catch (e) {
      developer.log('❌ Failed to restore session: $e', name: 'SupabaseAuth', error: e);
      return false;
    }
  }

  /// Refresh session
  Future<bool> refreshSession() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        developer.log('⚠️ No refresh token found', name: 'SupabaseAuth');
        return false;
      }

      final response = await _supabase.auth.refreshSession(refreshToken);
      
      if (response.session != null) {
        await _saveSession(response.session!);
        developer.log('✅ Session refreshed', name: 'SupabaseAuth');
        return true;
      }
      return false;
    } catch (e) {
      developer.log('❌ Failed to refresh session: $e', name: 'SupabaseAuth', error: e);
      return false;
    }
  }

  /// Check if token needs refresh
  Future<bool> shouldRefreshToken() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken == null) return false;

      final expiryDate = JwtDecoder.getExpirationDate(accessToken);
      final timeUntilExpiry = expiryDate.difference(DateTime.now());

      return timeUntilExpiry < SupabaseConfig.refreshThreshold;
    } catch (e) {
      return false;
    }
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Get JWT access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _clearSession();
      developer.log('✅ User signed out', name: 'SupabaseAuth');
    } catch (e) {
      developer.log('❌ Failed to sign out: $e', name: 'SupabaseAuth', error: e);
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Clear session from secure storage
  Future<void> _clearSession() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userIdKey);
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Create user profile after authentication
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required int age,
    required String className,
    required String language,
  }) async {
    try {
      developer.log('👤 Creating user profile for: $userId', name: 'SupabaseAuth');
      
      // Insert into users table
      await _supabase.from('users').insert({
        'id': userId,
        'name': name,
        'age': age,
        'class': className,
        'language': language,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Insert into profiles table
      await _supabase.from('profiles').insert({
        'user_id': userId,
        'onboarding_completed': false,
        'screening_completed': false,
      });

      // Initialize learning progress
      await _supabase.from('learning_progress').insert({
        'user_id': userId,
        'stage': 'Foundations',
        'level': 1,
        'xp': 0,
        'streak': 0,
        'last_active': DateTime.now().toIso8601String(),
      });
      
      developer.log('✅ User profile created successfully', name: 'SupabaseAuth');
    } catch (e) {
      developer.log('❌ Failed to create user profile: $e', name: 'SupabaseAuth', error: e);
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Update profile completion status
  Future<void> updateProfileStatus({
    required String userId,
    bool? onboardingCompleted,
    bool? screeningCompleted,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (onboardingCompleted != null) {
        updates['onboarding_completed'] = onboardingCompleted;
      }
      if (screeningCompleted != null) {
        updates['screening_completed'] = screeningCompleted;
      }

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('user_id', userId);
          
      developer.log('✅ Profile status updated', name: 'SupabaseAuth');
    } catch (e) {
      developer.log('❌ Failed to update profile status: $e', name: 'SupabaseAuth', error: e);
      throw Exception('Failed to update profile status: $e');
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      // This is a workaround since Supabase doesn't have a direct method
      // You might need to implement this on the backend
      return false;
    } catch (e) {
      return false;
    }
  }
}
