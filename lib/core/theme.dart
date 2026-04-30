import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TAYYIB DESIGN SYSTEM
// Apple design language · Space Grotesk · iOS/Android parity
// ─────────────────────────────────────────────────────────────────────────────

abstract class TayyibColors {
  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color primary   = Color(0xFF007AFF);
  static const Color green     = Color(0xFF34C759);
  static const Color red       = Color(0xFFFF3B30);
  static const Color orange    = Color(0xFFFF9500);
  static const Color purple    = Color(0xFF5856D6);

  // ── Light mode ────────────────────────────────────────────────────────────
  static const Color background       = Color(0xFFF2F2F7);
  static const Color card             = Color(0xFFFFFFFF);
  static const Color label            = Color(0xFF000000);
  static const Color secondaryLabel   = Color(0xFF8E8E93);
  static const Color tertiaryLabel    = Color(0xFFAEAEB2);
  static const Color separator        = Color(0xFFE5E5EA);
  static const Color groupedFill      = Color(0xFFEFEFF4);

  // ── Dark mode ─────────────────────────────────────────────────────────────
  static const Color backgroundDark     = Color(0xFF000000);
  static const Color cardDark           = Color(0xFF1C1C1E);
  static const Color labelDark          = Color(0xFFFFFFFF);
  static const Color secondaryLabelDark = Color(0xFF8E8E93);
  static const Color separatorDark      = Color(0xFF38383A);
  static const Color groupedFillDark    = Color(0xFF2C2C2E);

  // ── Status tints ─────────────────────────────────────────────────────────
  static const Color greenTint  = Color(0xFFE8F8ED);
  static const Color redTint    = Color(0xFFFFEBEA);
  static const Color orangeTint = Color(0xFFFFF3E0);
  static const Color blueTint   = Color(0xFFE5F1FF);

  // ── Adaptive helpers ─────────────────────────────────────────────────────
  static Color adaptive(BuildContext context, Color light, Color dark) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  static Color bg(BuildContext context) =>
      adaptive(context, background, backgroundDark);
  static Color cardBg(BuildContext context) =>
      adaptive(context, card, cardDark);
  static Color lbl(BuildContext context) =>
      adaptive(context, label, labelDark);
  static Color secondLbl(BuildContext context) =>
      adaptive(context, secondaryLabel, secondaryLabelDark);
  static Color sep(BuildContext context) =>
      adaptive(context, separator, separatorDark);
  static Color fill(BuildContext context) =>
      adaptive(context, groupedFill, groupedFillDark);
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPOGRAPHY — Space Grotesk everywhere
// ─────────────────────────────────────────────────────────────────────────────

abstract class TayyibText {
  // ── Display ───────────────────────────────────────────────────────────────
  static TextStyle largeTitle({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 34, fontWeight: FontWeight.w700,
    letterSpacing: -0.5, height: 1.1, color: color,
  );

  static TextStyle title1({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 28, fontWeight: FontWeight.w700,
    letterSpacing: -0.4, height: 1.15, color: color,
  );

  static TextStyle title2({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 22, fontWeight: FontWeight.w600,
    letterSpacing: -0.3, height: 1.2, color: color,
  );

  static TextStyle title3({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 20, fontWeight: FontWeight.w600,
    letterSpacing: -0.2, color: color,
  );

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle headline({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 17, fontWeight: FontWeight.w600,
    letterSpacing: -0.1, color: color,
  );

  static TextStyle body({Color? color, FontWeight? weight}) => GoogleFonts.spaceGrotesk(
    fontSize: 16, fontWeight: weight ?? FontWeight.w400,
    height: 1.45, color: color,
  );

  static TextStyle callout({Color? color, FontWeight? weight}) => GoogleFonts.spaceGrotesk(
    fontSize: 15, fontWeight: weight ?? FontWeight.w400,
    height: 1.4, color: color,
  );

  static TextStyle subheadline({Color? color, FontWeight? weight}) => GoogleFonts.spaceGrotesk(
    fontSize: 15, fontWeight: weight ?? FontWeight.w500,
    color: color,
  );

  static TextStyle footnote({Color? color, FontWeight? weight}) => GoogleFonts.spaceGrotesk(
    fontSize: 13, fontWeight: weight ?? FontWeight.w400,
    height: 1.4, color: color,
  );

  static TextStyle caption1({Color? color, FontWeight? weight}) => GoogleFonts.spaceGrotesk(
    fontSize: 12, fontWeight: weight ?? FontWeight.w500,
    letterSpacing: 0.2, color: color,
  );

  static TextStyle caption2({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 11, fontWeight: FontWeight.w500,
    letterSpacing: 0.5, color: color,
  );

  // ── Section header (ALL CAPS micro label) ─────────────────────────────────
  static TextStyle sectionHeader({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 12, fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: color ?? TayyibColors.secondaryLabel,
  );

  // ── Button ────────────────────────────────────────────────────────────────
  static TextStyle buttonLarge({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 17, fontWeight: FontWeight.w600,
    letterSpacing: -0.1, color: color ?? Colors.white,
  );

  static TextStyle buttonMedium({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: color ?? Colors.white,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHADOWS
// ─────────────────────────────────────────────────────────────────────────────

abstract class TayyibShadow {
  static List<BoxShadow> small({Color? color}) => [
    BoxShadow(
      color: (color ?? Colors.black).withOpacity(0.06),
      blurRadius: 8, offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> medium({Color? color}) => [
    BoxShadow(
      color: (color ?? Colors.black).withOpacity(0.08),
      blurRadius: 16, offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: (color ?? Colors.black).withOpacity(0.04),
      blurRadius: 4, offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> large({Color? color}) => [
    BoxShadow(
      color: (color ?? Colors.black).withOpacity(0.10),
      blurRadius: 30, offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: (color ?? Colors.black).withOpacity(0.05),
      blurRadius: 8, offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.32),
      blurRadius: 20, offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> bottomBar(BuildContext context) => [
    BoxShadow(
      color: TayyibColors.adaptive(context, Colors.black, Colors.black)
          .withOpacity(0.08),
      blurRadius: 20, offset: const Offset(0, -4),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME DATA
// ─────────────────────────────────────────────────────────────────────────────

abstract class TayyibTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark()  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg    = isDark ? TayyibColors.backgroundDark : TayyibColors.background;
    final card  = isDark ? TayyibColors.cardDark       : TayyibColors.card;
    final label = isDark ? TayyibColors.labelDark      : TayyibColors.label;
    final sep   = isDark ? TayyibColors.separatorDark  : TayyibColors.separator;

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

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: label,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TayyibText.headline(color: label),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: EdgeInsets.zero,
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TayyibColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: TayyibText.body(color: TayyibColors.tertiaryLabel),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(color: sep, thickness: 0.5),

      // ── Filled button ─────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TayyibColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 52),
          textStyle: TayyibText.buttonLarge(),
          elevation: 0,
        ),
      ),

      // ── Cupertino override ────────────────────────────────────────────────
      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        brightness: brightness,
        primaryColor: TayyibColors.primary,
        textTheme: CupertinoTextThemeData(
          primaryColor: TayyibColors.primary,
          textStyle: TayyibText.body(color: label),
          navLargeTitleTextStyle: TayyibText.largeTitle(color: label),
          navTitleTextStyle: TayyibText.headline(color: label),
        ),
      ),
    );
  }
}