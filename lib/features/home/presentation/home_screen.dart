import 'dart:async';

import 'package:azan_app/core/models/prayer_info.dart';
import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/theme/app_theme.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/azkar/presentation/azkar_screen.dart';
import 'package:azan_app/features/calendar/presentation/islamic_events_section.dart';
import 'package:azan_app/features/daily/presentation/daily_content_card.dart';
import 'package:azan_app/features/mosque/presentation/mosque_finder_screen.dart';
import 'package:azan_app/features/tracker/presentation/prayer_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
                  ),
                  icon: const Icon(Icons.copy_all_rounded),
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
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          IslamicEventsSection(now: controller.now),
          const SizedBox(height: 12),
          if (controller.dailyContent != null)
            DailyContentCard(item: controller.dailyContent!),
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
  }) async {
    final l10n = context.l10n;
    final formatter = DateFormat('hh:mm a');
    final lines = <String>[
      '${l10n.tr('prayerTimes')} - $city',
      DateFormat('EEE, dd MMM yyyy').format(DateTime.now()),
      '',
      ...prayers.map(
        (p) => '${l10n.prayerName(p.name)}: ${formatter.format(p.time)}',
      ),
    ];
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tr('scheduleCopied'))));
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
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppThemeColors.gold.withValues(alpha: 0.45)),
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
                  color: AppThemeColors.gold.withValues(alpha: 0.95),
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
                    color: AppThemeColors.gold.withValues(alpha: 0.22),
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

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AppSurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Theme.of(context).cardTheme.color,
          child: Column(
            children: <Widget>[
              Icon(icon, color: scheme.primary),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerTimeCard extends StatelessWidget {
  const _PrayerTimeCard({required this.prayer, required this.isNext});

  final PrayerInfo prayer;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (prayer.name.toLowerCase()) {
      'fajr' => Icons.nights_stay_rounded,
      'dhuhr' => Icons.wb_sunny_rounded,
      'asr' => Icons.wb_twilight_rounded,
      'maghrib' => Icons.wb_twilight_rounded,
      'isha' => Icons.dark_mode_rounded,
      _ => Icons.access_time_rounded,
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      child: AppSurfaceCard(
        backgroundColor: isNext ? const Color(0xFFEFFBF3) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: isNext ? scheme.secondary : const Color(0xFFCBD5E1),
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
                      Icon(
                        icon,
                        size: 16,
                        color: isNext ? scheme.secondary : scheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.prayerName(prayer.name),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
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
            Text(
              DateFormat('hh:mm a').format(prayer.time),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
