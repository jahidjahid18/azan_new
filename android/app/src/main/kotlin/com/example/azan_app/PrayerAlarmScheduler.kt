package com.example.azan_app

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

internal data class PrayerAlarmEntry(
    val prayerName: String,
    val triggerAtMillis: Long,
    val locationName: String,
    val soundMode: String,
)

internal object PrayerAlarmScheduler {
    private const val prefsName = "azan_prayer_alarm_prefs"
    private const val keyEntriesJson = "entries_json"
    private const val keyNextIndex = "next_index"
    private const val alarmRequestCode = 771001

    private const val actionTriggerPrayerAlarm = "com.example.azan_app.PRAYER_ALARM_TRIGGER"

    private const val channelSilent = "prayer_silent_channel"
    private const val channelAzan = "prayer_azan_channel"
    private const val channelName = "Prayer Alerts"
    private const val soundModeAzan = "azan_sound"

    fun scheduleFromFlutter(
        context: Context,
        prayers: List<Map<*, *>>,
        locationName: String,
        soundMode: String,
    ) {
        val now = System.currentTimeMillis()
        val entries = prayers
            .mapNotNull { map ->
                val name = map["name"] as? String ?: return@mapNotNull null
                val millis = anyToLong(map["timeMillis"]) ?: return@mapNotNull null
                PrayerAlarmEntry(
                    prayerName = name,
                    triggerAtMillis = millis,
                    locationName = locationName,
                    soundMode = soundMode,
                )
            }
            .filter { it.triggerAtMillis > now }
            .sortedBy { it.triggerAtMillis }

        if (entries.isEmpty()) {
            cancelAll(context)
            return
        }

        saveEntries(context, entries)
        scheduleNextFromStoredEntries(context)
    }

    fun onAlarmTriggered(context: Context) {
        val entries = loadEntries(context)
        if (entries.isEmpty()) {
            cancelAll(context)
            return
        }

        val currentIndex = loadNextIndex(context).coerceIn(0, entries.lastIndex)
        val currentEntry = entries[currentIndex]
        showNotification(context, currentEntry)

        val now = System.currentTimeMillis()
        var nextIndex = currentIndex + 1
        while (nextIndex < entries.size && entries[nextIndex].triggerAtMillis <= now) {
            nextIndex++
        }

        if (nextIndex < entries.size) {
            saveNextIndex(context, nextIndex)
            scheduleAlarmAt(context, entries[nextIndex].triggerAtMillis)
        } else {
            cancelPendingIntentOnly(context)
        }
    }

    fun rescheduleAfterBoot(context: Context) {
        scheduleNextFromStoredEntries(context)
    }

    fun cancelAll(context: Context) {
        cancelPendingIntentOnly(context)
        context
            .getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .remove(keyEntriesJson)
            .remove(keyNextIndex)
            .apply()
    }

    fun canScheduleExactAlarms(context: Context): Boolean {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
    }

    private fun scheduleNextFromStoredEntries(context: Context) {
        val entries = loadEntries(context)
        if (entries.isEmpty()) {
            cancelAll(context)
            return
        }

        val now = System.currentTimeMillis()
        val nextIndex = entries.indexOfFirst { it.triggerAtMillis > now }
        if (nextIndex < 0) {
            cancelPendingIntentOnly(context)
            return
        }

        saveNextIndex(context, nextIndex)
        scheduleAlarmAt(context, entries[nextIndex].triggerAtMillis)
    }

    private fun scheduleAlarmAt(context: Context, triggerAtMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = alarmPendingIntent(context)
        alarmManager.cancel(pendingIntent)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                !alarmManager.canScheduleExactAlarms()
            ) {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent,
                )
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent,
                )
            }
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent,
            )
        }
    }

    private fun showNotification(context: Context, entry: PrayerAlarmEntry) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS,
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        ensureChannels(context)

        val channelId = if (entry.soundMode == soundModeAzan) channelAzan else channelSilent
        val timeLabel = SimpleDateFormat("h:mm a", Locale.getDefault()).format(
            Date(entry.triggerAtMillis),
        )
        val title = "${entry.prayerName} - $timeLabel"
        val body = "Location: ${entry.locationName}"

        val launchIntent =
            context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
        val contentIntent = PendingIntent.getActivity(
            context,
            991231,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setOngoing(false)
            .setContentIntent(contentIntent)
            .setShowWhen(true)
            .setWhen(entry.triggerAtMillis)

        if (entry.soundMode != soundModeAzan) {
            builder.setSilent(true)
        }

        val notificationId = (entry.triggerAtMillis % Int.MAX_VALUE).toInt()
        NotificationManagerCompat.from(context).notify(notificationId, builder.build())
    }

    private fun ensureChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val silentChannel = NotificationChannel(
            channelSilent,
            channelName,
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Silent prayer notifications"
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setSound(null, null)
            enableVibration(false)
        }

        val azanChannel = NotificationChannel(
            channelAzan,
            channelName,
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Prayer notifications with azan"
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            val soundUri = Uri.parse("android.resource://${context.packageName}/raw/azan")
            val attributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            setSound(soundUri, attributes)
            enableVibration(true)
        }

        manager.createNotificationChannel(silentChannel)
        manager.createNotificationChannel(azanChannel)
    }

    private fun cancelPendingIntentOnly(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(alarmPendingIntent(context))
    }

    private fun alarmPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, PrayerAlarmReceiver::class.java).apply {
            action = actionTriggerPrayerAlarm
        }
        return PendingIntent.getBroadcast(
            context,
            alarmRequestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun saveEntries(context: Context, entries: List<PrayerAlarmEntry>) {
        val array = JSONArray()
        entries.forEach { entry ->
            val obj = JSONObject()
            obj.put("prayerName", entry.prayerName)
            obj.put("triggerAtMillis", entry.triggerAtMillis)
            obj.put("locationName", entry.locationName)
            obj.put("soundMode", entry.soundMode)
            array.put(obj)
        }
        context
            .getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putString(keyEntriesJson, array.toString())
            .apply()
    }

    private fun loadEntries(context: Context): List<PrayerAlarmEntry> {
        val raw = context
            .getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .getString(keyEntriesJson, null)
            ?: return emptyList()

        return try {
            val array = JSONArray(raw)
            buildList {
                for (i in 0 until array.length()) {
                    val obj = array.optJSONObject(i) ?: continue
                    val prayerName = obj.optString("prayerName", "")
                    val triggerAtMillis = obj.optLong("triggerAtMillis", -1L)
                    val locationName = obj.optString("locationName", "Unknown location")
                    val soundMode = obj.optString("soundMode", "notification_only")
                    if (prayerName.isBlank() || triggerAtMillis <= 0L) continue
                    add(
                        PrayerAlarmEntry(
                            prayerName = prayerName,
                            triggerAtMillis = triggerAtMillis,
                            locationName = locationName,
                            soundMode = soundMode,
                        ),
                    )
                }
            }.sortedBy { it.triggerAtMillis }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun loadNextIndex(context: Context): Int {
        return context
            .getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .getInt(keyNextIndex, 0)
    }

    private fun saveNextIndex(context: Context, index: Int) {
        context
            .getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putInt(keyNextIndex, index)
            .apply()
    }

    private fun anyToLong(value: Any?): Long? {
        return when (value) {
            is Long -> value
            is Int -> value.toLong()
            is Double -> value.toLong()
            is Float -> value.toLong()
            is String -> value.toLongOrNull()
            else -> null
        }
    }
}
