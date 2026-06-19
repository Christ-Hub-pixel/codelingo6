import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialiser() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
  }

  static Future<void> afficherNotificationInstantanee(String titre, String corps) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_notifications_v2',
        'Notifications instantanées',
        channelDescription: 'Canal pour les notifications immédiates',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('rappel_notification'),
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        titre,
        corps,
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint("Erreur d'affichage notification instantanée: $e");
    }
  }

  static Future<void> programmerRappelQuotidien() async {
    final sentimentalMessages = [
      {'titre': 'Codie est triste... 😢', 'corps': 'Tu lui manques terriblement. Reviens coder un peu ?'},
      {'titre': 'Ta série va mourir... 🕯️', 'corps': 'Ne laisse pas tes efforts partir en fumée. Codie t\'attend.'},
      {'titre': 'Où es-tu ? 🤔', 'corps': 'Codie a préparé un nouvel exercice juste pour toi !'},
      {'titre': 'Petit rappel amical ❤️', 'corps': '5 minutes de code par jour font de toi un génie. À tout de suite ?'},
    ];

    final randomMessage = sentimentalMessages[Random().nextInt(sentimentalMessages.length)];


    try {
      await _notifications.zonedSchedule(
        0,
        randomMessage['titre']!,
        randomMessage['corps']!,
        _suivanteInstanceDe18h(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'rappel_sentimental_canal_v2',
            'Rappels Émotionnels',
            channelDescription: 'Notifications sentimentales pour encourager la pratique',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('rappel_notification'),
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Erreur lors de la programmation de la notification: $e");
    }
  }

  static tz.TZDateTime _suivanteInstanceDe18h() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 18);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
