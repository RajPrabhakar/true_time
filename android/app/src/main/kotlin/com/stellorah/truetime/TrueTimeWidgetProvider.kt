package com.stellorah.truetime

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.widget.RemoteViews
import java.io.File

class TrueTimeWidgetProvider : AppWidgetProvider() {

    private companion object {
        private const val DEFAULT_BG_HEX = "#000000"
        private const val DEFAULT_TEXT_HEX = "#FFFFFF"
        private const val SNAPSHOT_PATH_KEY = "widgetSnapshotPath"
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
        val bgHex = prefs.getString("bgHex", DEFAULT_BG_HEX) ?: DEFAULT_BG_HEX
        val textHex = prefs.getString("textHex", DEFAULT_TEXT_HEX) ?: DEFAULT_TEXT_HEX
        val snapshotPath = prefs.getString(SNAPSHOT_PATH_KEY, null)

        val safeBg = parseColorOrDefault(bgHex, Color.parseColor(DEFAULT_BG_HEX))
        val safeText = parseColorOrDefault(textHex, Color.parseColor(DEFAULT_TEXT_HEX))
        val snapshotBitmap = loadSnapshotBitmap(snapshotPath)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            views.setInt(R.id.widget_root, "setBackgroundColor", safeBg)
            if (snapshotBitmap != null) {
                views.setImageViewBitmap(R.id.widget_snapshot, snapshotBitmap)
                views.setViewVisibility(R.id.widget_snapshot, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.widget_time, android.view.View.GONE)
            } else {
                views.setTextColor(R.id.widget_time, safeText)
                views.setViewVisibility(R.id.widget_snapshot, android.view.View.GONE)
                views.setViewVisibility(R.id.widget_time, android.view.View.VISIBLE)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun loadSnapshotBitmap(path: String?): android.graphics.Bitmap? {
        if (path.isNullOrBlank()) {
            return null
        }

        val file = File(path)
        if (!file.exists()) {
            return null
        }

        return BitmapFactory.decodeFile(file.absolutePath)
    }

    private fun parseColorOrDefault(value: String, fallback: Int): Int {
        val normalized = normalizeHexColor(value)
        return try {
            Color.parseColor(normalized)
        } catch (_: IllegalArgumentException) {
            fallback
        }
    }

    private fun normalizeHexColor(value: String): String {
        val trimmed = value.trim()
        if (trimmed.isEmpty()) {
            return DEFAULT_BG_HEX
        }
        return if (trimmed.startsWith("#")) trimmed else "#$trimmed"
    }
}
