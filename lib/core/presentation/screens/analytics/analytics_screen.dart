import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _chartAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Progress Analytics',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Stats overview
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('127', 'Tasks', Icons.task_alt, const Color(0xFF4ECDC4))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('87%', 'Accuracy', Icons.trending_up, const Color(0xFFFF6B9D))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('1,240', 'XP', Icons.stars, const Color(0xFFFFA07A))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('5', 'Streak', Icons.local_fire_department, Colors.orange)),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Reading improvement chart
                    const Text(
                      'Reading Improvement',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLineChart(),

                    const SizedBox(height: 32),

                    // Accuracy chart
                    const Text(
                      'Weekly Accuracy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBarChart(),

                    const SizedBox(height: 32),

                    // Circular progress rings
                    const Text(
                      'Skill Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCircularProgress('Reading', 0.85, const Color(0xFF4ECDC4)),
                        _buildCircularProgress('Writing', 0.72, const Color(0xFFFF6B9D)),
                        _buildCircularProgress('Speaking', 0.90, const Color(0xFFFFA07A)),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Achievement badges
                    const Text(
                      'Recent Achievements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAchievementBadges(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Container(
          height: 200,
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
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'Day ${value.toInt()}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(1, 60 * _chartAnimation.value),
                    FlSpot(2, 65 * _chartAnimation.value),
                    FlSpot(3, 70 * _chartAnimation.value),
                    FlSpot(4, 75 * _chartAnimation.value),
                    FlSpot(5, 82 * _chartAnimation.value),
                    FlSpot(6, 85 * _chartAnimation.value),
                    FlSpot(7, 87 * _chartAnimation.value),
                  ],
                  isCurved: true,
                  color: const Color(0xFF4ECDC4),
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Container(
          height: 200,
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
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      return Text(
                        days[value.toInt() % 7],
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 75 * _chartAnimation.value, color: const Color(0xFFFF6B9D), width: 16, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 80 * _chartAnimation.value, color: const Color(0xFFFF6B9D), width: 16, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 78 * _chartAnimation.value, color: const Color(0xFFFF6B9D), width: 16, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 85 * _chartAnimation.value, color: const Color(0xFFFF6B9D), width: 16, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 88 * _chartAnimation.value, color: const Color(0xFFFF6B9D), width: 16, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 90 * _chartAnimation.value, color: const Color(0xFFFF6B9D), width: 16, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 87 * _chartAnimation.value, color: const Color(0xFFFF6B9D), width: 16, borderRadius: BorderRadius.circular(4))]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircularProgress(String label, double progress, Color color) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress * _chartAnimation.value,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  Center(
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAchievementBadges() {
    final badges = [
      {'title': '5-Day Streak', 'icon': Icons.local_fire_department, 'color': Colors.orange},
      {'title': 'Fast Learner', 'icon': Icons.flash_on, 'color': const Color(0xFFFFA07A)},
      {'title': 'Perfect Score', 'icon': Icons.stars, 'color': Colors.amber},
      {'title': 'Early Bird', 'icon': Icons.wb_sunny, 'color': const Color(0xFF4ECDC4)},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: badges.map((badge) {
        return Container(
          width: (MediaQuery.of(context).size.width - 64) / 2,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (badge['color'] as Color).withOpacity(0.3),
                (badge['color'] as Color).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                badge['icon'] as IconData,
                color: badge['color'] as Color,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                badge['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
