import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_router.dart';
import '../../../../data/services/supabase_db_service.dart';
import '../../../../data/services/supabase_auth_service.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  int currentLevel = 1; 
  bool _isLoading = true;


  // Harry Potter themed levels with character unlocks
  final List<Map<String, dynamic>> journeyLevels = [
    {
      'level': 1,
      'title': 'The Sorting Hat',
      'character': 'Harry Potter',
      'stars': 3,
      'house': 'Gryffindor'
    },
    {
      'level': 2,
      'title': 'Wand Selection',
      'character': 'Hermione Granger',
      'stars': 0,
      'house': 'Gryffindor'
    },
    {
      'level': 3,
      'title': 'First Potions Class',
      'character': 'Ron Weasley',
      'stars': 0,
      'house': 'Gryffindor'
    },
    {
      'level': 4,
      'title': 'Charms Practice',
      'character': 'Luna Lovegood',
      'stars': 0,
      'house': 'Ravenclaw'
    },
    {
      'level': 5,
      'title': 'Defense Against Dark Arts',
      'character': 'Neville Longbottom',
      'stars': 0,
      'house': 'Gryffindor'
    },
    {
      'level': 6,
      'title': 'Herbology Garden',
      'character': 'Cedric Diggory',
      'stars': 0,
      'house': 'Hufflepuff'
    },
    {
      'level': 7,
      'title': 'Transfiguration Magic',
      'character': 'Draco Malfoy',
      'stars': 0,
      'house': 'Slytherin'
    },
    {
      'level': 8,
      'title': 'Quidditch Training',
      'character': 'Ginny Weasley',
      'stars': 0,
      'house': 'Gryffindor'
    },
    {
      'level': 9,
      'title': 'Ancient Runes',
      'character': 'Cho Chang',
      'stars': 0,
      'house': 'Ravenclaw'
    },
    {
      'level': 10,
      'title': 'Patronus Charm',
      'character': 'Sirius Black',
      'stars': 0,
      'house': 'Gryffindor'
    },
    {
      'level': 11,
      'title': 'Forbidden Forest',
      'character': 'Hagrid',
      'stars': 0,
      'house': 'Gryffindor'
    },
    {
      'level': 12,
      'title': 'Chamber of Secrets',
      'character': 'Dobby',
      'stars': 0,
      'house': 'Free Elf'
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchProgress();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _fetchProgress() async {
    try {
        final auth = SupabaseAuthService();
        final db = SupabaseDbService();
        final user = auth.currentUser;
        if (user != null) {
            final progress = await db.getLearningProgress(user.id);
            if (progress != null && mounted) {
                setState(() {
                    currentLevel = progress['level'] ?? 1;
                    _isLoading = false;
                });
            } else {
                 if (mounted) setState(() => _isLoading = false);
            }
        }
    } catch (e) {
        debugPrint(e.toString());
        if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color _getHouseColor(String house) {
    switch (house) {
      case 'Gryffindor':
        return const Color(0xFF740001);
      case 'Slytherin':
        return const Color(0xFF1A472A);
      case 'Ravenclaw':
        return const Color(0xFF0E1A40);
      case 'Hufflepuff':
        return const Color(0xFFECB939);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                          fontFamily: 'serif',
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Progress Overview
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4AF37).withOpacity(0.3),
                      const Color(0xFFD4AF37).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Level', '$currentLevel/${journeyLevels.length}'),
                    _buildStatItem('Stars', '${_getTotalStars()}'),
                    _buildStatItem('Characters', '${_getUnlockedCharacters()}/${journeyLevels.length}'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Journey Timeline
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: journeyLevels.length,
                  itemBuilder: (context, index) {
                    final level = journeyLevels[index];
                    final isCompleted = level['level'] < currentLevel;
                    final isCurrent = level['level'] == currentLevel;
                    // Unlock all levels except the last one (Level 12)
                    final isLocked = level['level'] == 12 && currentLevel < 12;

                    return _buildJourneyNode(
                      level['level'],
                      level['title'],
                      level['character'],
                      level['house'],
                      level['stars'],
                      isCompleted,
                      isCurrent,
                      isLocked,
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyNode(
    int level,
    String title,
    String character,
    String house,
    int stars,
    bool isCompleted,
    bool isCurrent,
    bool isLocked,
    int index,
  ) {
    Color nodeColor = _getHouseColor(house);
    IconData nodeIcon;

    if (isCompleted) {
      nodeIcon = Icons.check_circle;
    } else if (isCurrent) {
      nodeIcon = Icons.auto_awesome;
    } else {
      nodeIcon = Icons.lock;
      nodeColor = Colors.grey;
    }

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line and node
              SizedBox(
                width: 70,
                child: Column(
                  children: [
                    // Connecting line from previous
                    if (index > 0)
                      Container(
                        width: 3,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isCompleted
                                ? [const Color(0xFFD4AF37), const Color(0xFFD4AF37)]
                                : [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.3)],
                          ),
                        ),
                      ),
                    // Node with character initial
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isCurrent
                              ? [
                                  nodeColor,
                                  nodeColor.withOpacity(0.7),
                                ]
                              : [nodeColor, nodeColor],
                        ),
                        border: Border.all(
                          color: isCompleted || isCurrent 
                              ? const Color(0xFFD4AF37)
                              : Colors.white.withOpacity(0.3),
                          width: isCurrent ? 3 : 2,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withOpacity(_glowController.value * 0.8),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : [],
                      ),
                      child: isLocked
                          ? Icon(
                              nodeIcon,
                              color: Colors.white,
                              size: 28,
                            )
                          : Center(
                              child: Text(
                                character.split(' ').map((e) => e[0]).join(''),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    // Connecting line to next
                    if (index < journeyLevels.length - 1)
                      Expanded(
                        child: Container(
                          width: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isCompleted
                                  ? [const Color(0xFFD4AF37), const Color(0xFFD4AF37)]
                                  : [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.3)],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Card
              Expanded(
                child: GestureDetector(
                  onTap: isLocked
                      ? null
                      : () {
                          context.push('${AppRouter.learningSession}?day=$level');
                        },
                  child: Container(
                    margin: const EdgeInsets.only(left: 12, bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          nodeColor.withOpacity(0.4),
                          nodeColor.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCompleted || isCurrent
                            ? const Color(0xFFD4AF37).withOpacity(0.5)
                            : Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: nodeColor.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Level $level',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (isCompleted)
                              Row(
                                children: List.generate(
                                  3,
                                  (i) => Icon(
                                    i < stars ? Icons.star : Icons.star_border,
                                    color: const Color(0xFFD4AF37),
                                    size: 18,
                                  ),
                                ),
                              ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1a1a2e),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? Colors.white.withOpacity(0.4)
                                : Colors.white,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.person : Icons.person_outline,
                              color: isLocked
                                  ? Colors.white.withOpacity(0.3)
                                  : const Color(0xFFD4AF37),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                isCompleted
                                    ? 'Unlocked: $character'
                                    : isLocked
                                        ? '??? (Locked)'
                                        : 'Unlock: $character',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isLocked
                                      ? Colors.white.withOpacity(0.4)
                                      : const Color(0xFFD4AF37),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getTotalStars() {
    return journeyLevels
        .where((level) => level['level'] < currentLevel)
        .fold(0, (sum, level) => sum + (level['stars'] as int));
  }

  int _getUnlockedCharacters() {
    return journeyLevels
        .where((level) => level['level'] < currentLevel)
        .length;
  }
}
