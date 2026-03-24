import 'dart:ui';

import 'package:azan_app/ads/banner_ad_widget.dart';
import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/features/home/presentation/home_screen.dart';
import 'package:azan_app/features/qibla/presentation/qibla_screen.dart';
import 'package:azan_app/features/quran/presentation/quran_surah_list_screen.dart';
import 'package:azan_app/features/settings/presentation/settings_screen.dart';
import 'package:azan_app/features/tasbih/presentation/tasbih_screen.dart';
import 'package:azan_app/features/theme/theme_mode_option.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/state/app_controller.dart';

class AzanApp extends StatelessWidget {
  const AzanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();

    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(
        brightness: Brightness.light,
        style: appController.themeStyle,
      ),
      darkTheme: _buildTheme(
        brightness: Brightness.dark,
        style: appController.themeStyle,
      ),
      themeMode: appController.themeMode.flutterThemeMode,
      home: _MainScaffold(style: appController.themeStyle),
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
    required ThemeStyleOption style,
  }) {
    final seedColor = _styleSeedColor(style);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final inputFill = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.30);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      cardTheme: CardThemeData(
        color: inputFill,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(
              alpha: brightness == Brightness.dark ? 0.14 : 0.45,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.25),
      ),
    );
  }

  Color _styleSeedColor(ThemeStyleOption style) {
    return switch (style) {
      ThemeStyleOption.glassBlue => const Color(0xFF1E6CEB),
      ThemeStyleOption.emerald => const Color(0xFF198A66),
      ThemeStyleOption.sunset => const Color(0xFFE06B2E),
      ThemeStyleOption.monochrome => const Color(0xFF556070),
    };
  }
}

class _MainScaffold extends StatefulWidget {
  const _MainScaffold({required this.style});

  final ThemeStyleOption style;

  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  int _currentTab = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    QuranSurahListScreen(),
    TasbihScreen(),
    QiblaScreen(),
    SettingsScreen(),
  ];

  static const List<String> _titles = <String>[
    'Prayer Times',
    'Quran',
    'Tasbih',
    'Qibla',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final showBanner = _currentTab == 0 || _currentTab == 4;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_titles[_currentTab]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.16),
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: _BackgroundLayer(style: widget.style)),
          SafeArea(
            child: IndexedStack(index: _currentTab, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showBanner) const BannerAdWidget(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: NavigationBar(
                    selectedIndex: _currentTab,
                    onDestinationSelected: (index) {
                      setState(() => _currentTab = index);
                    },
                    destinations: const <NavigationDestination>[
                      NavigationDestination(
                        icon: Icon(Icons.mosque_outlined),
                        selectedIcon: Icon(Icons.mosque),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.menu_book_outlined),
                        selectedIcon: Icon(Icons.menu_book),
                        label: 'Quran',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.touch_app_outlined),
                        selectedIcon: Icon(Icons.touch_app),
                        label: 'Tasbih',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore),
                        label: 'Qibla',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer({required this.style});

  final ThemeStyleOption style;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final palette = _paletteFor(style, isDark);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.gradient,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -80,
            right: -40,
            child: _GlowBubble(size: 220, color: palette.primaryGlow),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: _GlowBubble(size: 180, color: palette.secondaryGlow),
          ),
        ],
      ),
    );
  }

  _StylePalette _paletteFor(ThemeStyleOption style, bool isDark) {
    return switch (style) {
      ThemeStyleOption.glassBlue =>
        isDark
            ? const _StylePalette(
                gradient: <Color>[
                  Color(0xFF071229),
                  Color(0xFF0E2C5D),
                  Color(0xFF0B1B3D),
                ],
                primaryGlow: Color(0x33FFFFFF),
                secondaryGlow: Color(0x2BC4FFFF),
              )
            : const _StylePalette(
                gradient: <Color>[
                  Color(0xFFE9F3FF),
                  Color(0xFFCFE4FF),
                  Color(0xFFB4D4FF),
                ],
                primaryGlow: Color(0x44FFFFFF),
                secondaryGlow: Color(0x33A9E4FF),
              ),
      ThemeStyleOption.emerald =>
        isDark
            ? const _StylePalette(
                gradient: <Color>[
                  Color(0xFF041A15),
                  Color(0xFF0B3C30),
                  Color(0xFF0A2D24),
                ],
                primaryGlow: Color(0x2FFFFFFF),
                secondaryGlow: Color(0x2B4BFFC7),
              )
            : const _StylePalette(
                gradient: <Color>[
                  Color(0xFFE8F9F3),
                  Color(0xFFC8EFDF),
                  Color(0xFFA7E5CB),
                ],
                primaryGlow: Color(0x44FFFFFF),
                secondaryGlow: Color(0x3391F7CF),
              ),
      ThemeStyleOption.sunset =>
        isDark
            ? const _StylePalette(
                gradient: <Color>[
                  Color(0xFF2A1010),
                  Color(0xFF5A2514),
                  Color(0xFF3E1A0F),
                ],
                primaryGlow: Color(0x2FFFFFFF),
                secondaryGlow: Color(0x33FFC38F),
              )
            : const _StylePalette(
                gradient: <Color>[
                  Color(0xFFFFF0E7),
                  Color(0xFFFFD8C4),
                  Color(0xFFFFC09E),
                ],
                primaryGlow: Color(0x44FFFFFF),
                secondaryGlow: Color(0x33FFDCAE),
              ),
      ThemeStyleOption.monochrome =>
        isDark
            ? const _StylePalette(
                gradient: <Color>[
                  Color(0xFF121519),
                  Color(0xFF28313C),
                  Color(0xFF1A212A),
                ],
                primaryGlow: Color(0x2FFFFFFF),
                secondaryGlow: Color(0x337E95B0),
              )
            : const _StylePalette(
                gradient: <Color>[
                  Color(0xFFF2F5F8),
                  Color(0xFFDBE3EA),
                  Color(0xFFC6D2DC),
                ],
                primaryGlow: Color(0x44FFFFFF),
                secondaryGlow: Color(0x33B7CAE0),
              ),
    };
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _StylePalette {
  const _StylePalette({
    required this.gradient,
    required this.primaryGlow,
    required this.secondaryGlow,
  });

  final List<Color> gradient;
  final Color primaryGlow;
  final Color secondaryGlow;
}
