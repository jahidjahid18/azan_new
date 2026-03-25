import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class IslamicEventsSection extends StatefulWidget {
  const IslamicEventsSection({super.key, required this.now});

  final DateTime now;

  @override
  State<IslamicEventsSection> createState() => _IslamicEventsSectionState();
}

class _IslamicEventsSectionState extends State<IslamicEventsSection> {
  int _selectedDays = 180;
  DateTime? _cachedDate;
  List<IslamicEventModel> _cachedEvents = <IslamicEventModel>[];

  static const List<int> _filterDayOptions = <int>[30, 60, 90, 180, 365];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = DateTime(widget.now.year, widget.now.month, widget.now.day);
    final allEvents = _eventsForDate(today);
    final filteredEvents = IslamicEventsFilter.filterByDays(
      events: allEvents,
      now: today,
      selectedDays: _selectedDays,
    );

    final chipEvents = filteredEvents
        .where((event) => event.showInChips)
        .toList(growable: false);
    final listEvents = filteredEvents
        .where((event) => event.showInMainList)
        .toList(growable: false);

    if (chipEvents.isEmpty && listEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '${l10n.tr('upcomingEvens')} (${_selectedDays.toString()} ${l10n.tr('daysShort')})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: l10n.tr('filterEvents'),
              onPressed: _openFilterBottomSheet,
              icon: const Icon(Icons.filter_list_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (chipEvents.isNotEmpty) ...<Widget>[
          SizedBox(
            height: 66,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chipEvents.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final event = chipEvents[index];
                return _EventChip(
                  title: _eventLabel(context, event.type),
                  days: event.eventDate.difference(today).inDays,
                  color: event.chipColor,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (listEvents.isNotEmpty)
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${l10n.tr('upcomingEvens')} (${_selectedDays.toString()} ${l10n.tr('daysShort')})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...listEvents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final event = entry.value;
                  final days = event.eventDate.difference(today).inDays;
                  return _EventListRow(
                    title: _eventLabel(context, event.type),
                    days: days,
                    isLast: index == listEvents.length - 1,
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  List<IslamicEventModel> _eventsForDate(DateTime today) {
    if (_cachedDate == today && _cachedEvents.isNotEmpty) {
      return _cachedEvents;
    }
    _cachedDate = today;
    _cachedEvents = _IslamicEventsCalculator.calculate(today);
    return _cachedEvents;
  }

  String _eventLabel(BuildContext context, IslamicEventType type) {
    final l10n = context.l10n;
    return switch (type) {
      IslamicEventType.ramadan => l10n.tr('ramadanLabel'),
      IslamicEventType.eidAlFitr => l10n.tr('eidAlFitrLabel'),
      IslamicEventType.eidAlAdha => l10n.tr('eidAlAdhaLabel'),
      IslamicEventType.ashura => l10n.tr('ashuraLabel'),
      IslamicEventType.jumuah => l10n.tr('jumuahLabel'),
    };
  }

  Future<void> _openFilterBottomSheet() async {
    final l10n = context.l10n;
    var tempSelected = _selectedDays;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setBottomState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + MediaQuery.of(sheetContext).viewPadding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.tr('filterEvents'),
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  RadioGroup<int>(
                    groupValue: tempSelected,
                    onChanged: (value) {
                      if (value == null) return;
                      setBottomState(() => tempSelected = value);
                    },
                    child: Column(
                      children: _filterDayOptions
                          .asMap()
                          .entries
                          .map((entry) {
                            final option = entry.value;
                            return Column(
                              children: <Widget>[
                                RadioListTile<int>(
                                  contentPadding: EdgeInsets.zero,
                                  value: option,
                                  secondary: const Icon(
                                    Icons.calendar_month_rounded,
                                  ),
                                  title: Text(
                                    '$option ${l10n.tr('daysShort')}',
                                  ),
                                ),
                                if (entry.key != _filterDayOptions.length - 1)
                                  Divider(
                                    height: 1,
                                    color: Theme.of(sheetContext)
                                        .colorScheme
                                        .outlineVariant
                                        .withValues(alpha: 0.35),
                                  ),
                              ],
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text(l10n.tr('cancel')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() => _selectedDays = tempSelected);
                            Navigator.of(sheetContext).pop();
                          },
                          child: Text(l10n.tr('apply')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

enum IslamicEventType { ramadan, eidAlFitr, eidAlAdha, ashura, jumuah }

/// Example event model used by the filtering system.
class IslamicEventModel {
  const IslamicEventModel({
    required this.type,
    required this.eventDate,
    required this.chipColor,
    this.showInChips = true,
    this.showInMainList = true,
  });

  final IslamicEventType type;
  final DateTime eventDate;
  final Color chipColor;
  final bool showInChips;
  final bool showInMainList;
}

class IslamicEventsFilter {
  const IslamicEventsFilter._();

  /// Filters events by selected day window.
  static List<IslamicEventModel> filterByDays({
    required List<IslamicEventModel> events,
    required DateTime now,
    required int selectedDays,
  }) {
    final limit = now.add(Duration(days: selectedDays));
    final filtered = events
        .where(
          (event) =>
              event.eventDate.isAfter(now) && event.eventDate.isBefore(limit),
        )
        .toList();
    filtered.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return filtered;
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({
    required this.title,
    required this.days,
    required this.color,
  });

  final String title;
  final int days;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.tr('eventInDays', <String, String>{'days': '$days'}),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _EventListRow extends StatelessWidget {
  const _EventListRow({
    required this.title,
    required this.days,
    this.isLast = false,
  });

  final String title;
  final int days;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            l10n.tr('eventInDays', <String, String>{'days': '$days'}),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicEventsCalculator {
  static List<IslamicEventModel> calculate(DateTime now) {
    final hijri = HijriCalendar.fromDate(now);
    return <IslamicEventModel>[
      IslamicEventModel(
        type: IslamicEventType.ramadan,
        eventDate: _hijriToDate(hijri, now, month: 9, day: 1),
        chipColor: const Color(0xFFE8F7EF),
      ),
      IslamicEventModel(
        type: IslamicEventType.eidAlFitr,
        eventDate: _hijriToDate(hijri, now, month: 10, day: 1),
        chipColor: const Color(0xFFEFF5FF),
      ),
      IslamicEventModel(
        type: IslamicEventType.eidAlAdha,
        eventDate: _hijriToDate(hijri, now, month: 12, day: 10),
        chipColor: const Color(0xFFFFF4E8),
      ),
      IslamicEventModel(
        type: IslamicEventType.ashura,
        eventDate: _hijriToDate(hijri, now, month: 1, day: 10),
        chipColor: const Color(0xFFFCEFF2),
        showInChips: false,
      ),
      IslamicEventModel(
        type: IslamicEventType.jumuah,
        eventDate: _nextJumuahDate(now),
        chipColor: const Color(0xFFF6F0FF),
        showInMainList: false,
      ),
    ];
  }

  static DateTime _nextJumuahDate(DateTime now) {
    const friday = DateTime.friday;
    final delta = (friday - now.weekday + 7) % 7;
    return now.add(Duration(days: delta == 0 ? 7 : delta));
  }

  static DateTime _hijriToDate(
    HijriCalendar hijri,
    DateTime now, {
    required int month,
    required int day,
  }) {
    final currentYearDate = hijri.hijriToGregorian(hijri.hYear, month, day);
    final currentYearTarget = DateTime(
      currentYearDate.year,
      currentYearDate.month,
      currentYearDate.day,
    );
    if (currentYearTarget.isAfter(now)) {
      return currentYearTarget;
    }

    final nextYearDate = hijri.hijriToGregorian(hijri.hYear + 1, month, day);
    return DateTime(nextYearDate.year, nextYearDate.month, nextYearDate.day);
  }
}
