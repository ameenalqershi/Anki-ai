import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:english_mentor_ai2/data/local_data_source.dart';

class NotificationService {
  static final _notifs = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _notifs.initialize(settings);
  }

  static void showNewMessage(String msg) {
    _notifs.show(
      0,
      "رسالة جديدة",
      msg,
      const NotificationDetails(
        android: AndroidNotificationDetails('chat', 'دردشة'),
      ),
    );
  }
}
