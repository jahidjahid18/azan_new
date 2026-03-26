import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/widgets/app_gradient_button.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/azkar/data/azkar_service.dart';
import 'package:azan_app/features/azkar/data/models/azkar_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final AzkarService _azkarService = AzkarService();
  late Future<Map<String, List<AzkarItem>>> _azkarFuture;
  String _selectedCategory = 'morning';

  @override
  void initState() {
    super.initState();
    _azkarFuture = _azkarService.loadAzkar();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('dailyAzkar'))),
      body: FutureBuilder<Map<String, List<AzkarItem>>>(
        future: _azkarFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text(l10n.tr('unableLoadAzkarData')));
          }

          final azkar = snapshot.data!;
          final items = azkar[_selectedCategory] ?? <AzkarItem>[];
          final counts = controller.azkarCountsForDateCategory(
            date: DateTime.now(),
            category: _selectedCategory,
          );

          final totalRequired = items.fold<int>(
            0,
            (sum, item) => sum + item.repeat,
          );
          final totalDone = items.fold<int>(
            0,
            (sum, item) => sum + (counts[item.id] ?? 0).clamp(0, item.repeat),
          );
          final progress = totalRequired == 0 ? 0.0 : totalDone / totalRequired;

          return ListView(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 20 + bottomPadding),
            children: <Widget>[
              Text(
                l10n.tr('morningEveningRemembrance'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'morning',
                    label: Text(l10n.tr('morning')),
                  ),
                  ButtonSegment<String>(
                    value: 'evening',
                    label: Text(l10n.tr('evening')),
                  ),
                ],
                selected: <String>{_selectedCategory},
                onSelectionChanged: (selection) {
                  setState(() => _selectedCategory = selection.first);
                },
              ),
              const SizedBox(height: 10),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${l10n.tr(_selectedCategory)} ${l10n.tr('progress')}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tr('completedToday', <String, String>{
                        'percent': '${(progress * 100).round()}',
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(items.length, (index) {
                final item = items[index];
                final current = (counts[item.id] ?? 0).clamp(0, item.repeat);
                final isComplete = current >= item.repeat;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == items.length - 1 ? 0 : 8,
                  ),
                  child: AppSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          item.text,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                height: 1.7,
                                fontFamily: 'NotoNaskhArabic',
                                fontSize: 26,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Text(
                              l10n.tr('countProgress', <String, String>{
                                'current': '$current',
                                'total': '${item.repeat}',
                              }),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 42,
                              child: AppGradientButton(
                                onPressed: isComplete
                                    ? null
                                    : () async {
                                        await context
                                            .read<AppController>()
                                            .incrementAzkarCount(
                                              date: DateTime.now(),
                                              category: _selectedCategory,
                                              itemId: item.id,
                                              maxCount: item.repeat,
                                            );
                                      },
                                icon: Icons.add_rounded,
                                label: isComplete
                                    ? l10n.tr('done')
                                    : l10n.tr('count'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AppGradientButton(
                  onPressed: () async {
                    await context.read<AppController>().resetAzkarCategory(
                      date: DateTime.now(),
                      category: _selectedCategory,
                    );
                  },
                  icon: Icons.restart_alt_rounded,
                  label: l10n.tr('resetToday'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
