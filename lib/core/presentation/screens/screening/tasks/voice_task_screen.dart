import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class VoiceTaskScreen extends StatefulWidget {
  const VoiceTaskScreen({super.key});

  @override
  State<VoiceTaskScreen> createState() => _VoiceTaskScreenState();
}

class _VoiceTaskScreenState extends State<VoiceTaskScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late ConfettiController _confettiController;

  int currentTask = 1;
  final int totalTasks = 5;
  int starsEarned = 0;
  bool isTaskComplete = false;
  bool isRecording = false;
  double pronunciationScore = 0.0;

  final List<String> prompts = [
    'Say: HELLO',
    'Say: APPLE',
    'Say: BUTTERFLY',
    'Say: RAINBOW',
    'Say: WONDERFUL',
  ];

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      isRecording = true;
      pronunciationScore = 0.0;
    });
    _waveController.repeat();

    // Simulate recording for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _stopRecording();
    });
  }

  void _stopRecording() {
    setState(() {
      isRecording = false;
      pronunciationScore = 0.75 + (Random().nextDouble() * 0.25); // 75-100%
    });
    _waveController.stop();

    // Auto-complete after showing score
    Future.delayed(const Duration(milliseconds: 1500), () {
      _completeTask();
    });
  }

  void _completeTask() {
    setState(() {
      isTaskComplete = true;
      starsEarned = pronunciationScore > 0.9
          ? 3
          : pronunciationScore > 0.8
              ? 2
              : 1;
    });

    _confettiController.play();

    Future.delayed(const Duration(seconds: 2), () {
      if (currentTask < totalTasks) {
        setState(() {
          currentTask++;
          isTaskComplete = false;
          starsEarned = 0;
          pronunciationScore = 0.0;
        });
      } else {
        // All tasks complete - return to hub
        Navigator.pop(context, {'status': true, 'score': pronunciationScore});
      }
    });
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Voice Task 🎤',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4ECDC4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Prompt
                  if (!isTaskComplete)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        prompts[currentTask - 1],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Microphone button with waveform
                  if (!isTaskComplete) _buildMicrophoneSection(),

                  // Pronunciation score
                  if (pronunciationScore > 0 && !isTaskComplete)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Pronunciation Score',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${(pronunciationScore * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Completion view
                  if (isTaskComplete) _buildCompletionView(),

                  const Spacer(),
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

  Widget _buildMicrophoneSection() {
    return Column(
      children: [
        // Waveform visualization
        if (isRecording)
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(20, (index) {
                    final height = 10 +
                        (sin(_waveController.value * 2 * pi + index * 0.3) *
                            30);
                    return Container(
                      width: 4,
                      height: height.abs(),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF4ECDC4),
                            Color(0xFF6366F1),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),

        const SizedBox(height: 20),

        // Microphone button
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return GestureDetector(
              onTap: isRecording ? null : _startRecording,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isRecording
                        ? [
                            const Color(0xFFFF6B9D),
                            const Color(0xFFFF6B9D).withOpacity(0.7),
                          ]
                        : [
                            const Color(0xFF4ECDC4),
                            const Color(0xFF4ECDC4).withOpacity(0.7),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording
                              ? const Color(0xFFFF6B9D)
                              : const Color(0xFF4ECDC4))
                          .withOpacity(_pulseController.value * 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        Text(
          isRecording ? 'Recording...' : 'Tap to Record',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCompletionView() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle,
          size: 80,
          color: Color(0xFF4ECDC4),
        ),
        const SizedBox(height: 24),
        const Text(
          'Perfect!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
              color: Colors.amber,
            ),
          ),
        ),
      ],
    );
  }
}
