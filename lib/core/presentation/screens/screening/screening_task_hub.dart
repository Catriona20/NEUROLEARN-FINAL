import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_router.dart';
import '../../../../data/services/supabase_db_service.dart';
import '../../../../data/services/supabase_auth_service.dart';

class ScreeningTaskHub extends StatefulWidget {
  final int userAge;

  const ScreeningTaskHub({super.key, required this.userAge});

  @override
  State<ScreeningTaskHub> createState() => _ScreeningTaskHubState();
}

class _ScreeningTaskHubState extends State<ScreeningTaskHub>
    with TickerProviderStateMixin {
  final SupabaseDbService _dbService = SupabaseDbService();
  final SupabaseAuthService _authService = SupabaseAuthService();
  late AnimationController _floatController;

  // Track completion status and scores
  bool handwritingComplete = false;
  double handwritingScore = 0.0;

  bool voiceComplete = false;
  double voiceScore = 0.0;

  bool typingComplete = false;
  double typingScore = 0.0;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  bool get isTypingRequired => widget.userAge > 7;

  bool get canProceed {
    // Only voice task is required, handwriting and typing are optional
    return voiceComplete;
  }

  int get completedTasks {
    int count = 0;
    if (handwritingComplete) count++;
    if (voiceComplete) count++;
    if (typingComplete) count++;
    return count;
  }

  int get totalRequiredTasks => 1; // Only voice task is required

  Future<void> _completeScreeningAndNavigate() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Save screening results to database
        await _dbService.saveScreeningResult(
          userId: user.id,
          handwritingScore: handwritingScore,
          speechScore: voiceScore,
          typingScore: typingScore,
          accuracy: (handwritingScore + voiceScore + typingScore) / 3,
        );
        
        if (mounted) {
          // Navigate to dashboard after saving
          context.go(AppRouter.dashboard);
        }
      }
    } catch (e) {
      // Even if save fails, navigate to dashboard
      if (mounted) {
        context.go(AppRouter.dashboard);
      }
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
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
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
                        'Screening Tasks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Progress card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Progress',
                      '$completedTasks/$totalRequiredTasks',
                      Icons.check_circle,
                    ),
                    _buildStatItem(
                      'Age',
                      '${widget.userAge}',
                      Icons.child_care,
                    ),
                    _buildStatItem(
                      'Status',
                      canProceed ? 'Ready!' : 'In Progress',
                      canProceed ? Icons.celebration : Icons.pending,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Task cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildTaskCard(
                      title: 'Handwriting Task',
                      subtitle: 'Draw and write letters',
                      icon: Icons.edit,
                      color: const Color(0xFFFF6B9D),
                      isRequired: false,
                      isCompleted: handwritingComplete,
                      onTap: () async {
                        final result = await context.push(
                          AppRouter.screeningHandwriting,
                        );
                        if (result is Map && result['status'] == true) {
                          setState(() {
                            handwritingComplete = true;
                            handwritingScore = result['score'] ?? 0.8;
                          });
                        }
                      },
                      delay: 0,
                    ),
                    _buildTaskCard(
                      title: 'Voice Task',
                      subtitle: 'Speak and pronounce words',
                      icon: Icons.mic,
                      color: const Color(0xFF4ECDC4),
                      isRequired: true,
                      isCompleted: voiceComplete,
                      onTap: () async {
                        final result = await context.push(
                          AppRouter.screeningVoice,
                        );
                        if (result is Map && result['status'] == true) {
                          setState(() {
                            voiceComplete = true;
                            voiceScore = result['score'] ?? 0.8;
                          });
                        }
                      },
                      delay: 0.1,
                    ),
                    _buildTaskCard(
                      title: 'Typing Task',
                      subtitle: 'Type words with the monkey!',
                      icon: Icons.keyboard,
                      color: const Color(0xFFFFA07A),
                      isRequired: false,
                      isCompleted: typingComplete,
                      onTap: () async {
                        final result = await context.push(
                          AppRouter.screeningTyping,
                        );
                        if (result is Map && result['status'] == true) {
                          setState(() {
                            typingComplete = true;
                            typingScore = result['score'] ?? 0.8;
                          });
                        }
                      },
                      delay: 0.2,
                    ),
                  ],
                ),
              ),

              // Complete button
              if (canProceed)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _completeScreeningAndNavigate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.celebration, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Go to Dashboard',
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
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isRequired,
    required bool isCompleted,
    required VoidCallback onTap,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, sin(_floatController.value * 2 * pi + delay) * 5),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF4ECDC4)
                    : Colors.white.withOpacity(0.3),
                width: isCompleted ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 35),
                      ),
                      const SizedBox(width: 16),

                      // Title and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (isCompleted)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF4ECDC4),
                                    size: 24,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isRequired
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.blue.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isRequired
                                      ? Colors.red.withOpacity(0.5)
                                      : Colors.blue.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                isRequired ? 'REQUIRED' : 'OPTIONAL',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isRequired
                                      ? Colors.red.shade200
                                      : Colors.blue.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
