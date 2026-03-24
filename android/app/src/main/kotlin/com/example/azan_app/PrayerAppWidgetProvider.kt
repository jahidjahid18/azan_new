package com.example.azan_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerAppWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
    widgetData: SharedPreferences,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout).apply {
        setTextViewText(R.id.widgetCity, widgetData.getString("widget_city_name", "Prayer Times"))
        setTextViewText(
          R.id.widgetNextPrayerName,
          widgetData.getString("widget_next_prayer_name", "No upcoming prayer"),
        )
        setTextViewText(
          R.id.widgetNextPrayerTime,
          widgetData.getString("widget_next_prayer_time", "--:--"),
        )
        setTextViewText(
          R.id.widgetCountdown,
          "In " + (widgetData.getString("widget_countdown", "00:00") ?: "00:00"),
        )
        setTextViewText(
          R.id.widgetUpdatedAt,
          "Updated " + (widgetData.getString("widget_updated_at", "just now") ?: "just now"),
        )

        val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        setOnClickPendingIntent(R.id.widgetContainer, launchIntent)
      }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}

