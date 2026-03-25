enum NotificationSoundMode { notificationOnly, azanSound }

extension NotificationSoundModeX on NotificationSoundMode {
  String get key => switch (this) {
    NotificationSoundMode.notificationOnly => 'notification_only',
    NotificationSoundMode.azanSound => 'azan_sound',
  };

  String get label => switch (this) {
    NotificationSoundMode.notificationOnly => 'Notification only',
    NotificationSoundMode.azanSound => 'Azan sound',
  };

  static NotificationSoundMode fromKey(String? value) {
    return NotificationSoundMode.values.firstWhere(
      (mode) => mode.key == value,
      orElse: () => NotificationSoundMode.notificationOnly,
    );
  }
}
