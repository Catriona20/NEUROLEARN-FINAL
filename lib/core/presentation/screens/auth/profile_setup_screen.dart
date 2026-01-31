import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_router.dart';
import '../../../../data/services/supabase_auth_service.dart';
import '../../../../data/services/supabase_db_service.dart';
import 'dart:developer' as developer;

class ProfileSetupScreen extends StatefulWidget {
  final int userAge;
  const ProfileSetupScreen({super.key, this.userAge = 7});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  final _authService = SupabaseAuthService();
  final _dbService = SupabaseDbService();
  
  bool _isNewUser = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    _checkUserStatus();
  }
  
  Future<void> _checkUserStatus() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Check if user has completed screening (for display purposes only)
        final screeningResult = await _dbService.getScreeningResult(user.id);
        
        if (mounted) {
          setState(() {
            _isNewUser = screeningResult == null;
            _isLoading = false;
          });
          
          // No auto-redirect - users make their choice on welcome screen
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      developer.log('⚠️ Error checking user status: $e', name: 'ProfileSetup');
      // If error, assume new user
      if (mounted) {
        setState(() {
          _isNewUser = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }
    
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
                        'Profile Setup',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Animated character guide
                      AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _bounceAnimation.value),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF6B9D), Color(0xFFFFB88C)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6B9D).withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.emoji_emotions,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Speech bubble - Different message for new vs existing
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _isNewUser 
                                  ? "Hi there! I'm NeuroLearn! 👋"
                                  : "Welcome back! 🎉",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isNewUser
                                  ? "I'll be your learning buddy! Let's set up your profile so I can help you learn better."
                                  : "Great to see you again! Let's continue your magical learning journey.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tips cards
                      _buildTipCard(
                        '🎯 Set Daily Goals',
                        'Practice a little every day for best results!',
                        const Color(0xFF4ECDC4),
                      ),
                      _buildTipCard(
                        '⭐ Earn Rewards',
                        'Complete tasks to earn stars and unlock new levels!',
                        const Color(0xFFFF6B9D),
                      ),
                      _buildTipCard(
                        '🎮 Play & Learn',
                        'Learning is fun with our interactive games!',
                        const Color(0xFFFFA07A),
                      ),

                      const SizedBox(height: 32),

                      // Complete button - Different action for new vs existing
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to welcome choice screen for all users
                            context.go('${AppRouter.welcomeChoice}?existing=${!_isNewUser}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isNewUser 
                                ? "Let's Start Learning!"
                                : "Continue to Dashboard",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      // Skip screening option for new users (optional)
                      if (_isNewUser) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go(AppRouter.dashboard),
                          child: Text(
                            'Skip for now',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
