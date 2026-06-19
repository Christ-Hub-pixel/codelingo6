import 'package:flutter/services.dart';

class HapticService {
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }

  static Future<void> click() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }
}
