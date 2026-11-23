import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class KaryawanColors {
  static const background = Color(0xFFF7EDC9);
  static const backgroundTop = Color(0xFFFFF8E7);
  static const surface = Color(0xFFFFFFFF);
  static const transparent = Color(0x00000000);
  static const border = Color(0xFFF3E3AD);
  static const primary = Color(0xFFFB923C);
  static const primaryDark = Color(0xFFF97316);
  static const amber = Color(0xFFEFB22D);
  static const heading = Color(0xFF2A1600);
  static const body = Color(0xFF343946);
  static const bodyAlt = Color(0xFF444A59);
  static const secondary = Color(0xFF979DA8);
  static const secondaryAlt = Color(0xFF9CA1AB);
  static const brown = Color(0xFF584730);
  static const brownDark = Color(0xFF603908);
  static const success = Color(0xFF449964);
  static const successBackground = Color(0xFFDBFCE7);
  static const successAccent = Color(0xFF59AA77);
  static const warningBackground = Color(0xFFF7EDC9);
  static const danger = Color(0xFFAD6464);
  static const dangerBackground = Color(0xFFFEE2E2);
  static const dangerBackgroundAlt = Color(0xFFFEDFD5);
  static const dangerAccent = Color(0xFFCA7B7B);
  static const orangeTint = Color(0xFFFFF0DC);
  static const mutedBrown = Color(0xFF8A7659);
}

abstract final class KaryawanRadii {
  static const card = 20.0;
  static const hero = 24.0;
  static const button = 16.0;
  static const icon = 14.0;
  static const pill = 999.0;
}

abstract final class KaryawanSpacing {
  static const screen = 20.0;
  static const item = 16.0;
  static const section = 24.0;
}

abstract final class KaryawanTextStyles {
  static TextStyle _text({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    ).copyWith(fontFamilyFallback: const ['Poppins']);
  }

  static TextStyle get greeting =>
      _text(fontSize: 13, fontWeight: FontWeight.w600);

  static TextStyle get headline => _text(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: KaryawanColors.heading,
  );

  static TextStyle get sectionTitle => _text(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: KaryawanColors.heading,
  );

  static TextStyle get body => _text(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: KaryawanColors.body,
  );

  static TextStyle get label => _text(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: KaryawanColors.secondary,
  );

  static TextStyle get metric => _text(
    fontSize: 25,
    fontWeight: FontWeight.w800,
    color: KaryawanColors.heading,
  );

  static TextStyle get button =>
      _text(fontSize: 14, fontWeight: FontWeight.w700);
}

abstract final class KaryawanTheme {
  static ThemeData get data {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: KaryawanColors.primaryDark,
        brightness: Brightness.light,
        surface: KaryawanColors.surface,
        error: KaryawanColors.danger,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: KaryawanColors.background,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: KaryawanColors.body,
        displayColor: KaryawanColors.heading,
        fontFamilyFallback: const ['Poppins'],
      ),
      splashColor: KaryawanColors.amber.withValues(alpha: 0.10),
      highlightColor: KaryawanColors.amber.withValues(alpha: 0.06),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: KaryawanColors.heading,
        contentTextStyle: KaryawanTextStyles.body.copyWith(
          color: KaryawanColors.surface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KaryawanRadii.button),
        ),
      ),
    );
  }
}
