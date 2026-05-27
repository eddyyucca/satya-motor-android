import 'package:flutter/material.dart';

class AppColors {
  // Primary Orange Palette
  static const Color primary = Color(0xFFFF6D00);
  static const Color primaryDark = Color(0xFFE65100);
  static const Color primaryLight = Color(0xFFFFB74D);
  static const Color accent = Color(0xFFFF9100);

  // Background Colors
  static const Color background = Color(0xFFFFF8F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1AFF6D00);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
}

class AppConstants {
  static const String appName = 'Satya Motor';
  static const String appTagline = 'Bengkel Terpercaya';

  // Default Percentage Split
  static const double defaultItemMechanicPercent = 30.0;
  static const double defaultItemOwnerPercent = 70.0;
  static const double defaultServiceMechanicPercent = 50.0;
  static const double defaultServiceOwnerPercent = 50.0;

  // Stock Warning Threshold
  static const int lowStockThreshold = 5;
}
