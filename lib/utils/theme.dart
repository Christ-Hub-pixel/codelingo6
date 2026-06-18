import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// ═══════════════════════════════════════════
//  PALETTE DE COULEURS CODELINGO
// ═══════════════════════════════════════════
class AppColors {
  // Couleurs primaires
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEF2FF);

  // Couleurs sémantiques
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);

  // Nœuds de leçons
  static const Color nodeStarter = Color(0xFF22C55E);
  static const Color nodeIntermediate = Color(0xFF3B82F6);
  static const Color nodeAdvanced = Color(0xFF8B5CF6);
  static const Color nodeSpecial = Color(0xFFF59E0B);

  // Fonds
  static const Color background = Color(0xFFF4F5FE);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E2E);
  static const Color backgroundDark = Color(0xFF0F1117);
  static const Color cardDark = Color(0xFF1A1A2E);

  // Texte
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDark = Color(0xFFF9FAFB);
  static const Color textDarkSecondary = Color(0xFF9CA3AF);
}

// ═══════════════════════════════════════════
//  STYLES DE TEXTE
// ═══════════════════════════════════════════
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.2,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.5,
  );
  static const TextStyle label = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.2,
  );
  static const TextStyle statValue = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary,
  );
}

// ═══════════════════════════════════════════
//  DÉCORATIONS RÉUTILISABLES
// ═══════════════════════════════════════════
class AppDecorations {
  static BoxDecoration card({Color? color, bool dark = false}) => BoxDecoration(
    color: color ?? (dark ? AppColors.cardDark : AppColors.surface),
    borderRadius: BorderRadius.circular(24),
    boxShadow: dark ? [] : [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );

  static BoxDecoration cardBordered({Color borderColor = AppColors.primary, bool dark = false}) => BoxDecoration(
    color: dark ? AppColors.cardDark : AppColors.surface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: borderColor.withValues(alpha: 0.3), width: 1.5),
    boxShadow: dark ? [] : [
      BoxShadow(color: borderColor.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );

  static BoxDecoration gradient({List<Color>? colors}) => BoxDecoration(
    gradient: LinearGradient(
      colors: colors ?? [AppColors.primary, AppColors.primaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8)),
    ],
  );

  static BoxDecoration navBar(bool dark) => BoxDecoration(
    color: dark ? const Color(0xFF1F2937) : AppColors.surface,
    border: Border(top: BorderSide(color: dark ? Colors.white10 : Colors.grey.shade100, width: 1)),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -4)),
    ],
  );
}

// ═══════════════════════════════════════════
//  THÈME FLUTTER
// ═══════════════════════════════════════════
class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showUnselectedLabels: false,
      showSelectedLabels: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F2937),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w800),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1F2937),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: false,
      showSelectedLabels: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
