import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../../data/services/supabase_db_service.dart';
import '../../../../data/services/supabase_auth_service.dart';

class LearningSessionScreen extends StatefulWidget {
  final int dayNumber;

  const LearningSessionScreen({
    super.key,
    required this.dayNumber,
  });

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _characterController;
  late AnimationController _progressController;
  late ConfettiController _confettiController;
  late TextEditingController _typingController; 

  int currentTask = 1;
  int totalTasks = 3; // Reduced from 5 to 3
  int starsEarned = 0;
  bool isTaskComplete = false;

  // Character image paths for each level
  Map<int, String> characterImages = {
    1: 'assets/images/characters/harry_potter.png',
    2: 'assets/images/characters/hermione_granger.png',
    3: 'assets/images/characters/ron_weasley.png',
    4: 'assets/images/characters/luna_lovegood.png',
    5: 'assets/images/characters/neville_longbottom.png',
    6: 'assets/images/characters/cedric_diggory.png',
    7: 'assets/images/characters/draco_malfoy.png',
    8: 'assets/images/characters/ginny_weasley.png',
    9: 'assets/images/characters/cho_chang.png',
    10: 'assets/images/characters/sirius_black.png',
    11: 'assets/images/characters/hagrid.png',
    12: 'assets/images/characters/character_unlock.png', // Generic for last level
  };

  // Character names for each level
  Map<int, String> levelCharacters = {
    1: 'Harry Potter',
    2: 'Hermione Granger',
    3: 'Ron Weasley',
    4: 'Luna Lovegood',
    5: 'Neville Longbottom',
    6: 'Cedric Diggory',
    7: 'Draco Malfoy',
    8: 'Ginny Weasley',
    9: 'Cho Chang',
    10: 'Sirius Black',
    11: 'Hagrid',
    12: 'Dobby',
  };

  // Simplified tasks: Typing, Reading, Speaking easy words (Gamified Monkey Typing)
  Map<int, List<String>> levelTasks = {
    1: ['Type: CAT', 'Read: BAT', 'Say: MAT'],
    2: ['Type: DOG', 'Read: LOG', 'Say: FOG'],
    3: ['Type: SUN', 'Read: RUN', 'Say: FUN'],
    4: ['Type: BIG', 'Read: PIG', 'Say: DIG'],
    5: ['Type: RED', 'Read: BED', 'Say: FED'],
    6: ['Type: DAY', 'Read: SAY', 'Say: PLAY'],
    7: ['Type: EAT', 'Read: FAT', 'Say: HAT'],
    8: ['Type: LOOK', 'Read: BOOK', 'Say: COOK'],
    9: ['Type: KITE', 'Read: BITE', 'Say: SIT'],
    10: ['Type: JUMP', 'Read: BUMP', 'Say: LAMP'],
    11: ['Type: FISH', 'Read: DISH', 'Say: WISH'],
    12: ['Type: STAR', 'Read: FAR', 'Say: CAR'],
  };

  List<String> get currentLevelTasks {
    return levelTasks[widget.dayNumber] ?? ['Type: FUN', 'Read: RUN', 'Say: SUN'];
  }

  @override
  void initState() {
    super.initState();
    _typingController = TextEditingController();
    _typingController.addListener(() {
      setState(() {});
    });

    _characterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _characterController.dispose();
    _progressController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _completeTask() {
    // Validation for typing tasks
    final currentTaskText = currentLevelTasks[currentTask - 1];
    if (currentTaskText.startsWith('Type: ')) {
      final targetWord = currentTaskText.split(': ')[1].trim();
      if (_typingController.text.trim().toUpperCase() != targetWord) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keep trying! Type the characters exactly.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    setState(() {
      isTaskComplete = true;
      starsEarned = Random().nextInt(2) + 2; // 2-3 stars
    });

    _confettiController.play();

    Future.delayed(const Duration(seconds: 2), () {
      if (currentTask < totalTasks) {
        setState(() {
          currentTask++;
          isTaskComplete = false;
          starsEarned = 0;
          _typingController.clear(); // Clear input
        });
        _progressController.forward(from: 0);
      } else {
        // All tasks complete
        _showCompletionDialog();
      }
    });
  }

  Future<void> _saveProgress() async {
    try {
      final authService = SupabaseAuthService();
      final dbService = SupabaseDbService();
      final user = authService.currentUser;
      
      if (user != null) {
        // 1. Mark current day as completed
        await dbService.updateJourneyDay(
            userId: user.id, 
            dayNumber: widget.dayNumber, 
            isCompleted: true,
            completedTasks: 3
        );
        
        // 2. Unlock next level
        await dbService.updateJourneyDay(
            userId: user.id, 
            dayNumber: widget.dayNumber + 1, 
            isUnlocked: true
        );
        
        // 3. Add XP (e.g., 50 XP per level)
        await dbService.addXP(user.id, 50);
        
        // 4. Update overall Level
        final progress = await dbService.getLearningProgress(user.id);
        if (progress != null) {
          final currentMaxLevel = progress['level'] as int? ?? 1;
          if (widget.dayNumber >= currentMaxLevel) {
             await dbService.updateLearningProgress(
               userId: user.id, 
               level: widget.dayNumber + 1
             );
          }
           await dbService.updateStreak(user.id);
        }
      }
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void _showCompletionDialog() {
    _saveProgress();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1a1a2e).withOpacity(0.95),
                const Color(0xFF16213e).withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 80,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(height: 16),
              const Text(
                'Level Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve mastered Level ${widget.dayNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Character unlock card with image
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4AF37).withOpacity(0.3),
                      const Color(0xFFD4AF37).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // Character image
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          characterImages[widget.dayNumber] ?? 'assets/images/characters/character_unlock.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF1a1a2e),
                              child: const Icon(
                                Icons.person_add,
                                color: Color(0xFFD4AF37),
                                size: 60,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'New Character Unlocked!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      levelCharacters[widget.dayNumber] ?? 'Magical Character',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'serif',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF1a1a2e),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue Journey',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Level ${widget.dayNumber}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Task $currentTask of $totalTasks',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: currentTask / totalTasks,
                        minHeight: 10,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Animated magical wand/character guide
                  AnimatedBuilder(
                    animation: _characterController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          sin(_characterController.value * 2 * pi) * 10,
                        ),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 50,
                            color: Color(0xFF1a1a2e),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Task card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD4AF37).withOpacity(0.2),
                              const Color(0xFFD4AF37).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isTaskComplete) ...[
                              const Icon(
                                Icons.menu_book,
                                size: 60,
                                color: Color(0xFFD4AF37),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                currentLevelTasks[currentTask - 1],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'serif',
                                ),
                              ),
                              if (currentLevelTasks[currentTask - 1].startsWith('Type: ')) ...[
                                const SizedBox(height: 24),
                                TextField(
                                  controller: _typingController,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Type here...',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: const Color(0xFFD4AF37).withOpacity(0.5),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD4AF37),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 48),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _completeTask,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: const Color(0xFF1a1a2e),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    currentLevelTasks[currentTask - 1].startsWith('Type: ') 
                                        ? 'Check Typing' 
                                        : 'I Did It!',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Icon(
                                Icons.check_circle,
                                size: 80,
                                color: Color(0xFFD4AF37),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Brilliant!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4AF37),
                                  fontFamily: 'serif',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  3,
                                  (index) => Icon(
                                    index < starsEarned ? Icons.star : Icons.star_border,
                                    size: 48,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.3,
                  colors: const [
                    Color(0xFFD4AF37),
                    Color(0xFFFFD700),
                    Color(0xFF740001),
                    Color(0xFF1A472A),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
