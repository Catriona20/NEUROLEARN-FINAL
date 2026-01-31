import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_router.dart';

class WelcomeChoiceScreen extends StatelessWidget {
  final bool isExistingUser;

  const WelcomeChoiceScreen({
    super.key,
    this.isExistingUser = false,
  });

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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome Text
                Text(
                  isExistingUser ? 'Welcome Back!' : 'Welcome to NeuroLearn!',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  isExistingUser
                      ? 'Great to see you again! What would you like to do?'
                      : 'Let\'s get started on your learning journey!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Option 1: Screening Test
                _buildOptionCard(
                  context: context,
                  icon: Icons.psychology,
                  title: isExistingUser
                      ? 'Retake Screening Test'
                      : 'Take Screening Test',
                  subtitle: isExistingUser
                      ? 'Update your learning profile with a new assessment'
                      : 'Help us personalize your learning experience',
                  color: const Color(0xFF4ECDC4),
                  onTap: () {
                    if (isExistingUser) {
                      // Existing users go directly to screening hub
                      context.push(AppRouter.screeningHub);
                    } else {
                      // New users go to screening intro first
                      context.push(AppRouter.screeningIntro);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Option 2: Go to Dashboard
                _buildOptionCard(
                  context: context,
                  icon: Icons.dashboard,
                  title: isExistingUser
                      ? 'Go to Dashboard'
                      : 'Start Learning Journey',
                  subtitle: isExistingUser
                      ? 'Continue where you left off'
                      : 'Begin your adventure with default settings',
                  color: const Color(0xFFFF6B6B),
                  onTap: () {
                    context.go(AppRouter.dashboard);
                  },
                ),

                if (!isExistingUser) ...[
                  const SizedBox(height: 24),
                  Text(
                    'You can always take the screening test later from settings',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 20),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
