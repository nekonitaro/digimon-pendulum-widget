package com.yourcompany.digimon_pendulum

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // データを取得
                val name = widgetData.getString("name", "アグモン") ?: "アグモン"
                val level = widgetData.getInt("level", 1)
                val coins = widgetData.getInt("coins", 0)
                val mood = widgetData.getInt("mood", 100)
                val poopCount = widgetData.getInt("poopCount", 0)
                val adventureCoins = widgetData.getInt("adventureCoins", 0)
                val distance = widgetData.getInt("distance", 0)
                
                // ウィジェットに表示
                setTextViewText(R.id.widget_name, name)
                setTextViewText(R.id.widget_level, "レベル: $level")
                setTextViewText(R.id.widget_coins, "コイン: $coins")
                setTextViewText(R.id.widget_mood, "機嫌: $mood")
                setTextViewText(R.id.widget_poop, "うんち: ${"💩".repeat(poopCount)}")
                // setTextViewText(R.id.widget_adventure_coins, "🪙 ${adventureCoins}枚 (${distance}m)")
                
                // ボタンのクリックイベント
                val addCoinIntent = Intent(Intent.ACTION_VIEW, Uri.parse("digimon://addcoin"))
                addCoinIntent.setPackage(context.packageName)
                val addCoinPendingIntent = android.app.PendingIntent.getActivity(
                    context, 0, addCoinIntent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_add_coin, addCoinPendingIntent)
                
                val cleanPoopIntent = Intent(Intent.ACTION_VIEW, Uri.parse("digimon://cleanpoop"))
                cleanPoopIntent.setPackage(context.packageName)
                val cleanPoopPendingIntent = android.app.PendingIntent.getActivity(
                    context, 1, cleanPoopIntent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_clean_poop, cleanPoopPendingIntent)
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}