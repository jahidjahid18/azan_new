package com.example.azan_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

object PrayerWidgetRenderer {
  fun render(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
    widgetData: SharedPreferences,
    layoutRes: Int,
    showRamadan: Boolean,
  ) {
    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, layoutRes).apply {
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
        setTextViewText(
          R.id.widgetRamadanCountdown,
          widgetData.getString("widget_ramadan_countdown", "Ramadan countdown"),
        )
        setViewVisibility(R.id.widgetRamadanCountdown, if (showRamadan) View.VISIBLE else View.GONE)

        val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        setOnClickPendingIntent(R.id.widgetContainer, launchIntent)
      }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }
}
