package com.stellorah.truetime

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import java.io.File

class TrueTimeWidgetProvider : AppWidgetProvider() {

    private companion object {
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
        val snapshotPath = prefs.getString(SNAPSHOT_PATH_KEY, null)
        val snapshotBitmap = loadSnapshotBitmap(snapshotPath)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            if (snapshotBitmap != null) {
                views.setImageViewBitmap(R.id.widget_snapshot, snapshotBitmap)
                views.setViewVisibility(R.id.widget_snapshot, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_snapshot, android.view.View.GONE)
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

        return try {
            BitmapFactory.decodeFile(file.absolutePath)
        } catch (e: Exception) {
            null
        }
    }
}
