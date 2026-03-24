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
      ],
    );
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
