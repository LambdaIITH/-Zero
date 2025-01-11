import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/models/weekly_event_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class EventNotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> scheduleWeeklyNotifications({
    required Timetable timetable,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'dashboard-channel',
      'IITH Dashboard Channel',
      channelDescription: 'Notifications for upcoming classes',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    int reminderOffsetMinutes = 10;
    List<WeeklyEvent> events =
        timetable.convertTimetableToWeeklyEvents(reminderOffsetMinutes);

    for (var event in events) {
      // peridically won't work as it schedules periodically first when its called,
      // better used for alarms may be
      
      // flutterLocalNotificationsPlugin.periodicallyShow(event.id, event.title,
      // event.description, RepeatInterval.weekly, platformChannelSpecifics,
      // androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);

      final tz.TZDateTime scheduledDate = _nextInstanceOfDay(
        event.dayOfWeek,
        event.hour,
        event.minute,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        event.id,
        event.title,
        event.description,
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> clearPendingNotifications(
      FlutterLocalNotificationsPlugin notificationsPlugin) async {
    try {
      await notificationsPlugin.cancelAll();
    } catch (e) {
      print("failed clearning $e");
    }
  }

  static tz.TZDateTime _nextInstanceOfDay(int dayOfWeek, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    return scheduledDate;
  }
}
