# Third-Party Attribution and Licensing

This app includes open-source libraries and data sources.  
Please keep this file with releases and store listings.

## 1) Core Prayer Time and Qibla

- `adhan` (Dart package)  
  - Use: Prayer time calculations (offline/local)
  - License: MIT
  - Source: https://pub.dev/packages/adhan

- `flutter_qiblah` (Flutter package)  
  - Use: Qibla direction using device sensors
  - License: MIT
  - Source: https://pub.dev/packages/flutter_qiblah

- `hijri` (Dart package)  
  - Use: Hijri date conversion/display
  - License: BSD-style license
  - Source: https://pub.dev/packages/hijri

## 2) Quran Text and Translation Data (Local JSON)

- Quran JSON data and translation format reference  
  - Repository: `semarketir/quranjson`
  - License: MIT
  - Source: https://github.com/semarketir/quranjson

- In-app files (examples):
  - `assets/data/quran_ar.json`
  - `assets/data/quran_en_translation.json`
  - `assets/data/quran_transliteration_en.json`
  - `assets/data/quran_translations/*.json`

## 3) Quran Audio Streaming/Caching

- EveryAyah file hosting endpoint (used by app):
  - https://everyayah.com/data/
  - App code reference: `lib/features/audio/services/quran_audio_service.dart`

Note:
- Audio is fetched remotely on first play, then cached locally.
- Before commercial distribution, confirm current EveryAyah usage terms/permission directly with provider.

## 4) Maps and Nearby Mosque Data

- OpenStreetMap map tiles/data attribution required
  - Copyright & attribution page:
    - https://www.openstreetmap.org/copyright

- Overpass API (public OSM query endpoints) used for nearby mosque search
  - App code reference: `lib/features/mosque/data/mosque_service.dart`
  - Respect public endpoint usage policies and rate limits.

## 5) Google Services in Project

- `google_maps_flutter` and `google_mobile_ads` are included as dependencies.
- Google services can involve billing/terms depending on enabled features and traffic.
- Google Maps pricing overview:
  - https://developers.google.com/maps/billing-and-pricing/overview

## 6) Your Responsibility Before Production Release

- Keep attribution visible where required (especially OSM).
- Include third-party licenses in app/legal docs or store listing as needed.
- Verify external data/audio providers' latest terms before large-scale/commercial launch.

