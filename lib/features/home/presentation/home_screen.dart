import 'dart:async';

import 'package:azan_app/core/models/prayer_info.dart';
import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/theme/app_theme.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/azkar/presentation/azkar_screen.dart';
import 'package:azan_app/features/calendar/presentation/islamic_events_section.dart';
import 'package:azan_app/features/home/presentation/widgets/daily_quran_ayahs_section.dart';
import 'package:azan_app/features/mosque/presentation/mosque_finder_screen.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:azan_app/features/tracker/presentation/prayer_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
      prayers: visiblePrayers,
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
            _CityHeader(city: controller.location!.cityName),
            const SizedBox(height: 12),
            _NextPrayerCard(nextPrayer: controller.nextPrayer),
          ] else
            _EmptyLocationState(message: controller.startupError),
          const SizedBox(height: 14),
          const _QuickActionsRow(),
          if (controller.location != null) ...<Widget>[
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Text(
                  l10n.tr('prayerTimes'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.tr('prayerDisplayFilter'),
                  onPressed: () => _openPrayerFilter(context, controller),
                  icon: const Icon(Icons.tune_rounded),
                ),
                IconButton(
                  tooltip: l10n.tr('copyTodaySchedule'),
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
                  onPressed: () => _sharePrayerSchedule(
                    context: context,
                    city: controller.location!.cityName,
                    prayers: visiblePrayers,
                    now: controller.now,
                  ),
                  icon: const Icon(Icons.share_rounded),
                ),
                Text(
                  DateFormat('EEE, dd MMM').format(controller.now),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...visiblePrayers.map(
              (prayer) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PrayerTimeCard(
                  prayer: prayer,
                  isNext: _isSamePrayer(prayer, controller.nextPrayer),
                  isCurrent: currentPrayerWindow?.prayer == prayer,
                  now: controller.now,
                  endsIn: currentPrayerWindow?.prayer == prayer
                      ? currentPrayerWindow?.endsIn
                      : null,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          IslamicEventsSection(now: controller.now),
          const SizedBox(height: 12),
          DailyQuranAyahsSection(translationLanguage: controller.appLanguage),
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
        .where((prayer) => visibleSet.contains(prayer.name))
        .toList();
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
      final next = prayers[index + 1];
      final isStarted = !now.isBefore(current.time);
      final notEnded = now.isBefore(next.time);
      if (isStarted && notEnded) {
        final remaining = next.time.difference(now);
        return _CurrentPrayerWindow(
          prayer: current,
          endsIn: remaining.isNegative ? Duration.zero : remaining,
        );
      }
    }

    return null;
  }

  void _openPrayerFilter(BuildContext context, AppController controller) {
    final l10n = context.l10n;
    final selected = controller.visiblePrayerNames.toSet();
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
    final l10n = context.l10n;
    final text = _buildPrayerScheduleText(
      context: context,
      city: city,
      prayers: prayers,
      now: now,
    );
    await Share.share(text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tr('scheduleShared'))));
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
}

class _CityHeader extends StatelessWidget {
  const _CityHeader({required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.location_on_rounded,
          color: Theme.of(context).colorScheme.secondary,
        ),
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
      ],
    );
  }
}

class _NextPrayerCard extends StatefulWidget {
  const _NextPrayerCard({required this.nextPrayer});

  final PrayerInfo? nextPrayer;

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
    final style = context.select<AppController, ThemeStyleOption>(
      (c) => c.themeStyle,
    );
    final prayerTimeFormat = DateFormat('hh:mm a');
    final scheme = Theme.of(context).colorScheme;
    final countdown = widget.nextPrayer == null
        ? Duration.zero
        : widget.nextPrayer!.time.difference(_now);
    final countdownLabel = l10n.tr('startsIn', <String, String>{
      'duration': _formatStableDuration(countdown),
    });

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: AppGradients.primaryFor(style),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.45)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: scheme.secondary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  l10n.tr('nextPrayer'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.nights_stay_rounded,
                  color: scheme.secondary.withValues(alpha: 0.95),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  constraints: const BoxConstraints(minWidth: 170),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    countdownLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
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
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PrayerTrackerScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.map_outlined,
            label: l10n.tr('quickMosques'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MosqueFinderScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.auto_stories_rounded,
            label: l10n.tr('quickAzkar'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AzkarScreen()),
              );
            },
          ),
        ),
      ],
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
          child: AppSurfaceCard(
            radius: 18,
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                Icon(widget.icon, color: scheme.primary),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
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
    required this.endsIn,
  });

  final PrayerInfo prayer;
  final bool isNext;
  final bool isCurrent;
  final DateTime now;
  final Duration? endsIn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextPrayerGradient = LinearGradient(
      colors: isDark
          ? <Color>[
              scheme.primary.withValues(alpha: 0.38),
              scheme.secondary.withValues(alpha: 0.2),
            ]
          : <Color>[
              scheme.secondary.withValues(alpha: 0.1),
              scheme.tertiary.withValues(alpha: 0.12),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final currentPrayerGradient = LinearGradient(
      colors: isDark
          ? <Color>[
              scheme.secondary.withValues(alpha: 0.36),
              scheme.tertiary.withValues(alpha: 0.3),
            ]
          : <Color>[
              scheme.primary.withValues(alpha: 0.2),
              scheme.secondary.withValues(alpha: 0.24),
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
      fontWeight: FontWeight.w700,
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
      child: AppSurfaceCard(
        gradient: isCurrent
            ? currentPrayerGradient
            : isNext
            ? nextPrayerGradient
            : null,
        backgroundColor: isNext || isCurrent
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
                    : isNext
                    ? scheme.tertiary.withValues(alpha: 0.65)
                    : scheme.outlineVariant.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      if (isNext)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondary.withValues(
                              alpha: isDark ? 0.14 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: scheme.secondary.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Text(
                            l10n.tr('nextPrayer'),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                      Icon(
                        icon,
                        size: 16,
                        color: isCurrent
                            ? scheme.secondary
                            : isNext
                            ? scheme.tertiary.withValues(alpha: 0.8)
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
                    style: Theme.of(context).textTheme.bodySmall,
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
                              color: scheme.secondary.withValues(alpha: 0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        )
                      : isNext
                      ? BoxDecoration(
                          color: scheme.secondary.withValues(
                            alpha: isDark ? 0.14 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: scheme.secondary.withValues(alpha: 0.22),
                          ),
                        )
                      : null,
                  child: Text(
                    DateFormat('hh:mm a').format(prayer.time),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isCurrent && isDark
                          ? Colors.white
                          : isCurrent
                          ? scheme.primary
                          : isNext && isDark
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
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
    );
  }

  String _formatStableDuration(Duration duration) {
    final safeDuration = duration.isNegative ? Duration.zero : duration;
    final hours = safeDuration.inHours;
    final minutes = safeDuration.inMinutes.remainder(60);
    final seconds = safeDuration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _CurrentPrayerWindow {
  const _CurrentPrayerWindow({required this.prayer, required this.endsIn});

  final PrayerInfo prayer;
  final Duration endsIn;
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
