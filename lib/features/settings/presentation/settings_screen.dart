import 'package:azan_app/core/enums/calculation_method_option.dart';
import 'package:azan_app/core/enums/notification_sound_mode.dart';
import 'package:azan_app/core/localization/app_language.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/widgets/app_gradient_button.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/settings/presentation/contact_developer_screen.dart';
import 'package:azan_app/features/settings/presentation/faq_screen.dart';
import 'package:azan_app/features/theme/theme_mode_option.dart';
import 'package:azan_app/features/theme/theme_style_option.dart';
import 'package:file_picker/file_picker.dart';
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
    final l10n = context.l10n;
    final location = controller.location;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomPadding),
      children: <Widget>[
        _SectionTitle(
          title: l10n.tr('location'),
          subtitle: l10n.tr('locationSub'),
          icon: Icons.location_on_rounded,
        ),
        const SizedBox(height: 8),
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                location == null
                    ? l10n.tr('noSavedLocation')
                    : '${location.cityName}\n${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: AppGradientButton(
                  onPressed: controller.isBusy
                      ? null
                      : () async {
                          final message = await context
                              .read<AppController>()
                              .refreshLocationFromGps();
                          if (!mounted) return;
                          _showSnack(
                            message ?? l10n.tr('locationUpdatedFromGps'),
                          );
                        },
                  icon: Icons.my_location_rounded,
                  label: l10n.tr('useCurrentLocation'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.tr('latitude'),
                  hintText: 'e.g. 3.1390',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.tr('longitude'),
                  hintText: 'e.g. 101.6869',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: l10n.tr('cityNameOptional'),
                  hintText: l10n.tr('leaveBlankAutoDetect'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.isBusy
                      ? null
                      : () async {
                          final message = await context
                              .read<AppController>()
                              .saveManualLocation(
                                latitudeText: _latitudeController.text,
                                longitudeText: _longitudeController.text,
                                cityText: _cityController.text,
                              );
                          if (!mounted) return;
                          _showSnack(message ?? l10n.tr('manualLocationSaved'));
                        },
                  icon: const Icon(Icons.save_rounded),
                  label: Text(l10n.tr('saveManualLocation')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSupportSection(context, l10n),
        const SizedBox(height: 16),
        _SectionTitle(
          title: l10n.tr('notifications'),
          subtitle: l10n.tr('notificationsSub'),
          icon: Icons.notifications_active_rounded,
        ),
        const SizedBox(height: 8),
        AppSurfaceCard(
          child: Column(
            children: <Widget>[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.tr('enablePrayerNotifications')),
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
                  segments: <ButtonSegment<NotificationSoundMode>>[
                    ButtonSegment<NotificationSoundMode>(
                      value: NotificationSoundMode.notificationOnly,
                      label: Text(
                        l10n.notificationSoundLabel(
                          NotificationSoundMode.notificationOnly,
                        ),
                      ),
                    ),
                    ButtonSegment<NotificationSoundMode>(
                      value: NotificationSoundMode.azanSound,
                      label: Text(
                        l10n.notificationSoundLabel(
                          NotificationSoundMode.azanSound,
                        ),
                      ),
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
                  l10n.tr('azanModeRequiresFile'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitle(
          title: l10n.tr('prayerCalculation'),
          subtitle: l10n.tr('prayerCalculationSub'),
          icon: Icons.calculate_rounded,
        ),
        const SizedBox(height: 8),
        AppSurfaceCard(
          child: DropdownButtonFormField<CalculationMethodOption>(
            initialValue: controller.settings.calculationMethod,
            decoration: InputDecoration(
              labelText: l10n.tr('calculationMethod'),
            ),
            items: CalculationMethodOption.values
                .map(
                  (method) => DropdownMenuItem<CalculationMethodOption>(
                    value: method,
                    child: Text(l10n.calculationMethodLabel(method)),
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
        const SizedBox(height: 16),
        _SectionTitle(
          title: l10n.tr('language'),
          subtitle: l10n.tr('languageSub'),
          icon: Icons.language_rounded,
        ),
        const SizedBox(height: 8),
        AppSurfaceCard(
          child: DropdownButtonFormField<AppLanguage>(
            initialValue: controller.appLanguage,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.tr('appLanguage')),
            items: appLanguagesAlphabetical
                .map(
                  (language) => DropdownMenuItem<AppLanguage>(
                    value: language,
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(language.englishName)),
                        const SizedBox(width: 12),
                        Text(language.nativeName),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null) return;
              await context.read<AppController>().setAppLanguage(value);
            },
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitle(
          title: l10n.tr('appearance'),
          subtitle: l10n.tr('appearanceSub'),
          icon: Icons.palette_rounded,
        ),
        const SizedBox(height: 8),
        AppSurfaceCard(
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<ThemeModeOption>(
                initialValue: controller.themeMode,
                decoration: InputDecoration(labelText: l10n.tr('themeMode')),
                items: ThemeModeOption.values
                    .map(
                      (option) => DropdownMenuItem<ThemeModeOption>(
                        value: option,
                        child: Text(l10n.themeModeLabel(option)),
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
                decoration: InputDecoration(labelText: l10n.tr('themeStyle')),
                items: kSelectableThemeStyles
                    .map(
                      (option) => DropdownMenuItem<ThemeStyleOption>(
                        value: option,
                        child: Text(l10n.themeStyleLabel(option)),
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
        const SizedBox(height: 16),
        _SectionTitle(
          title: l10n.tr('dataBackup'),
          subtitle: l10n.tr('dataBackupSub'),
          icon: Icons.data_saver_on_rounded,
        ),
        const SizedBox(height: 8),
        AppSurfaceCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    final appController = context.read<AppController>();
                    final backupExportedText = context.l10n.tr(
                      'backupExported',
                    );
                    final defaultName =
                        'azan_backup_${DateTime.now().toIso8601String().split('T').first}.json';
                    final outputPath = await FilePicker.platform.saveFile(
                      dialogTitle: l10n.tr('saveBackupFile'),
                      fileName: defaultName,
                      type: FileType.custom,
                      allowedExtensions: const <String>['json'],
                    );

                    if (outputPath == null) return;
                    final message = await appController.exportBackup(
                      filePath: outputPath,
                    );
                    if (!mounted) return;
                    _showSnack(message ?? backupExportedText);
                  },
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(l10n.tr('export')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final appController = context.read<AppController>();
                    final backupRestoredText = context.l10n.tr(
                      'backupRestored',
                    );
                    final result = await FilePicker.platform.pickFiles(
                      dialogTitle: l10n.tr('selectBackupFile'),
                      type: FileType.custom,
                      allowedExtensions: const <String>['json'],
                    );

                    final filePath = result?.files.single.path;
                    if (filePath == null) return;
                    final message = await appController.importBackup(
                      filePath: filePath,
                    );
                    if (!mounted) return;
                    _showSnack(message ?? backupRestoredText);
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text(l10n.tr('restore')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionTitle(
          title: l10n.tr('support'),
          subtitle: l10n.tr('supportSub'),
          icon: Icons.support_agent_rounded,
        ),
        const SizedBox(height: 8),
        AppSurfaceCard(
          child: Column(
            children: <Widget>[
              _NavigationActionButton(
                icon: Icons.help_center_rounded,
                title: l10n.tr('helpFaqButton'),
                subtitle: l10n.tr('helpFaqButtonSub'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const FaqScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
              _NavigationActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                title: l10n.tr('contactDeveloperButton'),
                subtitle: l10n.tr('contactDeveloperButtonSub'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ContactDeveloperScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NavigationActionButton extends StatelessWidget {
  const _NavigationActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.22),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
