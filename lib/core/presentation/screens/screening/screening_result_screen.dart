import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../../utils/app_router.dart';
import '../../../../data/models/screening_result.dart';
import '../../../../data/services/firestore_service.dart';

class ScreeningResultScreen extends StatefulWidget {
  final double handwritingScore;
  final double voiceScore;
  final double typingScore;

  const ScreeningResultScreen({
    super.key,
    this.handwritingScore = 0.85,
    this.voiceScore = 0.92,
    this.typingScore = 0.78,
  });

  @override
  State<ScreeningResultScreen> createState() => _ScreeningResultScreenState();
}

class _ScreeningResultScreenState extends State<ScreeningResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _trophyController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 500), () {
      _progressController.forward();
      _trophyController.forward();
      _confettiController.play();
      _saveResults();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _trophyController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _saveResults() async {
    // In a real app, we would get the actual user ID from AuthService
    // For now, we'll use a dummy ID
    const dummyUid = 'user_123';
    
    final result = ScreeningResult(
      uid: dummyUid,
      handwritingScore: widget.handwritingScore,
      speechScore: widget.voiceScore,
      typingScore: widget.typingScore,
      overallScore: overallScore,
      accuracy: widget.typingScore, // Using typing score as accuracy for now
      speed: 45, // Dummy speed
      learningPathLevel: overallScore < 0.7 ? 'intermediate' : 'advanced',
      completedAt: DateTime.now(),
      tasksCompleted: {
        'handwriting': true,
        'voice': true,
        'typing': widget.typingScore > 0,
      },
    );

    // Save to Firestore (Simulated if Firebase not fully setup)
    try {
      // await FirestoreService().saveScreeningResult(result);
    } catch (e) {
      debugPrint('Failed to save results: $e');
    }
  }

  double get overallScore =>
      (widget.handwritingScore + widget.voiceScore + widget.typingScore) / 
      (widget.typingScore > 0 ? 3 : 2);

  String get performanceLevel {
    if (overallScore >= 0.9) return 'Excellent';
    if (overallScore >= 0.75) return 'Great';
    if (overallScore >= 0.6) return 'Good';
    return 'Keep Practicing';
  }

  Color get performanceColor {
    if (overallScore >= 0.9) return const Color(0xFF4ECDC4);
    if (overallScore >= 0.75) return const Color(0xFFFFA07A);
    return const Color(0xFFFF6B9D);
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
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Screening Complete! 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Trophy animation
                        AnimatedBuilder(
                          animation: _trophyController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _trophyController.value,
                              child: Opacity(
                                opacity: _trophyController.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        performanceColor,
                                        performanceColor.withOpacity(0.7),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: performanceColor.withOpacity(0.5),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.emoji_events,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Overall score
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Overall Performance',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                performanceLevel,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: performanceColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(overallScore * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Individual skill scores
                        const Text(
                          'Skill Breakdown',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildSkillBar(
                          'Handwriting ✍️',
                          widget.handwritingScore,
                          const Color(0xFFFF6B9D),
                        ),
                        _buildSkillBar(
                          'Speech 🎤',
                          widget.voiceScore,
                          const Color(0xFF4ECDC4),
                        ),
                        if (widget.typingScore > 0)
                          _buildSkillBar(
                            'Typing 🐒',
                            widget.typingScore,
                            const Color(0xFFFFA07A),
                          ),

                        const SizedBox(height: 32),

                        // Encouraging message
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                performanceColor.withOpacity(0.3),
                                performanceColor.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 40,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getEncouragingMessage(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Continue button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRouter.dashboard),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: performanceColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Start Learning Journey',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                  numberOfParticles: 30,
                  gravity: 0.3,
                  colors: const [
                    Color(0xFFFF6B9D),
                    Color(0xFF4ECDC4),
                    Color(0xFFFFA07A),
                    Color(0xFFFFB88C),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillBar(String label, double score, Color color) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${(score * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: score * _progressController.value,
                  minHeight: 12,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getEncouragingMessage() {
    if (overallScore >= 0.9) {
      return "Outstanding work! You're a natural learner. Your personalized journey is ready to help you reach even greater heights!";
    } else if (overallScore >= 0.75) {
      return "Great job! You've shown wonderful potential. We've created a special learning path just for you to build on these strengths!";
    } else if (overallScore >= 0.6) {
      return "Good effort! Everyone learns differently, and we've designed your journey to match your unique style. Let's grow together!";
    } else {
      return "You did it! Remember, this is just the beginning. Your personalized journey will help you improve step by step. Let's start learning!";
    }
  }
}
