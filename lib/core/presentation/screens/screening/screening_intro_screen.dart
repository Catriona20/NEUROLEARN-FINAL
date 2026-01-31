import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_router.dart';

class ScreeningIntroScreen extends StatefulWidget {
  final int userAge;
  const ScreeningIntroScreen({super.key, this.userAge = 7});

  @override
  State<ScreeningIntroScreen> createState() => _ScreeningIntroScreenState();
}

class _ScreeningIntroScreenState extends State<ScreeningIntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _characterController;
  late AnimationController _cardController;
  int _currentStep = 0;
  final int _totalSteps = 3;

  final List<Map<String, dynamic>> steps = [
    {
      'icon': Icons.auto_awesome,
      'title': 'Welcome to Your Screening!',
      'description':
          "Let's discover your unique learning style! This fun test will help us understand how you learn best.",
      'color': Color(0xFFFF6B9D),
    },
    {
      'icon': Icons.edit_note,
      'title': 'Three Fun Activities',
      'description':
          "You'll try handwriting ✍️, speaking 🎤, and typing 🐒. Each one is like a mini-game!",
      'color': Color(0xFF4ECDC4),
    },
    {
      'icon': Icons.celebration,
      'title': 'Earn Stars & Have Fun!',
      'description':
          "There's no right or wrong - just do your best! You'll earn stars and unlock your personalized learning journey.",
      'color': Color(0xFFFFA07A),
    },
  ];

  @override
  void initState() {
    super.initState();

    _characterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _cardController.forward();
  }

  @override
  void dispose() {
    _characterController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _cardController.forward(from: 0);
    } else {
      // Navigate to screening hub with age parameter
      context.push('${AppRouter.screeningHub}?age=${widget.userAge}');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _cardController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStepData = steps[_currentStep];

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
              // Header with skip button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: _previousStep,
                      )
                    else
                      const SizedBox(width: 48),
                    const Text(
                      'Screening Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('${AppRouter.screeningHub}?age=${widget.userAge}'),
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalSteps, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentStep ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: index == _currentStep
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              // Animated character
              AnimatedBuilder(
                animation: _characterController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      sin(_characterController.value * 2 * pi) * 15,
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            currentStepData['color'],
                            (currentStepData['color'] as Color).withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (currentStepData['color'] as Color)
                                .withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        currentStepData['icon'],
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Content card
              Expanded(
                child: AnimatedBuilder(
                  animation: _cardController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _cardController.value,
                      child: Transform.scale(
                        scale: 0.9 + (_cardController.value * 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentStepData['title'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  currentStepData['description'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Next button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentStep < _totalSteps - 1
                          ? 'Next'
                          : "Let's Start!",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
}
