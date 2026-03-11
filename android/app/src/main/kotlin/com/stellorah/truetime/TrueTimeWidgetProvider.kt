package com.stellorah.truetime

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews

class TrueTimeWidgetProvider : AppWidgetProvider() {

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
        val bgHex = prefs.getString("bgHex", "#000000") ?: "#000000"
        val textHex = prefs.getString("textHex", "#FFFFFF") ?: "#FFFFFF"

        val safeBg = parseColorOrDefault(bgHex, Color.BLACK)
        val safeText = parseColorOrDefault(textHex, Color.WHITE)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            views.setInt(R.id.widget_root, "setBackgroundColor", safeBg)
            views.setTextColor(R.id.widget_time, safeText)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun parseColorOrDefault(value: String, fallback: Int): Int {
        return try {
            Color.parseColor(value)
        } catch (_: IllegalArgumentException) {
            fallback
        }
    }
}
