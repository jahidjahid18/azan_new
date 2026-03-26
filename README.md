# Azan - Offline Islamic Prayer App

Lightweight Android-first Islamic app focused on speed, offline usage, and
daily engagement.

## Core Principles
- No login
- No backend
- Offline-first
- Banner ads only (Home + Settings)
- Fast startup and minimal background work

## Features

### Prayer & Qibla
- GPS location with permission flow
- Local prayer times via `adhan`
- Next prayer countdown
- Automatic prohibited prayer windows (Makruh times) with active highlight:
  - After Fajr -> Sunrise + 15 min
  - Zenith (Dhuhr - 10 min -> Dhuhr)
  - After Asr -> Maghrib
- Settings toggle: show/hide prohibited times in the prayer list
- Qibla compass via `flutter_qiblah`
- Local prayer notifications (silent or azan sound)

### Quran (Offline JSON)
- Full Quran Arabic text from local file:
  - `assets/data/quran_ar.json`
- 114 Surah list
- Surah reader screen with:
  - Ayah number
  - Arabic text
  - Next/Previous surah navigation

### Quran Audio Player
- Ayah-level recitation playback in Quran reader
- Play / Pause / Previous / Next ayah
- Basic reciter selection
- Audio is downloaded and cached locally after first play
- Uses lightweight `just_audio` + `flutter_cache_manager`

### Prayer Tracker
- Mark daily prayers as completed
- Daily completion progress
- Weekly completion summary (last 7 days)
- Stored locally in Hive (`prayer_tracker` key)

### Tasbih Counter
- Big tap-to-increment button
- Reset button
- Last count saved in Hive

### Daily Ayah / Hadith
- Local dataset:
  - `assets/data/daily_content.json`
- Rotates daily from local date (no API)
- Card shown on Home screen

### Hijri Calendar
- Current Hijri date shown on Home
- Ramadan countdown shown below Hijri date

### Navigation
- Bottom navigation with:
  - Home
  - Quran
  - Tasbih
  - Qibla
  - Settings
- Tracker and Mosque Finder are accessible from Home quick actions.

### Mosque Finder
- Nearby mosque search around current location
- Google Maps view with markers
- Tap marker info to open in external maps app
- Data source: Overpass public API (no backend required)

### Theme Modes
- Light / Dark / System mode
- Saved locally and restored at startup

## Project Structure
```text
lib/
  main.dart
  app.dart
  core/
    constants/
    enums/
    models/
    services/
    state/
    utils/
  features/
    home/presentation/
    quran/
      data/
      presentation/
    audio/
      models/
      services/
      widgets/
    tasbih/presentation/
    tracker/presentation/
    mosque/
      data/
      presentation/
    theme/
    daily/
      data/
      presentation/
    calendar/presentation/
    qibla/presentation/
    settings/presentation/
  ads/
assets/
  data/
    quran_ar.json
    daily_content.json
```

## JSON Structure

### Quran JSON (`assets/data/quran_ar.json`)
```json
{
  "surahs": [
    {
      "number": 1,
      "name_ar": "الفاتحة",
      "name_en": "The Opening",
      "ayah_count": 7,
      "ayahs": [
        { "number": 1, "text": "..." }
      ]
    }
  ]
}
```

### Daily Content JSON (`assets/data/daily_content.json`)
```json
{
  "items": [
    {
      "type": "ayah",
      "title": "Patience and Prayer",
      "text": "...",
      "reference": "Quran 2:153"
    }
  ]
}
```

## Android Permissions
Configured in `android/app/src/main/AndroidManifest.xml`:
- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `POST_NOTIFICATIONS`
- `RECEIVE_BOOT_COMPLETED`
- `VIBRATE`

## Google Maps Setup (Mosque Finder)
Add your Android Maps key in:
`android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```

## AdMob Setup
1. Replace release banner unit ID in:
   - `lib/ads/ad_helper.dart`
2. Replace app ID in:
   - `android/app/src/main/AndroidManifest.xml`
   - `com.google.android.gms.ads.APPLICATION_ID`

## Optional Azan Sound Setup
Place custom azan audio at:
```text
android/app/src/main/res/raw/azan.mp3
```

## Run
```bash
flutter pub get
flutter run
```

## Build APK
```bash
flutter build apk --debug
flutter build apk --release
```
