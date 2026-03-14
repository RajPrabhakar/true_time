package com.stellorah.truetime

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.os.Build
import android.widget.RemoteViews
import java.io.File
import java.util.Calendar

// The widget displays a rendered snapshot only when a skin theme is active.
// Non-skin themes clear the snapshot path (set to ""), which hides the widget content.
class SkinThemeWidgetProvider : AppWidgetProvider() {

    private companion object {
        private const val SNAPSHOT_PATH_KEY = "widgetSnapshotPath"
        private const val THEME_NAME_KEY = "widgetThemeName"
        private const val THEME_CATEGORY_KEY = "widgetThemeCategory"
        private const val BG_HEX_KEY = "bgHex"
        private const val TEXT_HEX_KEY = "textHex"
        private const val IS_24_HOUR_KEY = "widgetIs24HourMode"
        const val ACTION_MINUTE_TICK = "com.stellorah.truetime.WIDGET_MINUTE_TICK"
        // Native render canvas size — matches Flutter snapshot logical size.
        private const val CANVAS_WIDTH = 720
        private const val CANVAS_HEIGHT = 360
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        scheduleMinuteTick(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        cancelMinuteTick(context)
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

        val action = intent.action
        when (action) {
            "es.antonborri.home_widget.action.UPDATE" -> {
                // Flutter pushed a fresh snapshot — display it as-is.
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, SkinThemeWidgetProvider::class.java),
                )
                updateWidgets(context, appWidgetManager, appWidgetIds, isBackgroundTick = false)
            }
            ACTION_MINUTE_TICK -> {
                // Background alarm — Flutter is not running; render time natively.
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, SkinThemeWidgetProvider::class.java),
                )
                updateWidgets(context, appWidgetManager, appWidgetIds, isBackgroundTick = true)
                scheduleMinuteTick(context)
            }
        }
    }

    private fun scheduleMinuteTick(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = minuteTickPendingIntent(context)

        val nextMinute = Calendar.getInstance().apply {
            add(Calendar.MINUTE, 1)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis

        // RTC_WAKEUP wakes the CPU if sleeping. setExactAndAllowWhileIdle fires
        // even in Doze mode. On API 31+ we check for the exact-alarm permission
        // and fall back to an inexact setWindow alarm when it is not yet granted.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
            // Inexact fallback: fires within a 30-second window around the target.
            alarmManager.setWindow(
                AlarmManager.RTC_WAKEUP,
                nextMinute,
                30_000L,
                pendingIntent,
            )
        } else {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, nextMinute, pendingIntent)
        }
    }

    private fun cancelMinuteTick(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(minuteTickPendingIntent(context))
    }

    private fun minuteTickPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, SkinThemeWidgetProvider::class.java).apply {
            action = ACTION_MINUTE_TICK
        }
        return PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun updateWidgets(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        isBackgroundTick: Boolean = false,
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        // An empty or absent path means no skin theme is active — show the unsupported message.
        val snapshotPath = prefs.getString(SNAPSHOT_PATH_KEY, null)

        // Choose the bitmap to display:
        //  • Foreground push (Flutter is running): use the fresh Flutter-rendered snapshot.
        //  • Background tick (Flutter not running): render the current time natively so
        //    the widget is never stuck showing a stale time from a previous snapshot.
        val displayBitmap: Bitmap? = if (!snapshotPath.isNullOrBlank()) {
            if (isBackgroundTick) {
                val bgHex = prefs.getString(BG_HEX_KEY, null)
                val textHex = prefs.getString(TEXT_HEX_KEY, null)
                val is24Hour = prefs.getBoolean(IS_24_HOUR_KEY, false)
                renderNativeClockBitmap(bgHex, textHex, is24Hour)
            } else {
                loadSkinSnapshot(snapshotPath)
            }
        } else {
            null
        }

        val themeName = prefs.getString(THEME_NAME_KEY, null)
        val themeCategory = prefs.getString(THEME_CATEGORY_KEY, null)
            ?.replaceFirstChar { it.uppercase() }
        val unsupportedMessage = buildUnsupportedMessage(themeName, themeCategory)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.skin_theme_widget_layout)

            if (displayBitmap != null) {
                views.setImageViewBitmap(R.id.widget_snapshot, displayBitmap)
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

    /**
     * Renders the current time as a plain [Bitmap] using theme colors from SharedPreferences.
     * Used when Flutter is not running (background tick) and cannot produce a fresh snapshot.
     */
    private fun renderNativeClockBitmap(bgHex: String?, textHex: String?, is24Hour: Boolean): Bitmap {
        val bitmap = Bitmap.createBitmap(CANVAS_WIDTH, CANVAS_HEIGHT, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val bgColor = parseHexColor(bgHex) ?: Color.BLACK
        canvas.drawColor(bgColor)

        val cal = Calendar.getInstance()
        val timeStr = if (is24Hour) {
            String.format("%02d:%02d", cal.get(Calendar.HOUR_OF_DAY), cal.get(Calendar.MINUTE))
        } else {
            val rawHour = cal.get(Calendar.HOUR).let { if (it == 0) 12 else it }
            val amPm = if (cal.get(Calendar.AM_PM) == Calendar.AM) "am" else "pm"
            String.format("%02d:%02d %s", rawHour, cal.get(Calendar.MINUTE), amPm)
        }

        val textColor = parseHexColor(textHex) ?: Color.WHITE
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = textColor
            textSize = CANVAS_HEIGHT * 0.30f
            textAlign = Paint.Align.CENTER
            typeface = Typeface.MONOSPACE
        }

        val cx = CANVAS_WIDTH / 2f
        val cy = CANVAS_HEIGHT / 2f - (paint.ascent() + paint.descent()) / 2f
        canvas.drawText(timeStr, cx, cy, paint)

        return bitmap
    }

    private fun parseHexColor(hex: String?): Int? {
        if (hex.isNullOrBlank()) return null
        return try {
            Color.parseColor(if (hex.startsWith("#")) hex else "#$hex")
        } catch (e: Exception) {
            null
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
