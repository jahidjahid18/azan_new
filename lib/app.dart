import 'package:azan_app/ads/banner_ad_widget.dart';
import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/features/home/presentation/home_screen.dart';
import 'package:azan_app/features/qibla/presentation/qibla_screen.dart';
import 'package:azan_app/features/quran/presentation/quran_surah_list_screen.dart';
import 'package:azan_app/features/settings/presentation/settings_screen.dart';
import 'package:azan_app/features/tasbih/presentation/tasbih_screen.dart';
import 'package:azan_app/features/theme/theme_mode_option.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF136A4F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7F3),
        cardTheme: const CardThemeData(elevation: 1, margin: EdgeInsets.zero),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF136A4F),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: appController.themeMode.flutterThemeMode,
      home: const _MainScaffold(),
    );
  }
}

class _MainScaffold extends StatefulWidget {
  const _MainScaffold();

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
      appBar: AppBar(title: Text(_titles[_currentTab])),
      body: SafeArea(
        child: IndexedStack(index: _currentTab, children: _screens),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showBanner) const BannerAdWidget(),
          NavigationBar(
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
        ],
      ),
    );
  }
}
