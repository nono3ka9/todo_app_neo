import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> repeatingNotify() async {
  final flnp = FlutterLocalNotificationsPlugin();
  await flnp.initialize(
    settings: InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  await flnp
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  const androidNotificationDetails = AndroidNotificationDetails(
    'repeating_channel_id',
    'repeating_channel_name',
  );
  const notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  // await flnp.periodicallyShow(
  //   id: 2,
  //   title: '定期通知',
  //   body: '1 分おきの通知です',
  //   repeatInterval: RepeatInterval.everyMinute,
  //   notificationDetails: notificationDetails,
  //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  // );

  await flnp.cancelAll();

  // OSに、「repeating_channel_id」の枠組みで、通知するよう指示を出す
  // スケジュールで管理されてる間は、cancelしない限り通知が鳴り続ける
}
