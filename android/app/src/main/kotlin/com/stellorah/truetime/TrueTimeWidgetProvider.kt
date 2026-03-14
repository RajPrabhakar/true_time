package com.stellorah.truetime

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import java.io.File

// The widget displays a rendered snapshot only when a skin theme is active.
// Non-skin themes clear the snapshot path (set to ""), which hides the widget content.
class TrueTimeWidgetProvider : AppWidgetProvider() {

    private companion object {
        private const val SNAPSHOT_PATH_KEY = "widgetSnapshotPath"
        private const val THEME_NAME_KEY = "widgetThemeName"
        private const val THEME_CATEGORY_KEY = "widgetThemeCategory"
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
        // An empty or absent path means no skin theme is active — show the unsupported message.
        val snapshotPath = prefs.getString(SNAPSHOT_PATH_KEY, null)
        val snapshotBitmap = loadSkinSnapshot(snapshotPath)

        val themeName = prefs.getString(THEME_NAME_KEY, null)
        val themeCategory = prefs.getString(THEME_CATEGORY_KEY, null)
            ?.replaceFirstChar { it.uppercase() }
        val unsupportedMessage = buildUnsupportedMessage(themeName, themeCategory)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            if (snapshotBitmap != null) {
                views.setImageViewBitmap(R.id.widget_snapshot, snapshotBitmap)
                views.setViewVisibility(R.id.widget_snapshot, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.widget_unsupported_text, android.view.View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_snapshot, android.view.View.INVISIBLE)
                views.setTextViewText(R.id.widget_unsupported_text, unsupportedMessage)
                views.setViewVisibility(R.id.widget_unsupported_text, android.view.View.VISIBLE)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun buildUnsupportedMessage(themeName: String?, themeCategory: String?): String {
        val name = if (!themeName.isNullOrBlank()) themeName else "Current theme"
        val category = if (!themeCategory.isNullOrBlank()) "$themeCategory · " else ""
        return "$name\n${category}Not supported in this widget\n\nSwitch to a Skin theme to activate the widget"
    }

    /**
     * Loads the skin-theme snapshot bitmap from [path].
     * Returns null if no skin is active (path is blank or cleared) or the file is missing.
     */
    private fun loadSkinSnapshot(path: String?): android.graphics.Bitmap? {
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
