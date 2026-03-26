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

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    QuranDashboardScreen(),
    TasbihScreen(),
    QiblaScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final now = context.watch<AppController>().now;
    final l10n = context.l10n;
    final showBanner = _currentTab == 0 || _currentTab == 4;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showBanner) const BannerAdWidget(),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
