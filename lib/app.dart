import 'dart:async';

import 'package:azan_app/ads/banner_ad_widget.dart';
import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/theme/app_theme.dart';
import 'package:azan_app/core/widgets/app_gradient_background.dart';
import 'package:azan_app/features/home/presentation/home_screen.dart';
import 'package:azan_app/features/qibla/presentation/qibla_screen.dart';
import 'package:azan_app/features/quran/presentation/quran_dashboard_screen.dart';
import 'package:azan_app/features/settings/presentation/settings_screen.dart';
import 'package:azan_app/features/tasbih/presentation/tasbih_screen.dart';
import 'package:azan_app/features/theme/theme_mode_option.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AzanApp extends StatelessWidget {
  const AzanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();

    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(appController.themeStyle),
      darkTheme: AppTheme.dark(appController.themeStyle),
      themeMode: appController.themeMode.flutterThemeMode,
      themeAnimationDuration: const Duration(milliseconds: 420),
      themeAnimationCurve: Curves.easeInOutCubic,
      locale: appController.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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
  late DateTime _headerNow;
  Timer? _headerTicker;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    QuranDashboardScreen(),
    TasbihScreen(),
    QiblaScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _headerNow = DateTime.now();
    _headerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _headerNow = DateTime.now());
    });
  }

  @override
  void dispose() {
    _headerTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = _headerNow;
    final media = MediaQuery.of(context);
    final l10n = context.l10n;
    final style = context.select<AppController, ThemeStyleOption>(
      (c) => c.themeStyle,
    );
    final scheme = Theme.of(context).colorScheme;
    final showBanner = _currentTab == 0 || _currentTab == 4;
    final todayDate = DateFormat('EEEE, d MMMM').format(now);
    final hijriDate = HijriCalendar.fromDate(now).toFormat('dd MMMM yyyy');
    final currentTime = DateFormat('hh:mm:ss a').format(now);
    final titles = <String>[
      l10n.tr('titlePrayerTimes'),
      l10n.tr('titleQuran'),
      l10n.tr('titleTasbih'),
      l10n.tr('titleQibla'),
      l10n.tr('titleSettings'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentTab]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  '$todayDate | $hijriDate | $currentTime',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: AppGradientBackground(
        useAlternative: _currentTab == 1 || _currentTab == 3,
        child: MediaQuery(
          data: media.copyWith(
            padding: media.padding.copyWith(bottom: 0),
            viewPadding: media.viewPadding.copyWith(bottom: 0),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey<int>(_currentTab),
                child: _screens[_currentTab],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showBanner) const BannerAdWidget(),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.shellNavBackground(
                style: style,
                brightness: Theme.of(context).brightness,
                scheme: scheme,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: scheme.secondary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: NavigationBar(
                selectedIndex: _currentTab,
                onDestinationSelected: (index) {
                  setState(() => _currentTab = index);
                },
                destinations: <NavigationDestination>[
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: l10n.tr('navHome'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.menu_book_outlined),
                    selectedIcon: const Icon(Icons.menu_book_rounded),
                    label: l10n.tr('navQuran'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.touch_app_outlined),
                    selectedIcon: const Icon(Icons.touch_app_rounded),
                    label: l10n.tr('navTasbih'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.explore_outlined),
                    selectedIcon: const Icon(Icons.explore_rounded),
                    label: l10n.tr('navQibla'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings_rounded),
                    label: l10n.tr('navSettings'),
                  ),
                ],
                animationDuration: const Duration(milliseconds: 320),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                height: 72,
                backgroundColor: Colors.transparent,
                indicatorShape: const StadiumBorder(),
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                overlayColor: WidgetStatePropertyAll(
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
