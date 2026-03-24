import 'dart:io';

import 'package:flutter/foundation.dart';

class AdHelper {
  static const String _androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';

  static const String _androidReleaseBannerId =
      'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return kReleaseMode ? _androidReleaseBannerId : _androidTestBannerId;
    }
    throw UnsupportedError('Banner ads are configured for Android only.');
  }
}
