package com.yourcompany.digimon_pendulum

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class DigimonWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    // ========================================
    // 変更: updateAppWidget メソッドの最初と最後
    // ========================================

    companion object {
        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            android.util.Log.d("DigimonWidget", "updateAppWidget called for ID: $appWidgetId")
            
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val views = RemoteViews(context.packageName, R.layout.digimon_widget)

                android.util.Log.d("DigimonWidget", "Layout inflated successfully")

                // データ取得（デフォルト値を設定）
                val mood = widgetData.getInt("digimon_mood", 100)
                val poopCount = widgetData.getInt("digimon_poop", 0)
                val adventureCoins = widgetData.getInt("adventure_coins", 0)
                val evolutionColor = widgetData.getInt("evolution_color", 0xFFE0E0E0.toInt())
                val canEvolve = widgetData.getBoolean("can_evolve", false)

                android.util.Log.d("DigimonWidget", "Data loaded - mood:$mood, poop:$poopCount, coins:$adventureCoins")

                // デジモンの色を設定
                views.setInt(R.id.digimon_sprite, "setColorFilter", evolutionColor)

                // 機嫌に応じて顔を変更
                val face = when {
                    mood >= 80 -> "😊"
                    mood >= 50 -> "😐"
                    mood >= 30 -> "😟"
                    else -> "😢"
                }
                views.setTextViewText(R.id.digimon_face, face)

                // うんち表示
                views.setViewVisibility(R.id.poop_1, if (poopCount >= 1) View.VISIBLE else View.GONE)
                views.setViewVisibility(R.id.poop_2, if (poopCount >= 2) View.VISIBLE else View.GONE)
                views.setViewVisibility(R.id.poop_3, if (poopCount >= 3) View.VISIBLE else View.GONE)

                // 冒険コイン表示
                if (adventureCoins > 0) {
                    views.setViewVisibility(R.id.adventure_coins_container, View.VISIBLE)
                    views.setTextViewText(R.id.adventure_coins, adventureCoins.toString())
                } else {
                    views.setViewVisibility(R.id.adventure_coins_container, View.GONE)
                }

                // 進化可能アイコン
                views.setViewVisibility(
                    R.id.evolve_icon,
                    if (canEvolve) View.VISIBLE else View.GONE
                )

                // クリックでアプリ起動
                val intent = Intent(context, MainActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                // 更新
                appWidgetManager.updateAppWidget(appWidgetId, views)
                
                android.util.Log.d("DigimonWidget", "Widget updated successfully!")
                
            } catch (e: Exception) {
                android.util.Log.e("DigimonWidget", "Error updating widget", e)
                e.printStackTrace()
            }
        }
    }