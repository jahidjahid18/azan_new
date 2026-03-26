import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeColors {
  static const Color deepGreen = Color(0xFF0A5C45);
  static const Color emerald = Color(0xFF118C68);
  static const Color softTeal = Color(0xFF2DB58A);
  static const Color forestDark = Color(0xFF06261D);
  static const Color forestMid = Color(0xFF0B3C2F);
  static const Color gold = Color(0xFFD4A62A);
  static const Color softGold = Color(0xFFE8C96B);
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: <Color>[
      AppThemeColors.deepGreen,
      AppThemeColors.emerald,
      AppThemeColors.softTeal,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient alternative = LinearGradient(
    colors: <Color>[
      AppThemeColors.forestDark,
      AppThemeColors.forestMid,
      AppThemeColors.deepGreen,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightBackgroundPrimary = LinearGradient(
    colors: <Color>[Color(0xFFF1FBF6), Color(0xFFFAF7ED), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightBackgroundAlternative = LinearGradient(
    colors: <Color>[Color(0xFFEEF9F4), Color(0xFFFFF9EE), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkBackgroundPrimary = LinearGradient(
    colors: <Color>[Color(0xFF041610), Color(0xFF08251D), Color(0xFF0D3529)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkBackgroundAlternative = LinearGradient(
    colors: <Color>[Color(0xFF041510), Color(0xFF0A2A21), Color(0xFF0D3A2D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient primaryFor(ThemeStyleOption style) {
    return switch (style) {
      ThemeStyleOption.muslimPro => const LinearGradient(
        colors: <Color>[
          Color(0xFF0A5C45),
          Color(0xFF118C68),
          Color(0xFF2DB58A),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.glassBlue => const LinearGradient(
        colors: <Color>[
          Color(0xFF123F70),
          Color(0xFF1E5E9B),
          Color(0xFF2F86C9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.emerald => const LinearGradient(
        colors: <Color>[
          Color(0xFF0A6E53),
          Color(0xFF0F9A72),
          Color(0xFF25C590),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.sunset => const LinearGradient(
        colors: <Color>[
          Color(0xFF6E3E1E),
          Color(0xFFA35A27),
          Color(0xFFE08A3A),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.monochrome => const LinearGradient(
        colors: <Color>[
          Color(0xFF2B3136),
          Color(0xFF3D444A),
          Color(0xFF565F66),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    };
  }

  static LinearGradient alternativeFor(ThemeStyleOption style) {
    return switch (style) {
      ThemeStyleOption.muslimPro => const LinearGradient(
        colors: <Color>[
          Color(0xFF06261D),
          Color(0xFF0B3C2F),
          Color(0xFF0A5C45),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.glassBlue => const LinearGradient(
        colors: <Color>[
          Color(0xFF091F3A),
          Color(0xFF12375F),
          Color(0xFF1B4E84),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.emerald => const LinearGradient(
        colors: <Color>[
          Color(0xFF07271E),
          Color(0xFF0B4A38),
          Color(0xFF0E6A50),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.sunset => const LinearGradient(
        colors: <Color>[
          Color(0xFF2B160C),
          Color(0xFF4A2614),
          Color(0xFF6E3E1E),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ThemeStyleOption.monochrome => const LinearGradient(
        colors: <Color>[
          Color(0xFF1E2226),
          Color(0xFF2A3035),
          Color(0xFF383F46),
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
      (ThemeStyleOption.muslimPro, Brightness.light, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFF1FBF6),
            Color(0xFFFAF7ED),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.muslimPro, Brightness.light, true) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFEEF9F4),
            Color(0xFFFFF9EE),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.muslimPro, Brightness.dark, false) =>
        darkBackgroundPrimary,
      (ThemeStyleOption.muslimPro, Brightness.dark, true) =>
        darkBackgroundAlternative,

      (ThemeStyleOption.glassBlue, Brightness.light, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFEDF5FF),
            Color(0xFFF4FAFF),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.glassBlue, Brightness.light, true) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFEAF2FF),
            Color(0xFFF0F7FF),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.glassBlue, Brightness.dark, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFF061220),
            Color(0xFF0B223A),
            Color(0xFF12304F),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.glassBlue, Brightness.dark, true) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFF081526),
            Color(0xFF102A47),
            Color(0xFF173A61),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),

      (ThemeStyleOption.emerald, Brightness.light, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFEFFCF6),
            Color(0xFFF4FFF9),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.emerald, Brightness.light, true) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFEAFBF3),
            Color(0xFFF2FFF8),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.emerald, Brightness.dark, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFF051912),
            Color(0xFF0A2E23),
            Color(0xFF0E4233),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.emerald, Brightness.dark, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFF062017),
          Color(0xFF0C3528),
          Color(0xFF12503D),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),

      (ThemeStyleOption.sunset, Brightness.light, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFFFF5EB),
            Color(0xFFFFFAF3),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.sunset, Brightness.light, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFFFFF1E4),
          Color(0xFFFFF7EE),
          Color(0xFFFFFFFF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.sunset, Brightness.dark, false) => const LinearGradient(
        colors: <Color>[
          Color(0xFF201108),
          Color(0xFF382012),
          Color(0xFF4D2C1A),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      (ThemeStyleOption.sunset, Brightness.dark, true) => const LinearGradient(
        colors: <Color>[
          Color(0xFF26150B),
          Color(0xFF452614),
          Color(0xFF63351C),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),

      (ThemeStyleOption.monochrome, Brightness.light, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFF4F5F7),
            Color(0xFFF9FAFB),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.monochrome, Brightness.light, true) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFFF1F3F5),
            Color(0xFFF7F8FA),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.monochrome, Brightness.dark, false) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFF171B1F),
            Color(0xFF23282D),
            Color(0xFF2E353B),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      (ThemeStyleOption.monochrome, Brightness.dark, true) =>
        const LinearGradient(
          colors: <Color>[
            Color(0xFF1A1F23),
            Color(0xFF282E34),
            Color(0xFF353D44),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
    };
  }
}

class AppTheme {
  static ThemeData light(ThemeStyleOption style) {
    final colors = _palette(style);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: colors.primary,
          secondary: colors.accent,
          tertiary: AppThemeColors.softGold,
          surface: const Color(0xFFFBFCF9),
        );
    return _baseTheme(
      brightness: Brightness.light,
      colorScheme: scheme,
      textTheme: style == ThemeStyleOption.muslimPro
          ? GoogleFonts.cairoTextTheme()
          : GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFFBFCF9),
      cardColor: Colors.white,
    );
  }

  static ThemeData dark(ThemeStyleOption style) {
    final colors = _palette(style);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: colors.primary,
          secondary: colors.accent,
          tertiary: AppThemeColors.softGold,
        );
    return _baseTheme(
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: style == ThemeStyleOption.muslimPro
          ? GoogleFonts.cairoTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            )
          : GoogleFonts.poppinsTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ),
      scaffoldBackgroundColor: const Color(0xFF061A14),
      cardColor: const Color(0xFF0D2A21),
    );
  }

  static ThemeData _baseTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Color scaffoldBackgroundColor,
    required Color cardColor,
  }) {
    return ThemeData(
      useMaterial3: true,
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
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.35),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: brightness == Brightness.light
            ? colorScheme.primary
            : colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: (textTheme.titleLarge ?? const TextStyle()).copyWith(
          fontSize: 23,
          fontWeight: FontWeight.w700,
          color: brightness == Brightness.light
              ? colorScheme.primary
              : colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? Colors.white
            : cardColor.withValues(alpha: 0.94),
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
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFFFCFEFD)
            : const Color(0xFF0C241D),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
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
        backgroundColor: brightness == Brightness.light
            ? const Color(0xFF173A31)
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

  static _ThemePalette _palette(ThemeStyleOption style) {
    return switch (style) {
      ThemeStyleOption.muslimPro => const _ThemePalette(
        primary: AppThemeColors.deepGreen,
        accent: AppThemeColors.gold,
      ),
      ThemeStyleOption.glassBlue => const _ThemePalette(
        primary: Color(0xFF1C5687),
        accent: Color(0xFF3CA3F5),
      ),
      ThemeStyleOption.emerald => const _ThemePalette(
        primary: Color(0xFF0A7A5B),
        accent: Color(0xFF19B485),
      ),
      ThemeStyleOption.sunset => const _ThemePalette(
        primary: Color(0xFF8B4B23),
        accent: Color(0xFFF0A74A),
      ),
      ThemeStyleOption.monochrome => const _ThemePalette(
        primary: Color(0xFF2D3338),
        accent: Color(0xFF8E969E),
      ),
    };
  }
}

class _ThemePalette {
  const _ThemePalette({required this.primary, required this.accent});

  final Color primary;
  final Color accent;
}
