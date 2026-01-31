import 'package:flutter/material.dart';

class AppColors {
  // Primary Purple Gradient
  static const purplePrimary = Color(0xFF8B5CF6);
  static const purpleSecondary = Color(0xFF6366F1);
  static const purpleLight = Color(0xFFA78BFA);
  static const purpleDark = Color(0xFF7C3AED);
  
  // Lavender Accents
  static const lavenderLight = Color(0xFFE9D5FF);
  static const lavenderMedium = Color(0xFFD8B4FE);
  static const lavenderDark = Color(0xFFC084FC);
  
  // Gradient Colors
  static const gradientStart = Color(0xFF8B5CF6);
  static const gradientMiddle = Color(0xFF7C3AED);
  static const gradientEnd = Color(0xFF6366F1);
  
  // Background
  static const backgroundDark = Color(0xFF0F0A1F);
  static const backgroundMedium = Color(0xFF1A1333);
  static const backgroundLight = Color(0xFF2D1B4E);
  
  // Glass Effect
  static const glassWhite = Color(0x1AFFFFFF);
  static const glassPurple = Color(0x1A8B5CF6);
  
  // Success & Error
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
  
  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFD1D5DB);
  static const textTertiary = Color(0xFF9CA3AF);
  
  // Gamification
  static const gold = Color(0xFFFBBF24);
  static const silver = Color(0xFFD1D5DB);
  static const bronze = Color(0xFFEA580C);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMiddle, gradientEnd],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassPurple, glassWhite],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundMedium, backgroundLight],
  );
}
