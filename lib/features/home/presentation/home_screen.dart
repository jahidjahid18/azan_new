import 'dart:async';

import 'package:azan_app/core/models/prayer_info.dart';
import 'package:azan_app/core/models/prohibited_time.dart';
import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/widgets/app_card.dart';
import 'package:azan_app/core/widgets/section_header.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/azkar/presentation/azkar_screen.dart';
import 'package:azan_app/features/calendar/presentation/islamic_events_section.dart';
import 'package:azan_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:azan_app/features/home/presentation/widgets/daily_quran_ayahs_section.dart';
import 'package:azan_app/features/mosque/presentation/mosque_finder_screen.dart';
import 'package:azan_app/features/tracker/presentation/prayer_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

Route<void> _buildSmoothRoute(Widget screen) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final visiblePrayers = _visiblePrayers(
      allPrayers: controller.todayPrayers,
      visibleNames: controller.visiblePrayerNames,
    );
    final currentPrayerWindow = _currentPrayerWindow(
      prayers: controller.todayPrayers,
      now: controller.now,
    );

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AppController>().refreshLocationFromGps(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomPadding),
        children: <Widget>[
          if (controller.location != null) ...<Widget>[
            _CityHeader(
              city: controller.location!.cityName,
              isRefreshing: controller.isBusy,
              onLocatePressed: () => _refreshLocationFromHeader(context),
            ),
            const SizedBox(height: 12),
            _NextPrayerCard(
              nextPrayer: controller.nextPrayer,
              allPrayers: controller.todayPrayers,
            ),
          ] else
            _EmptyLocationState(message: controller.startupError),
          const SizedBox(height: 16),
          if (controller.showPersonalDashboard) ...<Widget>[
            const _DashboardPreviewCard(),
            const SizedBox(height: 6),
          ],
          const SizedBox(height: 16),
          const _QuickActionsRow(),
          if (controller.location != null) ...<Widget>[
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SectionHeader(
                  title: l10n.tr('prayerTimes'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        tooltip: l10n.tr('prayerDisplayFilter'),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _openPrayerFilter(context, controller),
                        icon: const Icon(Icons.tune_rounded),
                      ),
                      IconButton(
                        tooltip: controller.showPersonalDashboard
                            ? 'Hide Personal Dashboard'
                            : 'Show Personal Dashboard',
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          await context
                              .read<AppController>()
                              .setShowPersonalDashboard(
                                !controller.showPersonalDashboard,
                              );
                        },
                        icon: Icon(
                          controller.showPersonalDashboard
                              ? Icons.space_dashboard_rounded
                              : Icons.space_dashboard_outlined,
                          color: controller.showPersonalDashboard
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.tr('copyTodaySchedule'),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _copyPrayerSchedule(
                          context: context,
                          city: controller.location!.cityName,
                          prayers: visiblePrayers,
                          now: controller.now,
                        ),
                        icon: const Icon(Icons.copy_all_rounded),
                      ),
                      IconButton(
                        tooltip: l10n.tr('shareTodaySchedule'),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _sharePrayerSchedule(
                          context: context,
                          city: controller.location!.cityName,
                          prayers: visiblePrayers,
                          now: controller.now,
                        ),
                        icon: const Icon(Icons.share_rounded),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateFormat('EEE, dd MMM').format(controller.now),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildPrayerTimelineCards(
              visiblePrayers: visiblePrayers,
              allPrayers: controller.todayPrayers,
              prohibitedTimes: controller.showProhibitedTimes
                  ? controller.todayProhibitedTimes
                  : const <ProhibitedTime>[],
              currentPrayerWindow: currentPrayerWindow,
              nextPrayer: controller.nextPrayer,
              now: controller.now,
            ),
          ],
          const SizedBox(height: 16),
          DailyQuranAyahsSection(translationLanguage: controller.appLanguage),
          const SizedBox(height: 16),
          IslamicEventsSection(now: controller.now),
        ],
      ),
    );
  }

  bool _isSamePrayer(PrayerInfo prayer, PrayerInfo? nextPrayer) {
    if (nextPrayer == null) return false;
    return prayer.name == nextPrayer.name &&
        prayer.time.year == nextPrayer.time.year &&
        prayer.time.month == nextPrayer.time.month &&
        prayer.time.day == nextPrayer.time.day;
  }

  List<PrayerInfo> _visiblePrayers({
    required List<PrayerInfo> allPrayers,
    required List<String> visibleNames,
  }) {
    final visibleSet = visibleNames.toSet();
    return allPrayers
        .where(
          (prayer) =>
              visibleSet.contains(prayer.name) &&
              prayer.name.toLowerCase() != 'sunrise',
        )
        .toList();
  }

  DateTime? getEndTime(PrayerInfo currentPrayer, List<PrayerInfo> prayerTimes) {
    if (prayerTimes.isEmpty) {
      return null;
    }

    final sorted = List<PrayerInfo>.from(prayerTimes)
      ..sort((a, b) => a.time.compareTo(b.time));

    final currentIndex = sorted.indexWhere(
      (prayer) =>
          prayer.name == currentPrayer.name &&
          prayer.time == currentPrayer.time,
    );
    if (currentIndex == -1) {
      return null;
    }

    final defaultEndTime = currentIndex < sorted.length - 1
        ? sorted[currentIndex + 1].time
        : sorted.first.time.add(const Duration(days: 1));

    return _adjustedPrayerEndTime(
      prayer: currentPrayer,
      defaultEndTime: defaultEndTime,
      prayerTimes: sorted,
    );
  }

  DateTime _adjustedPrayerEndTime({
    required PrayerInfo prayer,
    required DateTime defaultEndTime,
    required List<PrayerInfo> prayerTimes,
  }) {
    if (prayer.name.toLowerCase() != 'asr') {
      return defaultEndTime;
    }

    DateTime? maghribTime;
    for (final item in prayerTimes) {
      if (item.name.toLowerCase() == 'maghrib' &&
          !item.time.isBefore(prayer.time)) {
        maghribTime = item.time;
        break;
      }
    }

    if (maghribTime == null) {
      return defaultEndTime;
    }

    final asrEnd = maghribTime.subtract(const Duration(minutes: 15));
    if (asrEnd.isAfter(prayer.time)) {
      return asrEnd;
    }

    return defaultEndTime;
  }

  _CurrentPrayerWindow? _currentPrayerWindow({
    required List<PrayerInfo> prayers,
    required DateTime now,
  }) {
    if (prayers.length < 2) {
      return null;
    }

    for (var index = 0; index < prayers.length - 1; index++) {
      final current = prayers[index];
      final effectiveEndTime =
          getEndTime(current, prayers) ?? prayers[index + 1].time;
      final isStarted = !now.isBefore(current.time);
      final notEnded = now.isBefore(effectiveEndTime);
      if (isStarted && notEnded) {
        final remaining = effectiveEndTime.difference(now);
        return _CurrentPrayerWindow(
          prayer: current,
          endTime: effectiveEndTime,
          endsIn: remaining.isNegative ? Duration.zero : remaining,
        );
      }
    }

    final lastPrayer = prayers.last;
    if (!now.isBefore(lastPrayer.time)) {
      final nextDayFirst = prayers.first.time.add(const Duration(days: 1));
      final remaining = nextDayFirst.difference(now);
      return _CurrentPrayerWindow(
        prayer: lastPrayer,
        endTime: nextDayFirst,
        endsIn: remaining.isNegative ? Duration.zero : remaining,
      );
    }

    return null;
  }

  List<Widget> _buildPrayerTimelineCards({
    required List<PrayerInfo> visiblePrayers,
    required List<PrayerInfo> allPrayers,
    required List<ProhibitedTime> prohibitedTimes,
    required _CurrentPrayerWindow? currentPrayerWindow,
    required PrayerInfo? nextPrayer,
    required DateTime now,
  }) {
    final timeline =
        <_PrayerTimelineItem>[
          ...visiblePrayers.map(_PrayerTimelineItem.prayer),
          ...prohibitedTimes.map(_PrayerTimelineItem.prohibited),
        ]..sort((a, b) {
          final byTime = a.at.compareTo(b.at);
          if (byTime != 0) {
            return byTime;
          }
          return a.sortOrder.compareTo(b.sortOrder);
        });

    return timeline
        .map((item) {
          if (item.prayer != null) {
            final prayer = item.prayer!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PrayerTimeCard(
                prayer: prayer,
                isNext: _isSamePrayer(prayer, nextPrayer),
                isCurrent: currentPrayerWindow?.prayer == prayer,
                now: now,
                endTime:
                    getEndTime(prayer, allPrayers) ??
                    (currentPrayerWindow?.prayer == prayer
                        ? currentPrayerWindow?.endTime
                        : null),
                endsIn: currentPrayerWindow?.prayer == prayer
                    ? currentPrayerWindow?.endsIn
                    : null,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ProhibitedTimeCard(window: item.prohibited!, now: now),
          );
        })
        .toList(growable: false);
  }

  void _openPrayerFilter(BuildContext context, AppController controller) {
    final l10n = context.l10n;
    final selected = controller.visiblePrayerNames.toSet();
    var showProhibitedTimes = controller.showProhibitedTimes;
    final allOptions = <String>[
      ...AppConstants.mandatoryPrayerNames,
      ...AppConstants.optionalPrayerNames,
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setBottomState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                6,
                16,
                16 + MediaQuery.of(sheetContext).viewPadding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.tr('prayerDisplayFilter'),
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.tr('prayerDisplayFilterSub'),
                    style: Theme.of(sheetContext).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.tr('showProhibitedTimes')),
                    value: showProhibitedTimes,
                    onChanged: (value) {
                      setBottomState(() => showProhibitedTimes = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  ...allOptions.map((name) {
                    final isMandatory = AppConstants.mandatoryPrayerNames
                        .contains(name);
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(l10n.prayerName(name)),
                      subtitle: isMandatory
                          ? Text(l10n.tr('obligatoryPrayer'))
                          : null,
                      value: selected.contains(name),
                      onChanged: (checked) {
                        final isChecked = checked ?? false;
                        setBottomState(() {
                          if (isChecked) {
                            selected.add(name);
                            return;
                          }
                          if (isMandatory) {
                            final mandatorySelected = AppConstants
                                .mandatoryPrayerNames
                                .where(selected.contains)
                                .length;
                            if (mandatorySelected <= 1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.tr('mandatoryPrayersRequired'),
                                  ),
                                ),
                              );
                              return;
                            }
                          }
                          selected.remove(name);
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await controller.setVisiblePrayerNames(
                          selected.toList(),
                        );
                        await controller.setShowProhibitedTimes(
                          showProhibitedTimes,
                        );
                        if (!context.mounted) return;
                        Navigator.of(sheetContext).pop();
                      },
                      child: Text(l10n.tr('save')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _copyPrayerSchedule({
    required BuildContext context,
    required String city,
    required List<PrayerInfo> prayers,
    required DateTime now,
  }) async {
    final l10n = context.l10n;
    final text = _buildPrayerScheduleText(
      context: context,
      city: city,
      prayers: prayers,
      now: now,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tr('scheduleCopied'))));
  }

  Future<void> _sharePrayerSchedule({
    required BuildContext context,
    required String city,
    required List<PrayerInfo> prayers,
    required DateTime now,
  }) async {
    final text = _buildPrayerScheduleText(
      context: context,
      city: city,
      prayers: prayers,
      now: now,
    );
    await Share.share(text);
  }

  String _buildPrayerScheduleText({
    required BuildContext context,
    required String city,
    required List<PrayerInfo> prayers,
    required DateTime now,
  }) {
    final l10n = context.l10n;
    final formatter = DateFormat('hh:mm a');
    final lines = <String>[
      '${l10n.tr('prayerTimes')} - $city',
      DateFormat('EEE, dd MMM yyyy').format(now),
      '',
      ...prayers.map(
        (p) => '${l10n.prayerName(p.name)}: ${formatter.format(p.time)}',
      ),
    ];
    return lines.join('\n');
  }

  Future<void> _refreshLocationFromHeader(BuildContext context) async {
    final error = await context.read<AppController>().refreshLocationFromGps();
    if (!context.mounted || error == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}

class _CityHeader extends StatelessWidget {
  const _CityHeader({
    required this.city,
    required this.isRefreshing,
    required this.onLocatePressed,
  });

  final String city;
  final bool isRefreshing;
  final VoidCallback onLocatePressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Icon(Icons.location_on_rounded, color: scheme.secondary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                city,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.secondary.withValues(alpha: 0.12),
            border: Border.all(color: scheme.secondary.withValues(alpha: 0.35)),
          ),
          child: IconButton(
            tooltip: l10n.tr('useCurrentLocation'),
            onPressed: isRefreshing ? null : onLocatePressed,
            icon: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
          ),
        ),
      ],
    );
  }
}

class _NextPrayerCard extends StatefulWidget {
  const _NextPrayerCard({required this.nextPrayer, required this.allPrayers});

  final PrayerInfo? nextPrayer;
  final List<PrayerInfo> allPrayers;

  @override
  State<_NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<_NextPrayerCard> {
  late DateTime _now;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prayerTimeFormat = DateFormat('hh:mm a');
    final countdown = widget.nextPrayer == null
        ? Duration.zero
        : widget.nextPrayer!.time.difference(_now);
    final progress = _remainingProgress(
      now: _now,
      nextPrayer: widget.nextPrayer,
      allPrayers: widget.allPrayers,
    );
    final countdownValue = _formatStableDuration(countdown);

    return AppSurfaceCard(
      radius: 22,
      enableEntranceAnimation: false,
      entranceDirection: AppCardEntranceDirection.none,
      padding: const EdgeInsets.all(18),
      gradient: const LinearGradient(
        colors: <Color>[Color(0xFF0B6D59), Color(0xFF20C89A)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                l10n.tr('nextPrayer'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.nights_stay_rounded, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.nextPrayer == null
                ? l10n.tr('unavailable')
                : l10n.prayerName(widget.nextPrayer!.name),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.nextPrayer == null
                      ? '--:--'
                      : prayerTimeFormat.format(widget.nextPrayer!.time),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 190),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Starts in',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 30,
                        height: 1.0,
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      countdownValue,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 30,
                        height: 1.0,
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w800,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  minHeight: 5,
                  value: value,
                  backgroundColor: Colors.white.withValues(alpha: 0.24),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.92),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatStableDuration(Duration duration) {
    final safeDuration = duration.isNegative ? Duration.zero : duration;
    final hours = safeDuration.inHours;
    final minutes = safeDuration.inMinutes.remainder(60);
    final seconds = safeDuration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _remainingProgress({
    required DateTime now,
    required PrayerInfo? nextPrayer,
    required List<PrayerInfo> allPrayers,
  }) {
    if (nextPrayer == null) {
      return 0;
    }
    if (allPrayers.isEmpty) {
      return 0;
    }

    final sorted = List<PrayerInfo>.from(allPrayers)
      ..sort((a, b) => a.time.compareTo(b.time));
    final nextTime = nextPrayer.time;
    final nextIndex = sorted.indexWhere(
      (p) => p.name == nextPrayer.name && p.time == nextPrayer.time,
    );

    DateTime previousTime;
    if (nextIndex == -1) {
      previousTime = sorted.last.time;
      if (previousTime.isAfter(nextTime)) {
        previousTime = previousTime.subtract(const Duration(days: 1));
      }
    } else if (nextIndex == 0) {
      previousTime = sorted.last.time.subtract(const Duration(days: 1));
    } else {
      previousTime = sorted[nextIndex - 1].time;
    }

    final totalMillis = nextTime.difference(previousTime).inMilliseconds;
    if (totalMillis <= 0) {
      return 0;
    }

    final elapsedMillis = now.difference(previousTime).inMilliseconds;
    final ratio = elapsedMillis / totalMillis;
    return ratio.clamp(0.0, 1.0);
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: <Widget>[
        Expanded(
          child: _QuickActionButton(
            icon: Icons.checklist_rounded,
            label: l10n.tr('quickTracker'),
            onTap: () {
              Navigator.of(
                context,
              ).push(_buildSmoothRoute(const PrayerTrackerScreen()));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.map_outlined,
            label: l10n.tr('quickMosques'),
            onTap: () {
              Navigator.of(
                context,
              ).push(_buildSmoothRoute(const MosqueFinderScreen()));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.auto_stories_rounded,
            label: l10n.tr('quickAzkar'),
            onTap: () {
              Navigator.of(
                context,
              ).push(_buildSmoothRoute(const AzkarScreen()));
            },
          ),
        ),
      ],
    );
  }
}

class _DashboardPreviewCard extends StatelessWidget {
  const _DashboardPreviewCard();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final completed = controller.todayCompletedPrayersCount;
    final total = AppConstants.prayerOrder.length;

    return AppSurfaceCard(
      gradient: const LinearGradient(
        colors: <Color>[Color(0xFF0B6D59), Color(0xFF20C89A)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Personal Dashboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.insights_rounded, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _DashboardStatChip(label: 'Prayers', value: '$completed/$total'),
              _DashboardStatChip(
                label: 'Streak',
                value: '${controller.currentStreak} day(s)',
              ),
              _DashboardStatChip(
                label: 'Quran',
                value: '${controller.quranReadingTodayMinutes} min',
              ),
              _DashboardStatChip(
                label: 'Tasbih',
                value: '${controller.dailyTasbihCount}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(_buildSmoothRoute(const DashboardScreen()));
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Open Dashboard'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatChip extends StatelessWidget {
  const _DashboardStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _pressed ? 0.98 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: AppCard(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            gradient: LinearGradient(
              colors: <Color>[
                Theme.of(context).cardTheme.color ?? Colors.white,
                scheme.secondary.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              children: <Widget>[
                Icon(widget.icon, size: 22, color: scheme.primary),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrayerTimeCard extends StatelessWidget {
  const _PrayerTimeCard({
    required this.prayer,
    required this.isNext,
    required this.isCurrent,
    required this.now,
    required this.endTime,
    required this.endsIn,
  });

  final PrayerInfo prayer;
  final bool isNext;
  final bool isCurrent;
  final DateTime now;
  final DateTime? endTime;
  final Duration? endsIn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPrayerGradient = LinearGradient(
      colors: isDark
          ? <Color>[
              scheme.secondary.withValues(alpha: 0.46),
              scheme.tertiary.withValues(alpha: 0.4),
            ]
          : <Color>[
              scheme.primary.withValues(alpha: 0.28),
              scheme.secondary.withValues(alpha: 0.34),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final icon = switch (prayer.name.toLowerCase()) {
      'fajr' => Icons.nights_stay_rounded,
      'dhuhr' => Icons.wb_sunny_rounded,
      'asr' => Icons.wb_twilight_rounded,
      'maghrib' => Icons.wb_twilight_rounded,
      'isha' => Icons.dark_mode_rounded,
      _ => Icons.access_time_rounded,
    };
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
      color: isCurrent
          ? (isDark ? Colors.white : scheme.primary)
          : Theme.of(context).colorScheme.onSurface,
      shadows: isCurrent
          ? <Shadow>[
              Shadow(
                color: scheme.secondary.withValues(alpha: 0.28),
                blurRadius: 10,
              ),
            ]
          : null,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOut,
        opacity: isCurrent ? (now.second.isEven ? 1 : 0.76) : 1,
        child: Container(
          decoration: isCurrent
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: scheme.secondary.withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                )
              : null,
          child: AppSurfaceCard(
            gradient: isCurrent ? currentPrayerGradient : null,
            backgroundColor: isCurrent
                ? null
                : Theme.of(context).cardTheme.color,
            enableEntranceAnimation: false,
            entranceDirection: AppCardEntranceDirection.none,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 4,
                  height: isCurrent ? 50 : 44,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? scheme.secondary
                        : scheme.outlineVariant.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (isCurrent) ...<Widget>[
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondary.withValues(
                              alpha: isDark ? 0.28 : 0.2,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: scheme.secondary.withValues(alpha: 0.5),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: scheme.secondary.withValues(alpha: 0.26),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Ongoing',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ],
                      Row(
                        children: <Widget>[
                          if (isNext)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                l10n.tr('nextPrayer'),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          Icon(
                            icon,
                            size: 16,
                            color: isCurrent
                                ? scheme.secondary
                                : scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(l10n.prayerName(prayer.name), style: titleStyle),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prayer.isObligatory
                            ? l10n.tr('obligatoryPrayer')
                            : l10n.tr('additionalPrayer'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isCurrent
                              ? (isDark
                                    ? Colors.white.withValues(alpha: 0.92)
                                    : scheme.primary.withValues(alpha: 0.9))
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isCurrent
                            ? 12
                            : isNext
                            ? 8
                            : 0,
                        vertical: isCurrent
                            ? 7
                            : isNext
                            ? 4
                            : 0,
                      ),
                      decoration: isCurrent
                          ? BoxDecoration(
                              color: scheme.secondary.withValues(
                                alpha: isDark ? 0.32 : 0.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: scheme.secondary.withValues(alpha: 0.52),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: scheme.secondary.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            )
                          : null,
                      child: Text(
                        DateFormat('hh:mm a').format(prayer.time),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: isCurrent
                              ? FontWeight.w900
                              : FontWeight.w800,
                          color: isCurrent && isDark
                              ? Colors.white
                              : isCurrent
                              ? scheme.primary
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    if (endTime != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        'Ends at ${DateFormat('hh:mm a').format(endTime ?? prayer.time)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 15,
                          fontWeight: isCurrent
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant
                              .withValues(alpha: isCurrent ? 0.98 : 0.85),
                        ),
                      ),
                      if (isCurrent && endTime != null) ...<Widget>[
                        const SizedBox(height: 8),
                        _PrayerProgressBar(
                          progress: _progress(
                            start: prayer.time,
                            end: endTime!,
                            now: now,
                          ),
                        ),
                      ],
                    ],
                    if (isCurrent && endsIn != null) ...<Widget>[
                      const SizedBox(height: 6),
                      _buildEndsInChip(
                        context: context,
                        label: l10n.tr('endsIn', <String, String>{
                          'duration': _formatStableDuration(endsIn!),
                        }),
                        remaining: endsIn!,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatStableDuration(Duration duration) {
    final safeDuration = duration.isNegative ? Duration.zero : duration;
    final hours = safeDuration.inHours;
    final minutes = safeDuration.inMinutes.remainder(60);
    final seconds = safeDuration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _progress({
    required DateTime start,
    required DateTime end,
    required DateTime now,
  }) {
    final totalMillis = end.difference(start).inMilliseconds;
    if (totalMillis <= 0) {
      return 0;
    }
    final elapsedMillis = now.difference(start).inMilliseconds;
    final ratio = elapsedMillis / totalMillis;
    return ratio.clamp(0.0, 1.0);
  }

  Widget _buildEndsInChip({
    required BuildContext context,
    required String label,
    required Duration remaining,
    required bool isDark,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final safeDuration = remaining.isNegative ? Duration.zero : remaining;
    final isCritical = safeDuration < const Duration(minutes: 30);
    final isWarning = !isCritical && safeDuration < const Duration(hours: 2);

    final bgColor = isCritical
        ? const Color(0xFFDB4A43).withValues(alpha: isDark ? 0.74 : 0.16)
        : isWarning
        ? const Color(0xFFF4A840).withValues(alpha: isDark ? 0.72 : 0.18)
        : scheme.secondary.withValues(alpha: 0.16);
    final borderColor = isCritical
        ? const Color(0xFFDB4A43).withValues(alpha: isDark ? 0.9 : 0.65)
        : isWarning
        ? const Color(0xFFF4A840).withValues(alpha: isDark ? 0.9 : 0.65)
        : scheme.secondary.withValues(alpha: 0.35);
    final glowColor = isCritical
        ? const Color(0xFFDB4A43).withValues(alpha: isDark ? 0.34 : 0.3)
        : isWarning
        ? const Color(0xFFF4A840).withValues(alpha: isDark ? 0.28 : 0.24)
        : scheme.secondary.withValues(alpha: 0.2);
    final textColor = isCritical && isDark
        ? Colors.white
        : isCritical
        ? const Color(0xFF8C201B)
        : isWarning && isDark
        ? Colors.white
        : isWarning
        ? const Color(0xFF8D4D00)
        : Theme.of(context).colorScheme.onSurface;

    final blinkOpacity = isCritical ? (now.second.isEven ? 1.0 : 0.72) : 1.0;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeInOut,
      opacity: blinkOpacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: glowColor,
              blurRadius: isCritical ? 14 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _PrayerProgressBar extends StatelessWidget {
  const _PrayerProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 4,
          value: progress,
          backgroundColor: scheme.outlineVariant.withValues(alpha: 0.26),
          valueColor: AlwaysStoppedAnimation<Color>(
            scheme.secondary.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

class _ProhibitedTimeCard extends StatelessWidget {
  const _ProhibitedTimeCard({required this.window, required this.now});

  final ProhibitedTime window;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final isActive = !now.isBefore(window.start) && now.isBefore(window.end);
    final remaining = window.end.difference(now);
    final safeRemaining = remaining.isNegative ? Duration.zero : remaining;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isActive
        ? const Color(0xFFDB4A43).withValues(alpha: isDark ? 0.34 : 0.13)
        : const Color(0xFFF4A840).withValues(alpha: isDark ? 0.30 : 0.14);
    final accentColor = isActive
        ? const Color(0xFFDB4A43)
        : const Color(0xFFF4A840);

    final opacity = isActive ? (now.second.isEven ? 1.0 : 0.82) : 1.0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOut,
      opacity: opacity,
      child: AppSurfaceCard(
        radius: 16,
        enableEntranceAnimation: false,
        entranceDirection: AppCardEntranceDirection.none,
        backgroundColor: cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.warning_amber_rounded,
                        color: accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Prohibited Time',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF7A2A25),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    window.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.88)
                          : const Color(0xFF8C201B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (isActive) ...<Widget>[
                  Text(
                    'Ends in ${_formatDuration(safeRemaining)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.96)
                          : const Color(0xFF8C201B),
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  DateFormat('hh:mm a').format(window.start),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  'Ends at ${DateFormat('hh:mm a').format(window.end)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _CurrentPrayerWindow {
  const _CurrentPrayerWindow({
    required this.prayer,
    required this.endTime,
    required this.endsIn,
  });

  final PrayerInfo prayer;
  final DateTime endTime;
  final Duration endsIn;
}

class _PrayerTimelineItem {
  _PrayerTimelineItem.prayer(this.prayer)
    : prohibited = null,
      at = prayer!.time,
      sortOrder = 0;

  _PrayerTimelineItem.prohibited(this.prohibited)
    : prayer = null,
      at = prohibited!.start,
      sortOrder = 1;

  final PrayerInfo? prayer;
  final ProhibitedTime? prohibited;
  final DateTime at;
  final int sortOrder;
}

class _EmptyLocationState extends StatelessWidget {
  const _EmptyLocationState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Column(
        children: <Widget>[
          Icon(
            Icons.location_off_rounded,
            size: 42,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text(
            message ?? context.l10n.tr('locationUnavailableHint'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
