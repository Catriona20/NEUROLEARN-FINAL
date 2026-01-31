import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/app_colors.dart';
import '../common/glass_card.dart';
import '../common/gradient_button.dart';

class HandwritingTaskWidget extends StatefulWidget {
  final String sentence;
  final Function(int score) onComplete;

  const HandwritingTaskWidget({
    super.key,
    required this.sentence,
    required this.onComplete,
  });

  @override
  State<HandwritingTaskWidget> createState() => _HandwritingTaskWidgetState();
}

class _HandwritingTaskWidgetState extends State<HandwritingTaskWidget> {
  late SignatureController _signatureController;
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: AppColors.purplePrimary,
      exportBackgroundColor: AppColors.backgroundMedium,
    );
    _initTts();
    _speakSentence();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.0);
  }

  Future<void> _speakSentence() async {
    setState(() => _isListening = true);
    await _tts.speak(widget.sentence);
    setState(() => _isListening = false);
  }

  void _clearDrawing() {
    _signatureController.clear();
  }

  Future<void> _submitDrawing() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // In a real app, you would use OCR here
    // For now, we'll give a random score based on drawing complexity
    final points = _signatureController.points.length;
    final score = (points / 100 * 100).clamp(50, 100).toInt();
    
    widget.onComplete(score);
  }

  @override
  void dispose() {
    _signatureController.dispose();
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
                    Icons.draw,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Handwriting Task',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Write the sentence with your finger',
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

        // Drawing Pad
        Expanded(
          child: GlassCard(
            child: Column(
              children: [
                Expanded(
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearDrawing,
                        tooltip: 'Clear',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Submit Button
        GradientButton(
          onPressed: _submitDrawing,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
