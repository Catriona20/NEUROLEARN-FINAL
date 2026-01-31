class SupabaseConfig {
  // Replace these with your actual Supabase project credentials
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Storage buckets
  static const String handwritingBucket = 'handwriting-uploads';
  static const String profileImagesBucket = 'profile-images';
  
  // JWT configuration
  static const String jwtSecretKey = 'YOUR_JWT_SECRET';
  static const Duration sessionDuration = Duration(hours: 24);
  static const Duration refreshThreshold = Duration(minutes: 5);
}
