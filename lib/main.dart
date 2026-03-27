import 'package:azan_app/app.dart';
import 'package:azan_app/core/services/hive_service.dart';
import 'package:azan_app/core/services/location_service.dart';
import 'package:azan_app/core/services/location_sqlite_service.dart';
import 'package:azan_app/core/services/notification_service.dart';
import 'package:azan_app/core/services/prayer_notification_scheduler.dart';
import 'package:azan_app/core/services/prayer_service.dart';
import 'package:azan_app/core/services/prayer_alarm_service.dart';
import 'package:azan_app/core/services/quran_reading_sqlite_service.dart';
import 'package:azan_app/core/services/streak_service.dart';
import 'package:azan_app/core/services/tracking_service.dart';
import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/features/daily/data/daily_content_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final prayerService = PrayerService();
        final notificationService = NotificationService();
        final hiveService = HiveService();
        return AppController(
          hiveService: hiveService,
          locationService: LocationService(),
          locationSqliteService: LocationSqliteService(),
          quranReadingSqliteService: QuranReadingSqliteService(),
          prayerService: prayerService,
          notificationService: notificationService,
          prayerNotificationScheduler: PrayerNotificationScheduler(
            prayerService: prayerService,
            notificationService: notificationService,
            prayerAlarmService: PrayerAlarmService(),
          ),
          dailyContentService: DailyContentService(),
          streakService: StreakService(hiveService: hiveService),
          trackingService: TrackingService(hiveService: hiveService),
        )..initialize();
      },
      child: const AzanApp(),
    ),
  );
}
