package com.example.kita_46_2

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
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

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.kita_widget_layout)

            if (hasQuran) {
                views.setTextViewText(R.id.widget_quran_text, "$surahText: $ayahText")
                views.setTextViewText(R.id.widget_quran_subtitle, "Lanjut Baca")
            } else {
                views.setTextViewText(R.id.widget_quran_text, "-")
                views.setTextViewText(R.id.widget_quran_subtitle, "Belum ada riwayat")
            }

            if (hasPr) {
                views.setTextViewText(R.id.widget_pr_text, prTitle)
                views.setTextViewText(R.id.widget_pr_subtitle, "Count: ${prCount}x")
            } else {
                views.setTextViewText(R.id.widget_pr_text, "-")
                views.setTextViewText(R.id.widget_pr_subtitle, "Belum dikerjakan")
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
