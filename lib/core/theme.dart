import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class TayyibColors {
  // Semantic
  static const Color primary = Color(0xFF1A1A1A);
  static const Color green = Color(0xFF2DB87A);
  static const Color red = Color(0xFFE84545);
  static const Color orange = Color(0xFFF5A623);
  static const Color blue = Color(0xFF3D7EFF);

  // Light
  static const Color background = Color(0xFFF5F5F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color label = Color(0xFF0D0D0D);
  static const Color secondaryLabel = Color(0xFF8A8A8A);
  static const Color tertiaryLabel = Color(0xFFBBBBBB);
  static const Color separator = Color(0xFFEAEAEA);
  static const Color fill = Color(0xFFEEEEEE);

  // Dark
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1C1C1C);
  static const Color labelDark = Color(0xFFF0F0F0);
  static const Color secondaryLabelDark = Color(0xFF8A8A8A);
  static const Color separatorDark = Color(0xFF2A2A2A);
  static const Color fillDark = Color(0xFF2A2A2A);

  // Status tints
  static const Color greenTint = Color(0xFFE6F7F0);
  static const Color redTint = Color(0xFFFDEEEE);
  static const Color orangeTint = Color(0xFFFEF6E6);

  static Color adaptive(BuildContext ctx, Color light, Color dark) =>
      Theme.of(ctx).brightness == Brightness.dark ? dark : light;

  static Color bg(BuildContext ctx) =>
      adaptive(ctx, background, backgroundDark);
  static Color cardBg(BuildContext ctx) => adaptive(ctx, card, cardDark);
  static Color lbl(BuildContext ctx) => adaptive(ctx, label, labelDark);
  static Color secondLbl(BuildContext ctx) =>
      adaptive(ctx, secondaryLabel, secondaryLabelDark);
  static Color sep(BuildContext ctx) => adaptive(ctx, separator, separatorDark);
  static Color fillC(BuildContext ctx) => adaptive(ctx, fill, fillDark);
}

abstract class TayyibText {
  static TextStyle largeTitle({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.1,
        color: color,
      );

  static TextStyle title1({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: color,
      );

  static TextStyle title2({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle headline({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle body({Color? color, FontWeight? weight}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: weight ?? FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle callout({Color? color, FontWeight? weight}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: weight ?? FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle footnote({Color? color, FontWeight? weight}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: weight ?? FontWeight.w400,
        height: 1.4,
        color: color,
      );

  static TextStyle caption1({Color? color, FontWeight? weight}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: weight ?? FontWeight.w600,
        letterSpacing: 0.4,
        color: color,
      );

  static TextStyle sectionHeader({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: color ?? TayyibColors.secondaryLabel,
      );

  static TextStyle buttonLarge({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: color ?? Colors.white,
      );
}

abstract class TayyibTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? TayyibColors.backgroundDark : TayyibColors.background;
    final card = isDark ? TayyibColors.cardDark : TayyibColors.card;
    final label = isDark ? TayyibColors.labelDark : TayyibColors.label;
    final sep = isDark ? TayyibColors.separatorDark : TayyibColors.separator;

    final base = GoogleFonts.spaceGroteskTextTheme().apply(
      bodyColor: label,
      displayColor: label,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TayyibColors.primary,
        primary: TayyibColors.primary,
        secondary: TayyibColors.green,
        error: TayyibColors.red,
        surface: card,
        brightness: brightness,
      ),
      textTheme: base,
      primaryTextTheme: base,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: label,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: label,
          letterSpacing: -0.3,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
                .copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark
                .copyWith(statusBarColor: Colors.transparent),
      ),
      // FIXED: Changed CardTheme to CardThemeData
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: TayyibColors.primary.withOpacity(0.4), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          color: TayyibColors.tertiaryLabel,
        ),
      ),
      dividerTheme: DividerThemeData(color: sep, thickness: 0.5),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: label,
          foregroundColor: isDark ? TayyibColors.backgroundDark : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
        ),
      ),
    );
  }
}
