import 'package:azan_app/app.dart';
import 'package:azan_app/core/services/hive_service.dart';
import 'package:azan_app/core/services/location_service.dart';
import 'package:azan_app/core/services/notification_service.dart';
import 'package:azan_app/core/services/prayer_service.dart';
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
      create: (_) => AppController(
        hiveService: HiveService(),
        locationService: LocationService(),
        prayerService: PrayerService(),
        notificationService: NotificationService(),
        dailyContentService: DailyContentService(),
      )..initialize(),
      child: const AzanApp(),
    ),
  );
}
