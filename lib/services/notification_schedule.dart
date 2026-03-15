import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationSchedule {
  factory NotificationSchedule() => _instance;
  NotificationSchedule._internal();
  static final NotificationSchedule _instance =
      NotificationSchedule._internal();

  late final FlutterLocalNotificationsPlugin flnp;

  static const androidNotificationDetails = AndroidNotificationDetails(
    'test_channel_id',
    'test_channel_name',
  );
  static const notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  Future<void> initFlnp() async {
    flnp = FlutterLocalNotificationsPlugin();
    await flnp.initialize(
      settings: InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Android における通知のリクエスト
    await flnp
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // タイムゾーン初期化
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
  }

  Future<void> schedule(int id, String deadline, String title) async {
    final date = DateTime.parse(deadline);
    final schedule = tz.TZDateTime.local(
      date.year,
      date.month,
      date.day,
      14,
      22, // 通知する時間を14:22に設定
    );
    await flnp.zonedSchedule(
      id: id, // ID
      title: title, // タイトル
      scheduledDate: schedule, // 通知時間
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }
}
