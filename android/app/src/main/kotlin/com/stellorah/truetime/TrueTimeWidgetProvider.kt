package com.stellorah.truetime

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews

class TrueTimeWidgetProvider : AppWidgetProvider() {

    private companion object {
        private const val BG_HEX_KEY = "bgHex"
        private const val TEXT_HEX_KEY = "textHex"
        private const val IS_24_HOUR_MODE_KEY = "widgetIs24HourMode"
        private const val DEFAULT_BG_COLOR = Color.BLACK
        private const val DEFAULT_TEXT_COLOR = Color.WHITE
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        if (intent.action == "es.antonborri.home_widget.action.UPDATE") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, TrueTimeWidgetProvider::class.java),
            )
            updateWidgets(context, appWidgetManager, appWidgetIds)
        }
    }

    private fun updateWidgets(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val bgHex = prefs.getString(BG_HEX_KEY, null)
        val textHex = prefs.getString(TEXT_HEX_KEY, null)
        val bgColor = parseColorOrDefault(bgHex, DEFAULT_BG_COLOR)
        val textColor = parseColorOrDefault(textHex, DEFAULT_TEXT_COLOR)
        val has24HourPreference = prefs.contains(IS_24_HOUR_MODE_KEY)
        val is24HourMode = prefs.getBoolean(IS_24_HOUR_MODE_KEY, false)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            views.setInt(R.id.widget_root, "setBackgroundColor", bgColor)
            views.setTextColor(R.id.widget_clock, textColor)

            if (has24HourPreference) {
                if (is24HourMode) {
                    views.setCharSequence(R.id.widget_clock, "setFormat12Hour", "HH:mm:ss")
                    views.setCharSequence(R.id.widget_clock, "setFormat24Hour", "HH:mm:ss")
                } else {
                    views.setCharSequence(R.id.widget_clock, "setFormat12Hour", "hh:mm:ss a")
                    views.setCharSequence(R.id.widget_clock, "setFormat24Hour", "hh:mm:ss a")
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun parseColorOrDefault(hex: String?, fallback: Int): Int {
        return try {
            if (hex.isNullOrBlank()) {
                fallback
            } else {
                Color.parseColor(hex)
            }
        } catch (e: Exception) {
            fallback
        }
    }
}
