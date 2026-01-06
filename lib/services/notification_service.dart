import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// 通知タイプ
enum NotificationType {
  poop,         // うんち
  evolution,    // 進化可能
  mood,         // 機嫌悪化
  adventure,    // 冒険完了
}

/// 通知サービス
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;

  /// 初期化
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Androidの通知チャンネル作成
    await _createNotificationChannel();

    _initialized = true;
    debugPrint('✅ 通知サービス初期化完了');
  }

  /// 通知チャンネルを作成
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'digimon_channel',
      'デジモン通知',
      description: 'デジモンの状態変化を通知します',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 通知権限をリクエスト
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      final granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    }
    
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// 通知をタップした時の処理
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('通知タップ: ${response.payload}');
    // 必要に応じてディープリンクなどの処理を追加
  }

  /// 通知を表示
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    NotificationType? type,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'digimon_channel',
      'デジモン通知',
      channelDescription: 'デジモンの状態変化を通知します',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );

    debugPrint('📢 通知表示: $title - $body');
  }

  /// うんち通知
  Future<void> notifyPoop(String digimonName, int poopCount) async {
    await showNotification(
      id: 1,
      title: '💩 うんちが溜まっています！',
      body: '$digimonNameのうんちが${poopCount}個になりました。掃除してあげましょう！',
      type: NotificationType.poop,
    );
  }

  /// 進化可能通知
  Future<void> notifyEvolutionReady(String digimonName, String nextStage) async {
    await showNotification(
      id: 2,
      title: '✨ 進化可能です！',
      body: '$digimonNameが$nextStageに進化できます！',
      type: NotificationType.evolution,
    );
  }

  /// 機嫌悪化通知
  Future<void> notifyLowMood(String digimonName, int mood) async {
    await showNotification(
      id: 3,
      title: '😢 機嫌が悪くなっています',
      body: '$digimonNameの機嫌が$moodになりました。なでなでしてあげましょう！',
      type: NotificationType.mood,
    );
  }

  /// 冒険完了通知
  Future<void> notifyAdventureComplete(String digimonName, int coins, int enemies) async {
    String message = '';
    if (coins > 0 && enemies > 0) {
      message = 'コイン${coins}枚と敵${enemies}体を発見しました！';
    } else if (coins > 0) {
      message = 'コイン${coins}枚を発見しました！';
    } else if (enemies > 0) {
      message = '敵${enemies}体を倒しました！';
    }

    if (message.isNotEmpty) {
      await showNotification(
        id: 4,
        title: '🗺️ 冒険完了！',
        body: '$digimonName: $message',
        type: NotificationType.adventure,
      );
    }
  }

  /// 全通知をキャンセル
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('🔕 全通知をキャンセル');
  }

  /// 特定の通知をキャンセル
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}