package com.example.azan_app

import android.media.AudioManager
import android.media.ToneGenerator
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val PRAYER_ALARM_CHANNEL = "azan_app/prayer_alarm"
        private const val TASBIH_FEEDBACK_CHANNEL = "azan_app/tasbih_feedback"
    }

    private var tasbihToneGenerator: ToneGenerator? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PRAYER_ALARM_CHANNEL,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "schedulePrayerAlarms" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: true
                        if (!enabled) {
                            PrayerAlarmScheduler.cancelAll(applicationContext)
                            result.success(true)
                            return@setMethodCallHandler
                        }

                        val locationName =
                            call.argument<String>("locationName") ?: "Unknown location"
                        val soundMode =
                            call.argument<String>("soundMode") ?: "notification_only"
                        val rawPrayers = call.argument<List<Any?>>("prayers") ?: emptyList()
                        val prayers = rawPrayers.mapNotNull { it as? Map<*, *> }

                        PrayerAlarmScheduler.scheduleFromFlutter(
                            context = applicationContext,
                            prayers = prayers,
                            locationName = locationName,
                            soundMode = soundMode,
                        )
                        result.success(true)
                    }

                    "cancelPrayerAlarms" -> {
                        PrayerAlarmScheduler.cancelAll(applicationContext)
                        result.success(true)
                    }

                    "canScheduleExactAlarms" -> {
                        result.success(
                            PrayerAlarmScheduler.canScheduleExactAlarms(
                                applicationContext,
                            ),
                        )
                    }

                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("PRAYER_ALARM_ERROR", e.message, null)
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            TASBIH_FEEDBACK_CHANNEL,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "playTick" -> {
                        val tone = tasbihToneGenerator ?: ToneGenerator(
                            AudioManager.STREAM_MUSIC,
                            80,
                        ).also {
                            tasbihToneGenerator = it
                        }
                        tone.startTone(ToneGenerator.TONE_PROP_BEEP, 45)
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("TASBIH_FEEDBACK_ERROR", e.message, null)
            }
        }
    }

    override fun onDestroy() {
        tasbihToneGenerator?.release()
        tasbihToneGenerator = null
        super.onDestroy()
    }
}
