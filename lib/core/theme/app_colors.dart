import 'package:flutter/material.dart';

/// Design tokens aligned with the Rumour Figma / mockups.
abstract final class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  /// Join screen key accent (mock ~#C6FF00).
  static const Color joinLime = Color(0xFFC6FF00);

  /// Chat / identity accent (mock ~#B8E65C / #B9E85F).
  static const Color lime = Color(0xFFB8E65C);

  static const Color inputSurface = Color(0xFF1C1C1E);
  static const Color iconCircle = Color(0xFF2C2C2E);
  static const Color cardNavy = Color(0xFF12151C);
  static const Color incomingBubble = Color(0xFF1A1F26);

  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color secondaryTextAlt = Color(0xFF9BA1A6);

  static const Color datePillBg = Color(0xFF2C2C2E);
  static const Color timestampIncoming = Color(0xFF8E8E93);
  static const Color timestampOutgoing = Color(0xFF3D3D3D);

  static const Color outgoingText = Color(0xFF0D0D0D);
  static const Color sendIcon = Color(0xFF3D3D3D);

  // Light theme counterparts
  static const Color lightScaffold = Color(0xFFF2F2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightIncoming = Color(0xFFE8E8ED);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF6C6C70);
}
