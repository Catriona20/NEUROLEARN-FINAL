import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_router.dart';
import '../../../data/models/journey_day.dart';
import '../../widgets/common/glass_card.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  late List<JourneyDay> _journeyDays;
  String? _expandedStage;

  @override
  void initState() {
    super.initState();
    _journeyDays = JourneyDay.getDefaultJourney();
  }

  Map<String, List<JourneyDay>> get _groupedByStage {
    final Map<String, List<JourneyDay>> grouped = {};
    for (var day in _journeyDays) {
      if (!grouped.containsKey(day.stage)) {
        grouped[day.stage] = [];
      }
      grouped[day.stage]!.add(day);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroLearn Path'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header
              Text(
                'Progressive Learning Path',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Master each stage at your own pace',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Stage-based Journey
              ..._groupedByStage.entries.map((entry) {
                final stage = entry.key;
                final days = entry.value;
                final stageInfo = JourneyDay.getStageInfo(stage);
                final isExpanded = _expandedStage == stage;
                final isUnlocked = days.any((day) => day.isUnlocked);
                final completedCount = days.where((day) => day.isCompleted).length;

                return Column(
                  children: [
                    _StageHeader(
                      stage: stage,
                      icon: stageInfo['icon'],
                      color: Color(stageInfo['color']),
                      isExpanded: isExpanded,
                      isUnlocked: isUnlocked,
                      completedCount: completedCount,
                      totalCount: days.length,
                      onTap: () {
                        setState(() {
                          _expandedStage = isExpanded ? null : stage;
                        });
                      },
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: 16),
                      ...days.map((day) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 24),
                          child: _JourneyDayCard(
                            day: day,
                            stageColor: Color(stageInfo['color']),
                            onTap: day.isUnlocked
                                ? () {
                                    context.push(
                                      '${AppRouter.learningSession}?day=${day.dayNumber}',
                                    );
                                  }
                                : null,
                          ),
                        );
                      }).toList(),
                    ],
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageHeader extends StatelessWidget {
  final String stage;
  final String icon;
  final Color color;
  final bool isExpanded;
  final bool isUnlocked;
  final int completedCount;
  final int totalCount;
  final VoidCallback onTap;

  const _StageHeader({
    required this.stage,
    required this.icon,
    required this.color,
    required this.isExpanded,
    required this.isUnlocked,
    required this.completedCount,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Stage Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Stage Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stage: $stage',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stage,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            completedCount == totalCount
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 16,
                            color: completedCount == totalCount
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$completedCount/$totalCount completed',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Expand Icon
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyDayCard extends StatelessWidget {
  final JourneyDay day;
  final Color stageColor;
  final VoidCallback? onTap;

  const _JourneyDayCard({
    required this.day,
    required this.stageColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Day Number Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: day.isCompleted
                        ? const LinearGradient(
                            colors: [AppColors.success, Color(0xFF059669)],
                          )
                        : day.isUnlocked
                            ? LinearGradient(
                                colors: [stageColor, stageColor.withOpacity(0.7)],
                              )
                            : LinearGradient(
                                colors: [
                                  AppColors.glassWhite,
                                  AppColors.glassWhite,
                                ],
                              ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (day.isCompleted)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 28,
                        )
                      else if (!day.isUnlocked)
                        const Icon(
                          Icons.lock,
                          color: AppColors.textTertiary,
                          size: 20,
                        )
                      else
                        Text(
                          '${day.dayNumber}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Day Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.topic,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      if (day.isUnlocked && !day.isCompleted) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: day.progress,
                            backgroundColor: AppColors.glassWhite,
                            valueColor: AlwaysStoppedAnimation<Color>(stageColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow Icon
                if (day.isUnlocked)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
