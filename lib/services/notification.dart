import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> notify() async {
  // 通知プラグインのインスタンスの作成・初期化
  final flnp = FlutterLocalNotificationsPlugin();
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

  // 通知時間の定義
  final scheduledDate = tz.TZDateTime.now(
    tz.local,
  ).add(const Duration(seconds: 5));

  // Android 固有の設定
  const androidNotificationDetails = AndroidNotificationDetails(
    'test_channel_id',
    'test_channel_name',
  );
  const notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  await flnp.zonedSchedule(
    id: 0, // ID
    title: 'テスト通知', // タイトル
    body: 'これはテスト通知の内容です', // 内容
    scheduledDate: scheduledDate, // 通知時間
    notificationDetails: notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: null,
  );
  // OSに、「test_channel_id」の枠組みで、scheduledDateの時間に通知するよう指示を出す
  // 同じ枠組みで内で、異なる通知を出したい場合は、idを変えることで可能
}
