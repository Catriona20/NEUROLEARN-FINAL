import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:developer' as developer;
import 'package:neurolearn/data/services/speech_api_service.dart';
import 'package:neurolearn/data/services/supabase_auth_service.dart';
import 'dart:math';

class SpeechTestScreen extends StatefulWidget {
  const SpeechTestScreen({super.key});

  @override
  State<SpeechTestScreen> createState() => _SpeechTestScreenState();
}

class _SpeechTestScreenState extends State<SpeechTestScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final SpeechApiService _speechApi = SpeechApiService();
  final SupabaseAuthService _authService = SupabaseAuthService();
  
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _speechEnabled = false;
  String? _transcription;
  double? _confidence;
  
  // Sample text for user to read
  final String _sampleText = "The quick brown fox jumps over the lazy dog. "
      "Reading helps us learn and grow every day.";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) => developer.log('Speech status: $status', name: 'SpeechTestScreen'),
        onError: (errorNotification) => developer.log('Speech error: $errorNotification', name: 'SpeechTestScreen'),
      );
      setState(() {});
    } catch (e) {
      developer.log('Error initializing speech: $e', name: 'SpeechTestScreen');
    }
  }

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_speechEnabled) {
      _initSpeech();
      return;
    }
    
    setState(() {
      _isRecording = true;
      _transcription = '';
      _confidence = 0.0;
    });

    try {
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _transcription = result.recognizedWords;
            _confidence = _calculateAccuracy(_sampleText, result.recognizedWords);
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: 'en_US',
        listenMode: ListenMode.dictation,
      );
    } catch (e) {
       developer.log('Error starting speech listen: $e', name: 'SpeechTestScreen');
       _showError('Failed to start listening');
       setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _speechToText.stop();
      setState(() {
        _isRecording = false;
      });
      
      // Save result to backend if needed
      if (_transcription != null && _transcription!.isNotEmpty) {
        _saveResult();
      }
    } catch (e) {
      developer.log('Error stopping recording: $e', name: 'SpeechTestScreen');
    }
  }

  double _calculateAccuracy(String target, String actual) {
    if (actual.isEmpty) return 0.0;
    
    final targetDisplay = target.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final actualDisplay = actual.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    int distance = _levenshtein(targetDisplay, actualDisplay);
    int maxLength = targetDisplay.length > actualDisplay.length ? targetDisplay.length : actualDisplay.length;
    
    if (maxLength == 0) return 1.0;
    
    return (1.0 - (distance / maxLength)).clamp(0.0, 1.0);
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }

  Future<void> _saveResult() async {
    // Optional: Send the locally processed result to backend for storage
    // using a new method in SpeechApiService that accepts text instead of audio
    // For now, we just rely on local state.
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
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
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Speech Test',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFFD4AF37),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Instructions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Read the text below clearly\n'
                        '2. Tap the microphone to start recording\n'
                        '3. Tap again to stop and analyze',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Sample Text to Read
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4AF37).withOpacity(0.2),
                        const Color(0xFFD4AF37).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4AF37),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Read this text:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _sampleText,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Recording Button
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isProcessing
                            ? null
                            : (_isRecording ? _stopRecording : _startRecording),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _isRecording
                                  ? [Colors.red, Colors.redAccent]
                                  : [const Color(0xFFD4AF37), const Color(0xFFFFD700)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording ? Colors.red : const Color(0xFFD4AF37))
                                    .withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isProcessing
                            ? 'Processing...'
                            : _isRecording
                                ? 'Tap to Stop'
                                : 'Tap to Record',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Results
                if (_transcription != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              'Analysis Complete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Transcription: $_transcription',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Continue Button
                if (_transcription != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to next step or dashboard
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF1a1a2e),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
