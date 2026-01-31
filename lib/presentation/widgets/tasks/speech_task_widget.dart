import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/app_colors.dart';
import '../common/glass_card.dart';
import '../common/gradient_button.dart';

class SpeechTaskWidget extends StatefulWidget {
  final String sentence;
  final Function(int score) onComplete;

  const SpeechTaskWidget({
    super.key,
    required this.sentence,
    required this.onComplete,
  });

  @override
  State<SpeechTaskWidget> createState() => _SpeechTaskWidgetState();
}

class _SpeechTaskWidgetState extends State<SpeechTaskWidget>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  late AnimationController _pulseController;

  bool _isListening = false;
  bool _speechEnabled = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _initSpeech();
    _initTts();
    _speakSentence();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.0);
  }

  Future<void> _speakSentence() async {
    await _tts.speak(widget.sentence);
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
    );

    // Auto-stop after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (_isListening) {
        _stopListening();
      }
    });
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _checkPronunciation() {
    if (_recognizedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please speak first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final score = _calculateSimilarity(
      _recognizedText.toLowerCase(),
      widget.sentence.toLowerCase(),
    );

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
    _speech.stop();
    _tts.stop();
    _pulseController.dispose();
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
                  child: const Icon(Icons.mic, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Speech Task',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Read the sentence aloud',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.volume_up_outlined,
                    color: AppColors.purpleLight,
                  ),
                  onPressed: _speakSentence,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Microphone Button
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width:
                          120 +
                          (_isListening ? _pulseController.value * 20 : 0),
                      height:
                          120 +
                          (_isListening ? _pulseController.value * 20 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: AppColors.purplePrimary.withOpacity(
                                    0.5,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isListening
                              ? _stopListening
                              : _startListening,
                          customBorder: const CircleBorder(),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  _isListening ? 'Listening...' : 'Tap to speak',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_recognizedText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _recognizedText,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Submit Button
        GradientButton(
          onPressed: _recognizedText.isNotEmpty ? _checkPronunciation : null,
          child: const Text('Check Pronunciation'),
        ),
      ],
    );
  }
}
