import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/subscription.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Инициализация сервиса.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const macosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxInit = LinuxInitializationSettings(
      defaultActionName: 'Open SubTrack',
    );

    // v18 of flutter_local_notifications provides InitializationSettings
    // without explicit `windows` / `web` fields; just build conditionally
    // and ignore the unsupported platforms for now.
    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      macOS: macosInit,
      linux: linuxInit,
    );

    await _plugin.initialize(initSettings);

    await _requestPermissions();

    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'subscription_reminders',
          'Subscription Reminders',
          description: 'Уведомления о предстоящем списании по подпискам',
          importance: Importance.high,
        ),
      );
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      return;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return;
    }

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
      return;
    }
  }

  /// Планирует уведомление за 1 день до списания по подписке.
  Future<void> scheduleSubscriptionNotification(Subscription sub) async {
    await initialize();

    final id = _idFromString(sub.id);

    final fireDate = sub.nextPaymentDate.subtract(const Duration(days: 1));
    final now = DateTime.now();

    if (!fireDate.isAfter(now)) {
      await _plugin.cancel(id);
      return;
    }

    final tzDate = tz.TZDateTime.from(
      DateTime(fireDate.year, fireDate.month, fireDate.day, 9, 0),
      tz.local,
    );

    const androidDetails = AndroidNotificationDetails(
      'subscription_reminders',
      'Subscription Reminders',
      channelDescription: 'Напоминания о списании по подпискам',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const macosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
      linux: linuxDetails,
    );

    final body =
        'Завтра спишется ${sub.price.toStringAsFixed(2)} ${sub.currency} '
        'за подписку ${sub.name}!';

    try {
      await _plugin.zonedSchedule(
        id,
        'SubTrack: скоро списание',
        body,
        tzDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (_) {
      await _showImmediate(id, 'SubTrack: скоро списание', body, details);
    }
  }

  Future<void> _showImmediate(
    int id,
    String? title,
    String? body,
    NotificationDetails details,
  ) async {
    try {
      await _plugin.show(id, title, body, details);
    } catch (_) {}
  }

  /// Отменяет запланированное уведомление по id подписки.
  Future<void> cancelSubscriptionNotification(String subscriptionId) async {
    await _plugin.cancel(_idFromString(subscriptionId));
  }

  /// Стабильный числовой id по строковому ключу.
  int _idFromString(String key) {
    int h = 0;
    for (final c in key.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }
}
