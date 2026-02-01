import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/house_config.dart';
import 'widgets/sparkles_overlay.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_router.dart';

class TypingTestScreen extends StatefulWidget {
  final HouseConfig house;

  const TypingTestScreen({super.key, required this.house});

  @override
  State<TypingTestScreen> createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends State<TypingTestScreen> {
  static const List<String> basicWords = [
    'cat', 'dog', 'run', 'jump', 'play', 'book', 'pen', 'cup', 'hat', 'sun',
    'moon', 'star', 'tree', 'bird', 'fish', 'home', 'door', 'wall', 'roof', 'car',
    'bike', 'walk', 'talk', 'read', 'write', 'sing', 'dance', 'eat', 'sleep', 'wake',
    'day', 'night', 'rain', 'snow', 'wind', 'fire', 'water', 'earth', 'sky', 'sea',
    'hill', 'rock', 'sand', 'grass', 'leaf', 'flower', 'fruit', 'food', 'milk', 'bread'
  ];

  late String currentText;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  DateTime? startTime;
  Timer? timer;
  int elapsedSeconds = 0;
  int wpm = 0;
  int accuracy = 100;
  bool isTestActive = false;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    currentText = "Click \"Cast Your Spell\" to begin your ${widget.house.name} challenge!";
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _generateText() {
    final random = Random();
    final shuffled = List<String>.from(basicWords)..shuffle(random);
    setState(() {
      currentText = shuffled.take(20).join(' ');
    });
  }

  void _startTest() {
    _generateText();
    setState(() {
      isTestActive = true;
      showResult = false;
      elapsedSeconds = 0;
      wpm = 0;
      accuracy = 100;
      startTime = DateTime.now();
      _controller.clear();
    });
    _focusNode.requestFocus();
    timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      _updateStats();
    });
  }

  void _updateStats() {
    if (startTime == null) return;
    final now = DateTime.now();
    final diff = now.difference(startTime!);
    final seconds = diff.inSeconds;
    final typed = _controller.text;

    setState(() {
      elapsedSeconds = seconds;
      if (seconds > 0) {
        final wordsTyped = typed.trim().split(RegExp(r'\s+')).length;
        wpm = (wordsTyped / (seconds / 60)).round();
      }

      int correctChars = 0;
      for (int i = 0; i < typed.length && i < currentText.length; i++) {
        if (typed[i] == currentText[i]) {
          correctChars++;
        }
      }
      accuracy = typed.isEmpty ? 100 : ((correctChars / typed.length) * 100).round();
    });

    if (typed == currentText) {
      _endTest();
    }
  }

  void _endTest() {
    timer?.cancel();
    setState(() {
      isTestActive = false;
      showResult = true;
    });
    _showHouseModal();
  }

  void _showHouseModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.house.secondaryColor, const Color(0xFF1A0505)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.house.primaryColor, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 50),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.house.icon,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 20),
              Text(
                'You Belong to ${widget.house.name}!',
                textAlign: TextAlign.center,
                style: GoogleFonts.georgia(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6B6B),
                  shadows: [
                    const Shadow(color: Color(0x80FF6B6B), blurRadius: 20),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Your courage, bravery, and determination have proven you worthy of ${widget.house.name} house.\n\nLike the greatest witches and wizards, you embody the spirit of a true ${widget.house.name}!',
                textAlign: TextAlign.center,
                style: GoogleFonts.georgia(
                  fontSize: 18,
                  color: const Color(0xFFD4A574),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => context.go(AppRouter.dashboard),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: widget.house.accentColor),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.house.primaryColor, widget.house.accentColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    width: 120,
                    height: 50,
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [widget.house.secondaryColor, const Color(0xFF1A0505)],
          ),
        ),
        child: Stack(
          children: [
            const SparklesOverlay(count: 30),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: showResult ? _buildResultScreen() : _buildGameScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 900),
      decoration: BoxDecoration(
        color: widget.house.primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.house.primaryColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: widget.house.primaryColor.withOpacity(0.5),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${widget.house.icon} ${widget.house.name} Typing Test ${widget.house.icon}',
            textAlign: TextAlign.center,
            style: GoogleFonts.georgia(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF6B6B),
              shadows: [
                const Shadow(color: Color(0x80FF6B6B), blurRadius: 20),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.house.quote,
            textAlign: TextAlign.center,
            style: GoogleFonts.georgia(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: const Color(0xFFD4A574),
            ),
          ),
          const SizedBox(height: 25),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 10,
              color: Colors.white.withOpacity(0.1),
              child: FractionallySizedBox(
                widthFactor: isTestActive ? (_controller.text.length / currentText.length).clamp(0.0, 1.0) : 0,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.house.primaryColor, widget.house.accentColor],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('⏱️ Time', '${elapsedSeconds}s'),
              _buildStatCard('⚡ Speed', '$wpm WPM'),
              _buildStatCard('🎯 Accuracy', '$accuracy%'),
            ],
          ),
          const SizedBox(height: 25),
          // Text Display
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.house.primaryColor, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2), inset: true),
              ],
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.georgia(
                  fontSize: 24,
                  height: 1.8,
                  color: const Color(0xFF2C1810),
                  fontWeight: FontWeight.w500,
                ),
                children: _buildTextSpans(),
              ),
            ),
          ),
          const SizedBox(height: 25),
          // Input Area
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: isTestActive,
            autocorrect: false,
            enableSuggestions: false,
            style: GoogleFonts.georgia(fontSize: 20, color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.house.placeholder,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.house.primaryColor, width: 3),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.house.accentColor, width: 3),
              ),
            ),
            onChanged: (val) {
              _updateStats();
            },
          ),
          const SizedBox(height: 25),
          // Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isTestActive ? null : _startTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.house.primaryColor, widget.house.accentColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    isTestActive ? '🔮 Casting Spell...' : '🪄 Cast Your Spell',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Column(
      children: [
        const Text('⚡', style: TextStyle(fontSize: 100)),
        Text(
          'Spell Casted Successfully!',
          textAlign: TextAlign.center,
          style: GoogleFonts.georgia(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF6B6B),
            shadows: [const Shadow(color: Color(0x80FF6B6B), blurRadius: 20)],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Your bravery and determination shine through!',
          style: GoogleFonts.georgia(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFD4A574),
          ),
        ),
        const SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('⏱️ Time Taken', '${elapsedSeconds}s'),
            _buildStatCard('⚡ Typing Speed', '$wpm WPM'),
            _buildStatCard('🎯 Accuracy', '$accuracy%'),
          ],
        ),
        const SizedBox(height: 35),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(AppRouter.dashboard),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.house.primaryColor, widget.house.accentColor],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  '✨ CONTINUE TO DASHBOARD',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.house.accentColor, width: 2),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: widget.house.accentColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    final typed = _controller.text;
    List<TextSpan> spans = [];

    for (int i = 0; i < currentText.length; i++) {
      final char = currentText[i];
      if (i < typed.length) {
        if (typed[i] == char) {
          spans.add(TextSpan(text: char, style: const TextStyle(color: Color(0xFF2D5016), fontWeight: FontWeight.bold)));
        } else {
          spans.add(TextSpan(
            text: char,
            style: const TextStyle(
              color: Colors.red,
              backgroundColor: Color(0x33FF0000),
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
          ));
        }
      } else if (i == typed.length && isTestActive) {
        spans.add(TextSpan(
          text: char,
          style: TextStyle(
            backgroundColor: widget.house.accentColor,
            color: const Color(0xFF2C1810),
            fontWeight: FontWeight.bold,
          ),
        ));
      } else {
        spans.add(TextSpan(text: char));
      }
    }
    return spans;
  }
}
