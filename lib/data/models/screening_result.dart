class ScreeningResult {
  final String uid;
  final double handwritingScore;
  final double speechScore;
  final double typingScore;
  final double overallScore;
  final double accuracy;
  final int speed;
  final String learningPathLevel;
  final DateTime completedAt;
  final Map<String, bool> tasksCompleted;

  ScreeningResult({
    required this.uid,
    required this.handwritingScore,
    required this.speechScore,
    required this.typingScore,
    required this.overallScore,
    required this.accuracy,
    required this.speed,
    required this.learningPathLevel,
    required this.completedAt,
    required this.tasksCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'handwritingScore': handwritingScore,
      'speechScore': speechScore,
      'typingScore': typingScore,
      'overallScore': overallScore,
      'accuracy': accuracy,
      'speed': speed,
      'learningPathLevel': learningPathLevel,
      'completedAt': completedAt.toIso8601String(),
      'tasksCompleted': tasksCompleted,
    };
  }

  factory ScreeningResult.fromJson(Map<String, dynamic> json) {
    return ScreeningResult(
      uid: json['uid'] ?? '',
      handwritingScore: (json['handwritingScore'] ?? 0.0).toDouble(),
      speechScore: (json['speechScore'] ?? 0.0).toDouble(),
      typingScore: (json['typingScore'] ?? 0.0).toDouble(),
      overallScore: (json['overallScore'] ?? 0.0).toDouble(),
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      speed: json['speed'] ?? 0,
      learningPathLevel: json['learningPathLevel'] ?? 'foundations',
      completedAt: json['completedAt'] is String
          ? DateTime.parse(json['completedAt'])
          : DateTime.now(),
      tasksCompleted: Map<String, bool>.from(json['tasksCompleted'] ?? {}),
    );
  }
}
