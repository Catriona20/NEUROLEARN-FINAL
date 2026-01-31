class LearningTask {
  final String id;
  final String type; // 'typing', 'handwriting', 'speech'
  final String sentence;
  final String? audioUrl;
  final bool isCompleted;
  final int? score;
  final DateTime? completedAt;

  LearningTask({
    required this.id,
    required this.type,
    required this.sentence,
    this.audioUrl,
    this.isCompleted = false,
    this.score,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'sentence': sentence,
      'audioUrl': audioUrl,
      'isCompleted': isCompleted,
      'score': score,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory LearningTask.fromJson(Map<String, dynamic> json) {
    return LearningTask(
      id: json['id'] as String,
      type: json['type'] as String,
      sentence: json['sentence'] as String,
      audioUrl: json['audioUrl'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      score: json['score'] as int?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  LearningTask copyWith({
    String? id,
    String? type,
    String? sentence,
    String? audioUrl,
    bool? isCompleted,
    int? score,
    DateTime? completedAt,
  }) {
    return LearningTask(
      id: id ?? this.id,
      type: type ?? this.type,
      sentence: sentence ?? this.sentence,
      audioUrl: audioUrl ?? this.audioUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
