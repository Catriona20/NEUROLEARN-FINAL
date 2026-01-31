class UserProfile {
  final String uid;
  final String name;
  final int age;
  final String className;
  final String preferredLanguage;
  final String? parentEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    required this.className,
    required this.preferredLanguage,
    this.parentEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  // Age-based learning requirements
  bool get requiresTyping => age > 7;
  bool get requiresHandwriting => true;
  bool get requiresSpeech => true;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'className': className,
      'preferredLanguage': preferredLanguage,
      'parentEmail': parentEmail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      className: json['className'] as String,
      preferredLanguage: json['preferredLanguage'] as String,
      parentEmail: json['parentEmail'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  UserProfile copyWith({
    String? uid,
    String? name,
    int? age,
    String? className,
    String? preferredLanguage,
    String? parentEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      className: className ?? this.className,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      parentEmail: parentEmail ?? this.parentEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
