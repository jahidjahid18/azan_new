import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/widgets/glass_card.dart';
import 'package:azan_app/features/theme/theme_mode_option.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final location = controller.location;
    final selectedStyle = controller.themeStyle;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _SectionCard(
          title: 'Location',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                location == null
                    ? 'No saved location'
                    : '${location.cityName}\n${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: controller.isBusy
                    ? null
                    : () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final appController = context.read<AppController>();
                        final message = await appController
                            .refreshLocationFromGps();
                        if (!mounted) return;
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              message ?? 'Location updated from GPS.',
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Use current location'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'e.g. 3.1390',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'e.g. 101.6869',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City name (optional)',
                  hintText: 'Leave blank to auto-detect',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.isBusy
                    ? null
                    : () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final appController = context.read<AppController>();
                        final message = await appController.saveManualLocation(
                          latitudeText: _latitudeController.text,
                          longitudeText: _longitudeController.text,
                          cityText: _cityController.text,
                        );
                        if (!mounted) return;
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(message ?? 'Manual location saved.'),
                          ),
                        );
                      },
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save manual location'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Notifications',
          child: Column(
            children: <Widget>[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable prayer notifications'),
                value: controller.settings.notificationsEnabled,
                onChanged: (value) async {
                  await context.read<AppController>().setNotificationsEnabled(
                    value,
                  );
                },
              ),
              if (controller.settings.notificationsEnabled) ...<Widget>[
                const SizedBox(height: 8),
                SegmentedButton<NotificationSoundMode>(
                  showSelectedIcon: false,
                  segments: const <ButtonSegment<NotificationSoundMode>>[
                    ButtonSegment<NotificationSoundMode>(
                      value: NotificationSoundMode.notificationOnly,
                      label: Text('Notification only'),
                    ),
                    ButtonSegment<NotificationSoundMode>(
                      value: NotificationSoundMode.azanSound,
                      label: Text('Azan sound'),
                    ),
                  ],
                  selected: <NotificationSoundMode>{
                    controller.settings.notificationSoundMode,
                  },
                  onSelectionChanged: (selection) async {
                    final selectedMode = selection.first;
                    await context
                        .read<AppController>()
                        .setNotificationSoundMode(selectedMode);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Azan mode requires `android/app/src/main/res/raw/azan.mp3`.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Smart reminders: 15 minutes before prayer and gentle tracker check-in after prayer.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Prayer Calculation Method',
          child: DropdownButtonFormField<CalculationMethodOption>(
            initialValue: controller.settings.calculationMethod,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Method',
            ),
            items: CalculationMethodOption.values
                .map(
                  (method) => DropdownMenuItem<CalculationMethodOption>(
                    value: method,
                    child: Text(method.label),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null) return;
              await context.read<AppController>().updateCalculationMethod(
                value,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Appearance',
          child: Column(
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ThemeStyleOption.values
                    .map((option) {
                      final selected = option == selectedStyle;
                      return _ThemePreviewChip(
                        label: option.label,
                        selected: selected,
                        colors: _stylePreviewColors(option),
                        onTap: () async {
                          await context.read<AppController>().setThemeStyle(
                            option,
                          );
                        },
                      );
                    })
                    .toList(growable: false),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<ThemeModeOption>(
                initialValue: controller.themeMode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Theme mode',
                ),
                items: ThemeModeOption.values
                    .map(
                      (option) => DropdownMenuItem<ThemeModeOption>(
                        value: option,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) async {
                  if (value == null) return;
                  await context.read<AppController>().setThemeMode(value);
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<ThemeStyleOption>(
                initialValue: controller.themeStyle,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Theme style',
                ),
                items: ThemeStyleOption.values
                    .map(
                      (option) => DropdownMenuItem<ThemeStyleOption>(
                        value: option,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) async {
                  if (value == null) return;
                  await context.read<AppController>().setThemeStyle(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Prayer Time Adjustments',
          child: Column(
            children: <Widget>[
              Text(
                'Adjust notification time per prayer (-20 to +20 minutes).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ...<String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((
                prayer,
              ) {
                final value = controller.prayerOffsetsMinutes[prayer] ?? 0;
                return _PrayerOffsetRow(
                  prayerName: prayer,
                  minutes: value,
                  onChanged: (nextValue) async {
                    await context.read<AppController>().setPrayerOffsetMinutes(
                      prayerName: prayer,
                      minutes: nextValue,
                    );
                  },
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Backup and Restore',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Export all local app data to JSON and restore later.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.isBusy
                          ? null
                          : () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );
                              final appController = context
                                  .read<AppController>();
                              final message = await appController
                                  .exportLocalBackup();
                              if (!mounted) return;
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    message ??
                                        'Backup exported. Check app documents folder.',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Export'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: controller.isBusy
                          ? null
                          : () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );
                              final appController = context
                                  .read<AppController>();
                              final message = await appController
                                  .importLocalBackup();
                              if (!mounted) return;
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    message ?? 'Backup imported successfully.',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Import'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _stylePreviewColors(ThemeStyleOption option) {
    return switch (option) {
      ThemeStyleOption.glassBlue => const <Color>[
        Color(0xFFB4D4FF),
        Color(0xFF2A78F8),
      ],
      ThemeStyleOption.emerald => const <Color>[
        Color(0xFFA7E5CB),
        Color(0xFF198A66),
      ],
      ThemeStyleOption.sunset => const <Color>[
        Color(0xFFFFC09E),
        Color(0xFFE06B2E),
      ],
      ThemeStyleOption.monochrome => const <Color>[
        Color(0xFFC6D2DC),
        Color(0xFF556070),
      ],
    };
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ThemePreviewChip extends StatelessWidget {
  const _ThemePreviewChip({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withValues(alpha: 0.35),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(colors: colors),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

class _PrayerOffsetRow extends StatelessWidget {
  const _PrayerOffsetRow({
    required this.prayerName,
    required this.minutes,
    required this.onChanged,
  });

  final String prayerName;
  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(prayerName),
            const Spacer(),
            Text('${minutes >= 0 ? '+' : ''}$minutes min'),
          ],
        ),
        Slider(
          min: -20,
          max: 20,
          divisions: 40,
          value: minutes.toDouble(),
          onChanged: (value) => onChanged(value.round()),
        ),
      ],
    );
  }
}
