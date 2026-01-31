class SupabaseConfig {
  // Replace these with your actual Supabase project credentials
  // Get these from: https://app.supabase.com/project/_/settings/api
  static const String supabaseUrl = 'https://njptrgkgvrzlpsepswul.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qcHRyZ2tndnJ6bHBzZXBzd3VsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3OTYzMzQsImV4cCI6MjA4NTM3MjMzNH0.6bNPvxadShqh98L1vP5hKn1rUBmAOjEpHWHzxrLwkFk';
  
  // Storage buckets
  static const String handwritingBucket = 'handwriting-uploads';
  static const String profileImagesBucket = 'profile-images';
  
  // JWT configuration
  static const Duration sessionDuration = Duration(hours: 24);
  static const Duration refreshThreshold = Duration(minutes: 5);

  /// Check if configuration is valid
  static bool get isValid {
    // Simple check: Keys should be long enough to be real
    return supabaseUrl.length > 10 && supabaseAnonKey.length > 10;
  }
}
