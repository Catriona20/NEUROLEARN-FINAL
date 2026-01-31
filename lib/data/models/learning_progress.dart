class LearningProgress {
  final String uid;
  final int totalTasksCompleted;
  final int dailyStreak;
  final int totalPoints;
  final double readingAccuracy;
  final double spellingAccuracy;
  final double pronunciationAccuracy;
  final int minutesToday;
  final int dailyGoalMinutes;
  final DateTime lastActivityDate;
  final Map<String, int> taskTypeCompletions;

  LearningProgress({
    required this.uid,
    this.totalTasksCompleted = 0,
    this.dailyStreak = 0,
    this.totalPoints = 0,
    this.readingAccuracy = 0.0,
    this.spellingAccuracy = 0.0,
    this.pronunciationAccuracy = 0.0,
    this.minutesToday = 0,
    this.dailyGoalMinutes = 30,
    required this.lastActivityDate,
    Map<String, int>? taskTypeCompletions,
  }) : taskTypeCompletions = taskTypeCompletions ?? {
          'typing': 0,
          'handwriting': 0,
          'speech': 0,
        };

  double get dailyGoalProgress => 
      minutesToday / dailyGoalMinutes.clamp(1, double.infinity);

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'totalTasksCompleted': totalTasksCompleted,
      'dailyStreak': dailyStreak,
      'totalPoints': totalPoints,
      'readingAccuracy': readingAccuracy,
      'spellingAccuracy': spellingAccuracy,
      'pronunciationAccuracy': pronunciationAccuracy,
      'minutesToday': minutesToday,
      'dailyGoalMinutes': dailyGoalMinutes,
      'lastActivityDate': lastActivityDate.toIso8601String(),
      'taskTypeCompletions': taskTypeCompletions,
    };
  }

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      uid: json['uid'] as String,
      totalTasksCompleted: json['totalTasksCompleted'] as int? ?? 0,
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      readingAccuracy: (json['readingAccuracy'] as num?)?.toDouble() ?? 0.0,
      spellingAccuracy: (json['spellingAccuracy'] as num?)?.toDouble() ?? 0.0,
      pronunciationAccuracy: (json['pronunciationAccuracy'] as num?)?.toDouble() ?? 0.0,
      minutesToday: json['minutesToday'] as int? ?? 0,
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 30,
      lastActivityDate: DateTime.parse(json['lastActivityDate'] as String),
      taskTypeCompletions: Map<String, int>.from(json['taskTypeCompletions'] as Map? ?? {}),
    );
  }

  LearningProgress copyWith({
    String? uid,
    int? totalTasksCompleted,
    int? dailyStreak,
    int? totalPoints,
    double? readingAccuracy,
    double? spellingAccuracy,
    double? pronunciationAccuracy,
    int? minutesToday,
    int? dailyGoalMinutes,
    DateTime? lastActivityDate,
    Map<String, int>? taskTypeCompletions,
  }) {
    return LearningProgress(
      uid: uid ?? this.uid,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      readingAccuracy: readingAccuracy ?? this.readingAccuracy,
      spellingAccuracy: spellingAccuracy ?? this.spellingAccuracy,
      pronunciationAccuracy: pronunciationAccuracy ?? this.pronunciationAccuracy,
      minutesToday: minutesToday ?? this.minutesToday,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      taskTypeCompletions: taskTypeCompletions ?? this.taskTypeCompletions,
    );
  }
}
