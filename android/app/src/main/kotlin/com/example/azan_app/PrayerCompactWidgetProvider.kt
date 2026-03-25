package com.example.azan_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerCompactWidgetProvider : HomeWidgetProvider() {
  override fun onUpdate(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetIds: IntArray,
    widgetData: SharedPreferences,
  ) {
    PrayerWidgetRenderer.render(
      context = context,
      appWidgetManager = appWidgetManager,
      appWidgetIds = appWidgetIds,
      widgetData = widgetData,
      layoutRes = R.layout.prayer_widget_compact_layout,
      showRamadan = false,
    )
  }
}
