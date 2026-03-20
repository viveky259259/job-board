import 'package:flutter/material.dart';
import 'package:sub_zero_design_system/sub_zero_design_system.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = SubZeroTheme.lightTheme;
    return base.copyWith(
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        errorBorder: OutlineInputBorder(
          borderRadius: SubZeroRadius.medium,
          borderSide: BorderSide(color: SubZeroColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: SubZeroRadius.medium,
          borderSide: BorderSide(color: SubZeroColors.error, width: 2),
        ),
        errorStyle: TextStyle(color: SubZeroColors.error),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SubZeroColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: SubZeroRadius.medium,
          ),
        ),
      ),
    );
  }
  static ThemeData get darkTheme => _buildDarkTheme();

  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SubZeroColors.primary,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SubZeroRadius.md),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SubZeroRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SubZeroRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SubZeroRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SubZeroRadius.md),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SubZeroRadius.md),
          borderSide: BorderSide(color: SubZeroColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: SubZeroSpacing.md,
          vertical: SubZeroSpacing.md,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SubZeroRadius.md),
        ),
      ),
    );
  }

  static Color matchScoreColor(int score) {
    if (score >= 80) return SubZeroColors.success;
    if (score >= 60) return SubZeroColors.warning;
    if (score >= 40) return Colors.orange;
    return SubZeroColors.error;
  }
}
