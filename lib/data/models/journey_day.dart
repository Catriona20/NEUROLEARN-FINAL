class JourneyDay {
  final int dayNumber;
  final String stage;
  final String topic;
  final String description;
  final bool isUnlocked;
  final bool isCompleted;
  final int totalTasks;
  final int completedTasks;
  final List<String> sentences;

  JourneyDay({
    required this.dayNumber,
    required this.stage,
    required this.topic,
    required this.description,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.totalTasks = 5,
    this.completedTasks = 0,
    List<String>? sentences,
  }) : sentences = sentences ?? [];

  double get progress => completedTasks / totalTasks.clamp(1, double.infinity);

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'stage': stage,
      'topic': topic,
      'description': description,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'sentences': sentences,
    };
  }

  factory JourneyDay.fromJson(Map<String, dynamic> json) {
    return JourneyDay(
      dayNumber: json['dayNumber'] as int,
      stage: json['stage'] as String? ?? 'Foundations',
      topic: json['topic'] as String,
      description: json['description'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      totalTasks: json['totalTasks'] as int? ?? 5,
      completedTasks: json['completedTasks'] as int? ?? 0,
      sentences: List<String>.from(json['sentences'] as List? ?? []),
    );
  }

  JourneyDay copyWith({
    int? dayNumber,
    String? stage,
    String? topic,
    String? description,
    bool? isUnlocked,
    bool? isCompleted,
    int? totalTasks,
    int? completedTasks,
    List<String>? sentences,
  }) {
    return JourneyDay(
      dayNumber: dayNumber ?? this.dayNumber,
      stage: stage ?? this.stage,
      topic: topic ?? this.topic,
      description: description ?? this.description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      sentences: sentences ?? this.sentences,
    );
  }

  // Default journey with stage-based structure
  static List<JourneyDay> getDefaultJourney() {
    return [
      // Stage 1: Foundations
      JourneyDay(
        dayNumber: 1,
        stage: 'Foundations',
        topic: 'Letter Recognition',
        description: 'Discover letter shapes and sounds',
        isUnlocked: true,
        sentences: [
          'The cat sat on the mat.',
          'A big dog ran fast.',
          'I see a red ball.',
          'The sun is hot.',
          'We play in the park.',
        ],
      ),
      JourneyDay(
        dayNumber: 2,
        stage: 'Foundations',
        topic: 'Sound Awareness',
        description: 'Explore beginning sounds',
        sentences: [
          'My friend has a blue bike.',
          'The bird sings in the tree.',
          'I like to read books.',
          'The moon shines at night.',
          'We eat lunch together.',
        ],
      ),

      // Stage 2: Phonics
      JourneyDay(
        dayNumber: 3,
        stage: 'Phonics',
        topic: 'Blending Sounds',
        description: 'Combine sounds to make words',
        sentences: [
          'The happy children play outside.',
          'My mother cooks delicious food.',
          'The little fish swims in water.',
          'I help my dad wash the car.',
          'The flowers smell very nice.',
        ],
      ),
      JourneyDay(
        dayNumber: 4,
        stage: 'Phonics',
        topic: 'Vowel Patterns',
        description: 'Learn short and long vowel sounds',
        sentences: [
          'The butterfly has colorful wings.',
          'We learn new things every day.',
          'The rain makes the plants grow.',
          'My sister draws beautiful pictures.',
          'The stars twinkle in the sky.',
        ],
      ),

      // Stage 3: Word Building
      JourneyDay(
        dayNumber: 5,
        stage: 'Word Building',
        topic: 'Word Families',
        description: 'Discover words that rhyme and connect',
        sentences: [
          'The elephant is very big and strong.',
          'I brush my teeth before bed.',
          'The rainbow has many colors.',
          'We share toys with our friends.',
          'The clock tells us the time.',
        ],
      ),
      JourneyDay(
        dayNumber: 6,
        stage: 'Word Building',
        topic: 'Compound Words',
        description: 'Build bigger words from smaller ones',
        sentences: [
          'The sunflower grows in the garden.',
          'I wear my backpack to school.',
          'The snowman melts in the sun.',
          'We play basketball in the park.',
          'The butterfly lands on the flower.',
        ],
      ),

      // Stage 4: Reading
      JourneyDay(
        dayNumber: 7,
        stage: 'Reading',
        topic: 'Sight Words',
        description: 'Recognize common words instantly',
        sentences: [
          'I want to go to the store.',
          'She said we can play later.',
          'They were very happy today.',
          'We have many books at home.',
          'You are my best friend.',
        ],
      ),
      JourneyDay(
        dayNumber: 8,
        stage: 'Reading',
        topic: 'Sentence Reading',
        description: 'Read complete sentences smoothly',
        sentences: [
          'The little puppy runs around the yard.',
          'My grandmother tells wonderful stories.',
          'The children laugh and play together.',
          'I enjoy reading books every night.',
          'The ocean waves crash on the beach.',
        ],
      ),

      // Stage 5: Comprehension
      JourneyDay(
        dayNumber: 9,
        stage: 'Comprehension',
        topic: 'Understanding Stories',
        description: 'Grasp what you read',
        sentences: [
          'The brave knight saved the kingdom.',
          'The curious cat explored the house.',
          'The kind teacher helped all students.',
          'The clever fox found the grapes.',
          'The tired bear went to sleep.',
        ],
      ),
      JourneyDay(
        dayNumber: 10,
        stage: 'Comprehension',
        topic: 'Making Connections',
        description: 'Relate stories to your life',
        sentences: [
          'The family went on a fun vacation.',
          'The friends worked together on a project.',
          'The student studied hard for the test.',
          'The team celebrated their big win.',
          'The artist created a beautiful painting.',
        ],
      ),

      // Stage 6: Fluency
      JourneyDay(
        dayNumber: 11,
        stage: 'Fluency',
        topic: 'Reading Speed',
        description: 'Read faster with confidence',
        sentences: [
          'The adventurous explorer discovered a hidden treasure.',
          'The magnificent castle stood tall on the hill.',
          'The delicious chocolate cake was everyones favorite.',
          'The energetic puppy played with the colorful ball.',
          'The beautiful garden bloomed with vibrant flowers.',
        ],
      ),
      JourneyDay(
        dayNumber: 12,
        stage: 'Fluency',
        topic: 'Expression',
        description: 'Read with feeling and rhythm',
        sentences: [
          'The excited children cheered loudly at the game.',
          'The peaceful forest was quiet and calm.',
          'The amazing magician performed incredible tricks.',
          'The happy birthday song filled the room.',
          'The gentle breeze rustled through the leaves.',
        ],
      ),

      // Stage 7: Mastery
      JourneyDay(
        dayNumber: 13,
        stage: 'Mastery',
        topic: 'Advanced Reading',
        description: 'Master complex texts',
        sentences: [
          'The determined athlete trained every single day.',
          'The intelligent scientist made an important discovery.',
          'The creative writer published an amazing story.',
          'The talented musician performed at the concert.',
          'The dedicated student achieved excellent grades.',
        ],
      ),
      JourneyDay(
        dayNumber: 14,
        stage: 'Mastery',
        topic: 'Reading Independence',
        description: 'Read anything with confidence',
        sentences: [
          'The extraordinary journey changed everything forever.',
          'The remarkable achievement inspired many people.',
          'The fascinating adventure continued through the night.',
          'The wonderful memories will last a lifetime.',
          'The incredible transformation was truly amazing.',
        ],
      ),
    ];
  }

  // Get stage color
  static Map<String, dynamic> getStageInfo(String stage) {
    final stageMap = {
      'Foundations': {'color': 0xFF8B5CF6, 'icon': '🌱'},
      'Phonics': {'color': 0xFF6366F1, 'icon': '🔤'},
      'Word Building': {'color': 0xFF4ECDC4, 'icon': '🧩'},
      'Reading': {'color': 0xFF10B981, 'icon': '📖'},
      'Comprehension': {'color': 0xFFF59E0B, 'icon': '💡'},
      'Fluency': {'color': 0xFFFF6B9D, 'icon': '⚡'},
      'Mastery': {'color': 0xFFFFA07A, 'icon': '🏆'},
    };
    return stageMap[stage] ?? {'color': 0xFF8B5CF6, 'icon': '🌟'};
  }
}
