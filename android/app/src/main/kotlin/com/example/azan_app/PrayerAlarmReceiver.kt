package com.example.azan_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class PrayerAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        PrayerAlarmScheduler.onAlarmTriggered(context.applicationContext)
    }
}
