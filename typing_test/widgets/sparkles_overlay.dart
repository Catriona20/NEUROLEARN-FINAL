import 'dart:math';
import 'package:flutter/material.dart';

class SparklesOverlay extends StatefulWidget {
  final int count;
  final Color color;

  const SparklesOverlay({
    super.key,
    this.count = 30,
    this.color = const Color(0xFFFFD700),
  });

  @override
  State<SparklesOverlay> createState() => _SparklesOverlayState();
}

class _SparklesOverlayState extends State<SparklesOverlay> with TickerProviderStateMixin {
  late List<_SparkleData> sparkles;
  late List<AnimationController> controllers;

  @override
  void initState() {
    super.initState();
    final random = Random();
    sparkles = List.generate(widget.count, (index) {
      return _SparkleData(
        top: random.nextDouble(),
        left: random.nextDouble(),
        size: 2.0 + random.nextDouble() * 3.0,
        delay: random.nextInt(2000),
      );
    });

    controllers = List.generate(widget.count, (index) {
      return AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: List.generate(widget.count, (index) {
            final sparkle = sparkles[index];
            return Positioned(
              top: sparkle.top * constraints.maxHeight,
              left: sparkle.left * constraints.maxWidth,
              child: FadeTransition(
                opacity: controllers[index].drive(
                  CurveTween(curve: Curves.easeInOut),
                ),
                child: ScaleTransition(
                  scale: controllers[index].drive(
                    Tween(begin: 0.8, end: 1.2),
                  ),
                  child: Container(
                    width: sparkle.size,
                    height: sparkle.size,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SparkleData {
  final double top;
  final double left;
  final double size;
  final int delay;

  _SparkleData({
    required this.top,
    required this.left,
    required this.size,
    required this.delay,
  });
}
