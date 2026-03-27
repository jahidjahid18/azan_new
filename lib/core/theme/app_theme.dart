import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeColors {
  static const Color deepGreen = Color(0xFF0A5C45);
  static const Color emerald = Color(0xFF118C68);
  static const Color gold = Color(0xFFD4A62A);
  static const Color midnight = Color(0xFF121212);
  static const Color ocean = Color(0xFF0F6CAB);
  static const Color sunsetOrange = Color(0xFFE07A3F);
  static const Color sunsetPink = Color(0xFFE56AA6);
}

class AppGradients {
  static LinearGradient primaryFor(ThemeStyleOption style) {
    return switch (style) {
      ThemeStyleOption.emerald => const LinearGradient(
        colors: <Color>[
          Color(0xFF0A5C45),
          Color(0xFF0F8A67),
          Color(0xFF1CB887),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.midnightDark => const LinearGradient(
        colors: <Color>[
          Color(0xFF141414),
          Color(0xFF1D1D1D),
          Color(0xFF292929),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.ocean => const LinearGradient(
        colors: <Color>[
          Color(0xFF0B4E8F),
          Color(0xFF1A77BB),
          Color(0xFF35A2E0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.sunset => const LinearGradient(
        colors: <Color>[
          Color(0xFFB9552D),
          Color(0xFFE57D58),
          Color(0xFFF39BC0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.glass => const LinearGradient(
        colors: <Color>[
          Color(0xAA4AA5DE),
          Color(0xAA6CCAEF),
          Color(0xAAA4E3F7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.softUi => const LinearGradient(
        colors: <Color>[
          Color(0xFFC4D2DE),
          Color(0xFFD9E3EC),
          Color(0xFFEAF0F5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    };
  }

  static LinearGradient alternativeFor(ThemeStyleOption style) {
    return switch (style) {
      ThemeStyleOption.emerald => const LinearGradient(
        colors: <Color>[
          Color(0xFF06261D),
          Color(0xFF0A3B2E),
          Color(0xFF0F5C48),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.midnightDark => const LinearGradient(
        colors: <Color>[
          Color(0xFF0F0F0F),
          Color(0xFF161616),
          Color(0xFF202020),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.ocean => const LinearGradient(
        colors: <Color>[
          Color(0xFF082E53),
          Color(0xFF0F487C),
          Color(0xFF1567A8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.sunset => const LinearGradient(
        colors: <Color>[
          Color(0xFF4B1F16),
          Color(0xFF74301E),
          Color(0xFF9B4B30),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.glass => const LinearGradient(
        colors: <Color>[
          Color(0xCC204A70),
          Color(0xCC2E6D8E),
          Color(0xCC4D89A8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.softUi => const LinearGradient(
        colors: <Color>[
          Color(0xFFADBCC9),
          Color(0xFFC3D1DD),
          Color(0xFFD7E2EA),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    };
  }

  static LinearGradient backgroundFor({
    required ThemeStyleOption style,
    required Brightness brightness,
    required bool alternative,
  }) {
    return switch ((style, brightness, alternative)) {
      (ThemeStyleOption.emerald, Brightness.light, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFEFFBF5),
            Color(0xFFF7FCF9),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.emerald, Brightness.light, true) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFE8F8F0),
            Color(0xFFF2FCF6),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.emerald, Brightness.dark, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFF041610),
            Color(0xFF08251D),
            Color(0xFF0D3529),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.emerald, Brightness.dark, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFF041510),
          Color(0xFF0A2A21),
          Color(0xFF0D3A2D),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),

      (ThemeStyleOption.midnightDark, Brightness.light, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFF1EFEB),
            Color(0xFFF8F6F2),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.midnightDark, Brightness.light, true) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFEEEAE4),
            Color(0xFFF6F3EE),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.midnightDark, Brightness.dark, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFF101010),
            Color(0xFF121212),
            Color(0xFF1A1A1A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.midnightDark, Brightness.dark, true) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFF0E0E0E),
            Color(0xFF141414),
            Color(0xFF1F1F1F),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),

      (ThemeStyleOption.ocean, Brightness.light, false) => const LinearGradient(
        colors: <Color>[
          Color(0xFFEAF5FE),
          Color(0xFFF2FAFF),
          Color(0xFFFFFFFF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.ocean, Brightness.light, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFFE4F1FC),
          Color(0xFFEEF7FF),
          Color(0xFFFFFFFF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.ocean, Brightness.dark, false) => const LinearGradient(
        colors: <Color>[
          Color(0xFF051525),
          Color(0xFF0A233A),
          Color(0xFF113451),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.ocean, Brightness.dark, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFF04121F),
          Color(0xFF0B2841),
          Color(0xFF143C5E),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),

      (ThemeStyleOption.sunset, Brightness.light, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFFFF2EA),
            Color(0xFFFFF7F0),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.sunset, Brightness.light, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFFFFECE3),
          Color(0xFFFFF4EB),
          Color(0xFFFFFFFF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.sunset, Brightness.dark, false) => const LinearGradient(
        colors: <Color>[
          Color(0xFF22110C),
          Color(0xFF3B1E16),
          Color(0xFF553025),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.sunset, Brightness.dark, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFF1F0E0A),
          Color(0xFF341A13),
          Color(0xFF4D281D),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),

      (ThemeStyleOption.glass, Brightness.light, false) => const LinearGradient(
        colors: <Color>[
          Color(0xFFDFF0FF),
          Color(0xFFE9F6FF),
          Color(0xFFF8FCFF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.glass, Brightness.light, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFFD8EBFD),
          Color(0xFFE5F3FF),
          Color(0xFFF6FBFF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.glass, Brightness.dark, false) => const LinearGradient(
        colors: <Color>[
          Color(0xFF0A1A2B),
          Color(0xFF122B42),
          Color(0xFF1B3D5A),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.glass, Brightness.dark, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFF0C1E30),
          Color(0xFF16324C),
          Color(0xFF214765),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),

      (ThemeStyleOption.softUi, Brightness.light, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFE8EEF3),
            Color(0xFFEEF3F7),
            Color(0xFFF6F9FC),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.softUi, Brightness.light, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFFE2E9EF),
          Color(0xFFEAF1F6),
          Color(0xFFF4F8FB),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.softUi, Brightness.dark, false) => const LinearGradient(
        colors: <Color>[
          Color(0xFF1A2129),
          Color(0xFF222C36),
          Color(0xFF2A3744),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.softUi, Brightness.dark, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFF181F27),
          Color(0xFF212B35),
          Color(0xFF2B3945),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    };
  }
}

class AppTheme {
  static ThemeData light(ThemeStyleOption style) {
    final palette = _palette(style);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: palette.primary,
          secondary: palette.accent,
          tertiary: palette.tertiary,
          surface: palette.lightSurface,
        );

    return _baseTheme(
      style: style,
      brightness: Brightness.light,
      colorScheme: scheme,
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: palette.lightScaffold,
      cardColor: palette.lightCard,
    );
  }

  static ThemeData dark(ThemeStyleOption style) {
    final palette = _palette(style);
    final base = ThemeData(brightness: Brightness.dark).textTheme;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: palette.primary,
          secondary: palette.accent,
          tertiary: palette.tertiary,
          surface: palette.darkSurface,
        );

    return _baseTheme(
      style: style,
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: GoogleFonts.poppinsTextTheme(base),
      scaffoldBackgroundColor: palette.darkScaffold,
      cardColor: palette.darkCard,
    );
  }

  static ThemeData _baseTheme({
    required ThemeStyleOption style,
    required Brightness brightness,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Color scaffoldBackgroundColor,
    required Color cardColor,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 4,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.16),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? colorScheme.onSurface : colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: (textTheme.titleLarge ?? const TextStyle()).copyWith(
          fontSize: 23,
          fontWeight: FontWeight.w700,
          color: isDark ? colorScheme.onSurface : colorScheme.primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      splashFactory: InkRipple.splashFactory,
      listTileTheme: ListTileThemeData(
        minLeadingWidth: 26,
        horizontalTitleGap: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        iconColor: colorScheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? cardColor.withValues(alpha: 0.94)
            : Colors.white.withValues(
                alpha: style == ThemeStyleOption.glass ? 0.7 : 1,
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.secondary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: (textTheme.titleSmall ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.55),
            width: 1.2,
          ),
          textStyle: (textTheme.titleSmall ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorScheme.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: (textTheme.titleSmall ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? paletteDarkSheet(style)
            : paletteLightSheet(style),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary.withValues(alpha: 0.45);
          }
          return null;
        }),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 74,
        labelTextStyle: WidgetStatePropertyAll(
          (textTheme.bodySmall ?? const TextStyle()).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        indicatorShape: const StadiumBorder(),
        indicatorColor: colorScheme.secondary.withValues(alpha: 0.22),
        backgroundColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF232323)
            : const Color(0xFF173A31),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static Color shellNavBackground({
    required ThemeStyleOption style,
    required Brightness brightness,
    required ColorScheme scheme,
  }) {
    if (style == ThemeStyleOption.glass) {
      return brightness == Brightness.dark
          ? const Color(0x8821364A)
          : const Color(0xAAFFFFFF);
    }
    if (style == ThemeStyleOption.midnightDark &&
        brightness == Brightness.dark) {
      return const Color(0xFF151515);
    }
    if (style == ThemeStyleOption.softUi) {
      return brightness == Brightness.dark
          ? const Color(0xFF2A3440)
          : const Color(0xFFE7EDF2);
    }
    return brightness == Brightness.dark
        ? scheme.surface.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.95);
  }

  static _ThemePalette _palette(ThemeStyleOption style) {
    return switch (style) {
      ThemeStyleOption.emerald => const _ThemePalette(
        primary: Color(0xFF0A7A5B),
        accent: Color(0xFF1DBA8A),
        tertiary: Color(0xFFE4C46A),
        lightScaffold: Color(0xFFF7FCF9),
        darkScaffold: Color(0xFF061A14),
        lightSurface: Color(0xFFFBFCF9),
        darkSurface: Color(0xFF10251F),
        lightCard: Color(0xFFFFFFFF),
        darkCard: Color(0xFF0D2A21),
      ),
      ThemeStyleOption.midnightDark => const _ThemePalette(
        primary: Color(0xFF232323),
        accent: AppThemeColors.gold,
        tertiary: Color(0xFFE9C56A),
        lightScaffold: Color(0xFFF6F4EF),
        darkScaffold: AppThemeColors.midnight,
        lightSurface: Color(0xFFFBF8F1),
        darkSurface: Color(0xFF1A1A1A),
        lightCard: Color(0xFFFFFFFF),
        darkCard: Color(0xFF1C1C1C),
      ),
      ThemeStyleOption.ocean => const _ThemePalette(
        primary: Color(0xFF0F6CAB),
        accent: Color(0xFF4CC8F0),
        tertiary: Color(0xFF95E2FF),
        lightScaffold: Color(0xFFF3F9FF),
        darkScaffold: Color(0xFF071C2F),
        lightSurface: Color(0xFFF8FCFF),
        darkSurface: Color(0xFF12283A),
        lightCard: Color(0xFFFFFFFF),
        darkCard: Color(0xFF132B3F),
      ),
      ThemeStyleOption.sunset => const _ThemePalette(
        primary: Color(0xFFB9552D),
        accent: Color(0xFFE56AA6),
        tertiary: Color(0xFFF7B372),
        lightScaffold: Color(0xFFFFF6F1),
        darkScaffold: Color(0xFF22120D),
        lightSurface: Color(0xFFFFFBF8),
        darkSurface: Color(0xFF3A241C),
        lightCard: Color(0xFFFFFFFF),
        darkCard: Color(0xFF3A241C),
      ),
      ThemeStyleOption.glass => const _ThemePalette(
        primary: Color(0xFF2A8FC8),
        accent: Color(0xFF8ED8FF),
        tertiary: Color(0xFFB6EAFF),
        lightScaffold: Color(0xFFEAF5FF),
        darkScaffold: Color(0xFF0C1E30),
        lightSurface: Color(0xFFF5FAFF),
        darkSurface: Color(0xFF1B3244),
        lightCard: Color(0xCCFFFFFF),
        darkCard: Color(0x661A2D40),
      ),
      ThemeStyleOption.softUi => const _ThemePalette(
        primary: Color(0xFF607B93),
        accent: Color(0xFF8FA9C1),
        tertiary: Color(0xFFC3D5E5),
        lightScaffold: Color(0xFFEAF0F5),
        darkScaffold: Color(0xFF1A232D),
        lightSurface: Color(0xFFF0F5FA),
        darkSurface: Color(0xFF283340),
        lightCard: Color(0xFFEAF0F5),
        darkCard: Color(0xFF2A3643),
      ),
    };
  }
}

Color paletteLightSheet(ThemeStyleOption style) {
  return switch (style) {
    ThemeStyleOption.glass => const Color(0xEEFFFFFF),
    ThemeStyleOption.softUi => const Color(0xFFEAF0F5),
    _ => const Color(0xFFFCFEFD),
  };
}

Color paletteDarkSheet(ThemeStyleOption style) {
  return switch (style) {
    ThemeStyleOption.midnightDark => const Color(0xFF171717),
    ThemeStyleOption.glass => const Color(0xCC1A2D40),
    ThemeStyleOption.softUi => const Color(0xFF2A3643),
    _ => const Color(0xFF0C241D),
  };
}

class _ThemePalette {
  const _ThemePalette({
    required this.primary,
    required this.accent,
    required this.tertiary,
    required this.lightScaffold,
    required this.darkScaffold,
    required this.lightSurface,
    required this.darkSurface,
    required this.lightCard,
    required this.darkCard,
  });

  final Color primary;
  final Color accent;
  final Color tertiary;
  final Color lightScaffold;
  final Color darkScaffold;
  final Color lightSurface;
  final Color darkSurface;
  final Color lightCard;
  final Color darkCard;
}
