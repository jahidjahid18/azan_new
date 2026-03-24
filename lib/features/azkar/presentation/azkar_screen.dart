import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/widgets/glass_card.dart';
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
  String _category = 'morning';

  @override
  void initState() {
    super.initState();
    _azkarFuture = _azkarService.loadAzkarByCategory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<AzkarItem>>>(
      future: _azkarFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Azkar')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Unable to load Azkar content. Please restart the app.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final allData = snapshot.data!;
        final items = allData[_category] ?? const <AzkarItem>[];
        final controller = context.read<AppController>();
        final counts = controller.azkarCountsForDateCategory(
          DateTime.now(),
          _category,
        );
        final favoriteIds = controller.azkarFavorites.map((e) => e.id).toSet();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daily Azkar'),
            actions: <Widget>[
              TextButton(
                onPressed: items.isEmpty
                    ? null
                    : () async {
                        await controller.resetAzkarCategory(
                          date: DateTime.now(),
                          category: _category,
                        );
                        if (!mounted) return;
                        setState(() {});
                      },
                child: const Text('Reset All'),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: SegmentedButton<String>(
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: 'morning',
                      icon: Icon(Icons.wb_sunny_outlined),
                      label: Text('Morning'),
                    ),
                    ButtonSegment<String>(
                      value: 'evening',
                      icon: Icon(Icons.nightlight_round),
                      label: Text('Evening'),
                    ),
                  ],
                  selected: <String>{_category},
                  onSelectionChanged: (value) {
                    setState(() {
                      _category = value.first;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final completed = counts[item.id] ?? 0;
                    final progress = (completed / item.repeat).clamp(0.0, 1.0);
                    final isFavorite = favoriteIds.contains(item.id);

                    return GlassCard(
                      borderRadius: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  item.source,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              IconButton(
                                tooltip: isFavorite
                                    ? 'Remove favorite'
                                    : 'Save favorite',
                                onPressed: () async {
                                  await controller.toggleAzkarFavorite(
                                    id: item.id,
                                    category: _category,
                                    text: item.text,
                                    source: item.source,
                                    repeat: item.repeat,
                                  );
                                  if (!mounted) return;
                                  setState(() {});
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.text,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(height: 1.6),
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(value: progress),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Text('Count: $completed / ${item.repeat}'),
                              const Spacer(),
                              FilledButton.tonalIcon(
                                onPressed: completed >= item.repeat
                                    ? null
                                    : () async {
                                        await controller.incrementAzkarCount(
                                          date: DateTime.now(),
                                          category: _category,
                                          itemId: item.id,
                                          maxCount: item.repeat,
                                        );
                                        if (!mounted) return;
                                        setState(() {});
                                      },
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Recite'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
