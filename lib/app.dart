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
import 'package:azan_app/features/tools/presentation/tools_screen.dart';
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

class _MainScaffoldState extends State<_MainScaffold>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  late DateTime _headerNow;
  Timer? _headerTicker;
  late final AnimationController _tabTransitionController;
  late final Animation<double> _tabFade;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    QuranDashboardScreen(),
    ToolsScreen(),
    QiblaScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _headerNow = DateTime.now();
    _tabTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1,
    );
    _tabFade = CurvedAnimation(
      parent: _tabTransitionController,
      curve: Curves.easeOutCubic,
    );
    _headerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _headerNow = DateTime.now());
    });
  }

  @override
  void dispose() {
    _headerTicker?.cancel();
    _tabTransitionController.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showBanner = _currentTab == 0 || _currentTab == 4;
    final todayDate = DateFormat('EEEE, d MMMM').format(now);
    final hijriDate = HijriCalendar.fromDate(now).toFormat('dd MMMM yyyy');
    final currentTime = DateFormat('hh:mm:ss a').format(now);
    final titles = <String>[
      'Solat',
      l10n.tr('titleQuran'),
      'Tools',
      l10n.tr('titleQibla'),
      l10n.tr('titleSettings'),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              titles[_currentTab],
              style: Theme.of(
                context,
              ).appBarTheme.titleTextStyle?.copyWith(height: 1.0),
            ),
            const SizedBox(height: 1),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: isDark ? Colors.white : scheme.primary,
                    shadows: <Shadow>[
                      Shadow(
                        color: scheme.secondary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$todayDate | $hijriDate | $currentTime',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      height: 1.0,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : scheme.primary,
                      shadows: <Shadow>[
                        Shadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.55),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                        Shadow(
                          color: scheme.secondary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            child: FadeTransition(
              opacity: _tabFade,
              child: IndexedStack(index: _currentTab, children: _screens),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showBanner)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(child: BannerAdWidget()),
            ),
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
                  if (_currentTab == index) {
                    return;
                  }
                  setState(() => _currentTab = index);
                  _tabTransitionController.forward(from: 0);
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
                    icon: const Icon(Icons.grid_view_outlined),
                    selectedIcon: const Icon(Icons.grid_view_rounded),
                    label: 'Tools',
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
