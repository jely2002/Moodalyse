import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationHelpers {
  static initializeNotifications() {
    AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelKey: 'mood_reminders',
              channelName: 'Mood reminders',
              channelDescription: 'Reminders to add your mood to Moodalyse!',
              defaultColor: Colors.pink,
              ledColor: Colors.white
          )
        ],
        debug: kDebugMode);
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }
}
