import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:image_picker/image_picker.dart';

class HandwritingTaskScreen extends StatefulWidget {
  const HandwritingTaskScreen({super.key});

  @override
  State<HandwritingTaskScreen> createState() => _HandwritingTaskScreenState();
}

class _HandwritingTaskScreenState extends State<HandwritingTaskScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _shimmerController;
  late ConfettiController _confettiController;

  int currentTask = 1;
  final int totalTasks = 5;
  int starsEarned = 0;
  bool isTaskComplete = false;
  bool isProcessing = false;
  bool isScanning = false;
  File? uploadedImage;
  String extractedText = '';

  final List<String> prompts = [
    'Write: "The quick brown fox"',
    'Write your full name',
    'Write: "Learning is fun"',
    'Write: "I love reading"',
    'Write a short sentence',
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _shimmerController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          uploadedImage = File(image.path);
          isScanning = true;
        });

        _scanController.forward(from: 0);

        // Simulate OCR processing
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          isScanning = false;
          isProcessing = true;
        });

        // Simulate text extraction
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          extractedText = _simulateOCR();
          isProcessing = false;
        });

        // Auto-complete after showing result
        Future.delayed(const Duration(seconds: 2), () {
          _completeTask();
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  String _simulateOCR() {
    // Simulate OCR extraction with random accuracy
    final prompts = [
      'The quick brown fox',
      'John Smith',
      'Learning is fun',
      'I love reading',
      'Today is a great day',
    ];
    return prompts[currentTask - 1];
  }

  void _completeTask() {
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
          uploadedImage = null;
          extractedText = '';
        });
      } else {
        // All tasks complete - return to hub with overall score
        Navigator.pop(context, {'status': true, 'score': 0.85 + (Random().nextDouble() * 0.1)});
      }
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Upload Handwriting',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                                'Handwriting Task ✍️',
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
                          Color(0xFFFF6B9D),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Prompt
                  if (!isTaskComplete)
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
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        prompts[currentTask - 1],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Upload area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: isTaskComplete
                          ? _buildCompletionView()
                          : uploadedImage == null
                              ? _buildUploadCard()
                              : _buildImagePreview(),
                    ),
                  ),

                  const SizedBox(height: 20),
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

  Widget _buildUploadCard() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF6B9D).withOpacity(0.3),
              const Color(0xFFFF6B9D).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload Handwriting',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Take a photo or choose from gallery',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Image
            if (uploadedImage != null)
              Image.file(
                uploadedImage!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),

            // Scan overlay
            if (isScanning)
              AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) {
                  return Positioned(
                    top: _scanController.value * MediaQuery.of(context).size.height * 0.5,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF4ECDC4),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4ECDC4).withOpacity(0.8),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Processing shimmer
            if (isProcessing)
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(_shimmerController.value * 0.3),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Extracted text overlay
            if (extractedText.isNotEmpty && !isScanning && !isProcessing)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Color(0xFF4ECDC4),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Text Detected!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ECDC4).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4ECDC4),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            extractedText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Status text
            if (isScanning || isProcessing)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      isScanning ? 'Scanning...' : 'Processing...',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Color(0xFF4ECDC4),
          ),
          const SizedBox(height: 24),
          const Text(
            'Great Work!',
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
      ),
    );
  }
}
