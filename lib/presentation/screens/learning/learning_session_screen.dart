import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/journey_day.dart';
import '../../widgets/tasks/typing_task_widget.dart';
import '../../widgets/tasks/handwriting_task_widget.dart';
import '../../widgets/tasks/speech_task_widget.dart';
import '../../widgets/common/glass_card.dart';

class LearningSessionScreen extends StatefulWidget {
  final int dayNumber;

  const LearningSessionScreen({
    super.key,
    required this.dayNumber,
  });

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen> {
  late ConfettiController _confettiController;
  late JourneyDay _currentDay;
  late List<String> _sentences;
  int _currentTaskIndex = 0;
  int _currentSentenceIndex = 0;
  String _currentTaskType = AppConstants.taskTypeTyping;
  final List<String> _taskTypes = [
    AppConstants.taskTypeTyping,
    AppConstants.taskTypeHandwriting,
    AppConstants.taskTypeSpeech,
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadDayData();
  }

  void _loadDayData() {
    final allDays = JourneyDay.getDefaultJourney();
    _currentDay = allDays.firstWhere(
      (day) => day.dayNumber == widget.dayNumber,
      orElse: () => allDays.first,
    );
    _sentences = _currentDay.sentences;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleTaskComplete(int score) {
    // Show confetti for good scores
    if (score >= AppConstants.goodScore) {
      _confettiController.play();
    }

    // Move to next task or sentence
    setState(() {
      _currentTaskIndex++;
      if (_currentTaskIndex >= _taskTypes.length) {
        _currentTaskIndex = 0;
        _currentSentenceIndex++;
        
        if (_currentSentenceIndex >= _sentences.length) {
          // Session complete
          _showCompletionDialog();
          return;
        }
      }
      _currentTaskType = _taskTypes[_currentTaskIndex];
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('🎉 Great Job!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve completed Day ${widget.dayNumber}!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Keep up the amazing work!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to previous screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSentence = _sentences[_currentSentenceIndex];
    final progress = (_currentSentenceIndex * _taskTypes.length + _currentTaskIndex) /
        (_sentences.length * _taskTypes.length);

    return Scaffold(
      appBar: AppBar(
        title: Text('Day ${widget.dayNumber}: ${_currentDay.topic}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.glassWhite,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.purplePrimary,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Info
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Task ${_currentSentenceIndex + 1}/${_sentences.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  _getTaskIcon(_currentTaskType),
                                  color: AppColors.purpleLight,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentSentence,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Task Widget
                    Expanded(
                      child: _buildTaskWidget(currentSentence),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppColors.purplePrimary,
                AppColors.purpleLight,
                AppColors.lavenderMedium,
                AppColors.gold,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskWidget(String sentence) {
    switch (_currentTaskType) {
      case AppConstants.taskTypeTyping:
        return TypingTaskWidget(
          sentence: sentence,
          onComplete: _handleTaskComplete,
        );
      case AppConstants.taskTypeHandwriting:
        return HandwritingTaskWidget(
          sentence: sentence,
          onComplete: _handleTaskComplete,
        );
      case AppConstants.taskTypeSpeech:
        return SpeechTaskWidget(
          sentence: sentence,
          onComplete: _handleTaskComplete,
        );
      default:
        return const SizedBox();
    }
  }

  IconData _getTaskIcon(String taskType) {
    switch (taskType) {
      case AppConstants.taskTypeTyping:
        return Icons.keyboard;
      case AppConstants.taskTypeHandwriting:
        return Icons.draw;
      case AppConstants.taskTypeSpeech:
        return Icons.mic;
      default:
        return Icons.task;
    }
  }
}
