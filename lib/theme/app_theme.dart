import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ── Brand palette (warm-neutral athletic) ────────────────────────────────
  static const Color primary    = Color(0xFF1A1917); // warm near-black
  static const Color accent     = Color(0xFFBF5534); // warm brick/terracotta
  static const Color surface    = Color(0xFFFAFAF8); // warm paper-white
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color outline    = Color(0xFFE8E4DE); // barely-there warm divider
  static const Color outlineMed = Color(0xFFD0CAC3); // slightly visible

  static const Color textPrimary   = Color(0xFF1A1917);
  static const Color textSecondary = Color(0xFF6B6862);
  static const Color textTertiary  = Color(0xFFABA69F);

  // ── Schematic canvas ──────────────────────────────────────────────────────
  static const Color canvasBg     = Color(0xFFF2EFE8); // warm parchment
  static const Color sectionBorder= Color(0xFFD0CAC3);
  static const Color rackerColor  = Color(0xFF8C8882);
  static const Color shelfColor   = Color(0xFFC4A878); // warm timber

  // ── Shadow ────────────────────────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 1,
      offset: Offset(0, 0),
    ),
  ];

  // ── Shape ─────────────────────────────────────────────────────────────────
  static const _squareRadius = BorderRadius.zero;
  static final _squareShape  = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(2),
  );

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: surface,
          primary: primary,
          onPrimary: Colors.white,
          secondary: accent,
          onSecondary: Colors.white,
        ),
        scaffoldBackgroundColor: surface,

        // ── AppBar ──────────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: cardBg,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            color: textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
          ),
          toolbarHeight: 56,
          shape: const Border(
            bottom: BorderSide(color: outline, width: 1),
          ),
        ),

        // ── Card ────────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: _squareShape,
          margin: EdgeInsets.zero,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),

        // ── Buttons ─────────────────────────────────────────────────────────
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: primary, width: 1),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: textSecondary,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
            shape: _squareShape,
          ),
        ),

        // ── FAB ─────────────────────────────────────────────────────────────
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          extendedTextStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1.4,
          ),
        ),

        // ── Input ───────────────────────────────────────────────────────────
        inputDecorationTheme: const InputDecorationTheme(
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: outline),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: outlineMed),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          labelStyle: TextStyle(
            color: textSecondary,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          floatingLabelStyle: TextStyle(
            color: primary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          hintStyle: TextStyle(
            color: textTertiary,
            fontSize: 13,
          ),
        ),

        // ── Chip ────────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: surface,
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          side: const BorderSide(color: outlineMed),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          selectedColor: primary,
          secondarySelectedColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),

        // ── Dialog ──────────────────────────────────────────────────────────
        dialogTheme: const DialogThemeData(
          backgroundColor: cardBg,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
          contentTextStyle: TextStyle(
            color: textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          elevation: 8,
        ),

        // ── Divider ─────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: outline,
          space: 1,
          thickness: 1,
        ),

        // ── ListTile ────────────────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          subtitleTextStyle: TextStyle(
            color: textSecondary,
            fontSize: 11,
          ),
        ),

        // ── BottomSheet ─────────────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          ),
        ),

        // ── PopupMenu ───────────────────────────────────────────────────────
        popupMenuTheme: const PopupMenuThemeData(
          color: cardBg,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          textStyle: TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),

        // ── Switch ──────────────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? cardBg : outlineMed),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? primary : outline),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      );
}

// ── Type scale helpers ────────────────────────────────────────────────────────

extension TextStyleExt on BuildContext {
  /// Large editorial headline — product names, screen titles.
  TextStyle get headlineLarge => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppTheme.textPrimary,
        letterSpacing: -0.5,
        height: 1.1,
      );

  /// Medium title — card headers.
  TextStyle get titleMedium => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
        letterSpacing: 0.1,
      );

  /// Standard body text.
  TextStyle get bodyMedium => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppTheme.textSecondary,
        height: 1.45,
      );

  /// ALL CAPS micro label — section categories, field labels.
  TextStyle get labelSmall => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppTheme.textTertiary,
      );

  /// Accent label — featured callouts, zone labels.
  TextStyle get labelAccent => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: AppTheme.accent,
      );
}

// ── Reusable UI primitives ────────────────────────────────────────────────────

/// A premium card surface with soft shadow instead of a hard border.
class LuluCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  const LuluCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppTheme.cardBg,
      borderRadius: BorderRadius.circular(2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(2)),
            boxShadow: AppTheme.cardShadow,
            color: AppTheme.cardBg,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// ALL CAPS section divider label used throughout the app.
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: context.labelSmall,
      ),
    );
  }
}
