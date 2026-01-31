class AppConstants {
  // App Info
  static const String appName = 'NeuroLearn';
  static const String appTagline = 'Learn with Joy, Grow with Confidence';
  
  // Age Groups
  static const int minAge = 3;
  static const int maxAge = 13;
  static const int typingMandatoryAge = 7;
  
  // Learning Session
  static const int tasksPerSession = 5;
  static const int maxDailyGoal = 30; // minutes
  
  // Journey Days
  static const int totalJourneyDays = 5;
  
  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String profileSubcollection = 'profile';
  static const String progressSubcollection = 'progress';
  static const String journeySubcollection = 'journey';
  static const String analyticsSubcollection = 'analytics';
  
  // Storage Paths
  static const String handwritingPath = 'handwriting';
  static const String audioPath = 'audio';
  static const String ocrDataPath = 'ocr_data';
  
  // Task Types
  static const String taskTypeTyping = 'typing';
  static const String taskTypeHandwriting = 'handwriting';
  static const String taskTypeSpeech = 'speech';
  
  // Journey Topics
  static const List<String> journeyTopics = [
    'Letters & Phonics',
    'Word Recognition',
    'Sentence Building',
    'Reading Comprehension',
    'Memory Games',
  ];
  
  // Motivational Quotes
  static const List<String> motivationalQuotes = [
    'Every word you learn is a step forward! 🌟',
    'You\'re doing amazing! Keep going! 🚀',
    'Reading is your superpower! 💪',
    'Practice makes progress! 🎯',
    'You\'re a learning champion! 🏆',
    'Believe in yourself! You can do it! ✨',
    'Every day you\'re getting better! 🌈',
    'Your brain is growing stronger! 🧠',
  ];
  
  // Languages
  static const List<String> supportedLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Hindi',
  ];
  
  // Scoring
  static const int perfectScore = 100;
  static const int goodScore = 75;
  static const int averageScore = 50;
}
