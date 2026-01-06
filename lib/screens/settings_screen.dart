import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _poopNotification = true;
  bool _evolutionNotification = true;
  bool _moodNotification = true;
  bool _adventureNotification = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _poopNotification = prefs.getBool('notif_poop') ?? true;
      _evolutionNotification = prefs.getBool('notif_evolution') ?? true;
      _moodNotification = prefs.getBool('notif_mood') ?? true;
      _adventureNotification = prefs.getBool('notif_adventure') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '通知設定',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('💩 うんち通知'),
            subtitle: const Text('うんちが3個以上溜まった時に通知'),
            value: _poopNotification,
            onChanged: (value) {
              setState(() {
                _poopNotification = value;
              });
              _saveSetting('notif_poop', value);
            },
          ),
          SwitchListTile(
            title: const Text('✨ 進化可能通知'),
            subtitle: const Text('進化条件を満たした時に通知'),
            value: _evolutionNotification,
            onChanged: (value) {
              setState(() {
                _evolutionNotification = value;
              });
              _saveSetting('notif_evolution', value);
            },
          ),
          SwitchListTile(
            title: const Text('😢 機嫌悪化通知'),
            subtitle: const Text('機嫌が30以下になった時に通知'),
            value: _moodNotification,
            onChanged: (value) {
              setState(() {
                _moodNotification = value;
              });
              _saveSetting('notif_mood', value);
            },
          ),
          SwitchListTile(
            title: const Text('🗺️ 冒険完了通知'),
            subtitle: const Text('コインや敵を発見した時に通知'),
            value: _adventureNotification,
            onChanged: (value) {
              setState(() {
                _adventureNotification = value;
              });
              _saveSetting('notif_adventure', value);
            },
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _testNotification,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('テスト通知を送信'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _clearAllNotifications,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('全通知をクリア'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testNotification() async {
    final notifications = NotificationService();
    await notifications.showNotification(
      id: 999,
      title: 'テスト通知',
      body: '通知が正常に動作しています！',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('テスト通知を送信しました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAllNotifications() async {
    final notifications = NotificationService();
    await notifications.cancelAll();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('全通知をクリアしました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}