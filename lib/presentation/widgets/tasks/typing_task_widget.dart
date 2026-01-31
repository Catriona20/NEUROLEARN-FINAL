import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/app_colors.dart';
import '../common/glass_card.dart';
import '../common/gradient_button.dart';

class TypingTaskWidget extends StatefulWidget {
  final String sentence;
  final Function(int score) onComplete;

  const TypingTaskWidget({
    super.key,
    required this.sentence,
    required this.onComplete,
  });

  @override
  State<TypingTaskWidget> createState() => _TypingTaskWidgetState();
}

class _TypingTaskWidgetState extends State<TypingTaskWidget> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _speakSentence();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4); // Slower for better comprehension
    await _tts.setPitch(1.0);
  }

  Future<void> _speakSentence() async {
    setState(() => _isListening = true);
    await _tts.speak(widget.sentence);
    setState(() => _isListening = false);
  }

  void _checkAnswer() {
    final userInput = _controller.text.trim().toLowerCase();
    final correctAnswer = widget.sentence.trim().toLowerCase();
    
    // Calculate similarity score
    final score = _calculateSimilarity(userInput, correctAnswer);
    
    widget.onComplete(score);
  }

  int _calculateSimilarity(String input, String target) {
    if (input == target) return 100;
    
    final inputWords = input.split(' ');
    final targetWords = target.split(' ');
    
    int correctWords = 0;
    for (int i = 0; i < inputWords.length && i < targetWords.length; i++) {
      if (inputWords[i] == targetWords[i]) {
        correctWords++;
      }
    }
    
    return ((correctWords / targetWords.length) * 100).round();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructions
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.keyboard,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Typing Task',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type the sentence you hear',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.volume_up : Icons.volume_up_outlined,
                    color: AppColors.purpleLight,
                  ),
                  onPressed: _speakSentence,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Input Field
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _controller,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Type here...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),

        const Spacer(),

        // Submit Button
        GradientButton(
          onPressed: _controller.text.isNotEmpty ? _checkAnswer : null,
          child: const Text('Check Answer'),
        ),
      ],
    );
  }
}
