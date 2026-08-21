package com.example.kita_46_2

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class KitaWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val surahText = widgetData.getString("widget_surah", null)
        val ayahText = widgetData.getString("widget_ayah", null)
        val prTitle = widgetData.getString("widget_pr_title", null)
        val prCount = widgetData.getString("widget_pr_count", null)
        val prDate = widgetData.getString("widget_pr_date", null)

        val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
        val prIsToday = prDate == today
        val hasQuran = surahText != null && surahText.isNotEmpty()
        val hasPr = prTitle != null && prTitle.isNotEmpty() && prIsToday

        val streakMsg = widgetData.getString("widget_streak_message", null)

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.kita_widget_layout)

            if (hasQuran) {
                views.setTextViewText(R.id.widget_quran_text, "$surahText: $ayahText")
                views.setTextViewText(R.id.widget_quran_subtitle, "Lanjut Baca")
            } else {
                views.setTextViewText(R.id.widget_quran_text, "-")
                views.setTextViewText(R.id.widget_quran_subtitle, streakMsg ?: "Belum ada riwayat")
            }

            if (hasPr) {
                views.setTextViewText(R.id.widget_pr_text, prTitle)
                views.setTextViewText(R.id.widget_pr_subtitle, "Count: ${prCount}x")
            } else {
                views.setTextViewText(R.id.widget_pr_text, "-")
                views.setTextViewText(R.id.widget_pr_subtitle, streakMsg ?: "Belum dikerjakan")
            }

            // Click handler for Qur'an area → opens app to last-read surah
            val quranIntent = Intent(context, MainActivity::class.java).apply {
                action = "es.antonborri.home_widget.action.LAUNCH"
                data = Uri.parse("kita462://quran")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val quranPending = PendingIntent.getActivity(
                context,
                0,
                quranIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_quran_area, quranPending)

            // Click handler for PR 13 area → opens app to PR 13 page
            val prIntent = Intent(context, MainActivity::class.java).apply {
                action = "es.antonborri.home_widget.action.LAUNCH"
                data = Uri.parse("kita462://pr13")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val prPending = PendingIntent.getActivity(
                context,
                1,
                prIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_pr_area, prPending)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
