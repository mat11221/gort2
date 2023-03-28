import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'utilities.dart';

// Future<void> createPlantFoodNotification(
//   String title,
//   String text,
//   int id,
// ) async {
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: id,
//       channelKey: 'basic_channel',
//       title: title,
//       body: text,
//       bigPicture: 'asset://assets/list.png',
//       notificationLayout: NotificationLayout.BigPicture,
//     ),
//   );
// }

Future<void> createReminderNotification(
    String title,
    String text,
    int id,
    String gort,
    String group,
    NotificationWeekAndTime notificationSchedule) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
        id: id,
        channelKey: 'scheduled_channel',
        title: title,
        body: text,
        color: Colors.blue,
        notificationLayout: NotificationLayout.Default,
        payload: {'gort': gort},
        groupKey: group),
    actionButtons: [
      NotificationActionButton(key: 'DONE', label: 'Mark done'),
      NotificationActionButton(
          key: 'CANCEL',
          label: 'Cancel',
          actionType: ActionType.DismissAction,
          isDangerousOption: true)
    ],
    schedule: NotificationCalendar(
      weekday: notificationSchedule.dayOfTheWeek,
      hour: notificationSchedule.timeOfDay.hour,
      minute: notificationSchedule.timeOfDay.minute,
      second: 0,
      millisecond: 0,
      repeats: true,
    ),
  );
  Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}

// Future<void> createNewReminderNotification(
//     NotificationWeekAndTime notificationSchedule) async {
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: createUniqueId(),
//       channelKey: 'scheduled_channel',
//       title: '${Emojis.wheater_droplet} Add some water to your plant!',
//       body: 'Water your plant regularly to keep it healthy.',
//       notificationLayout: NotificationLayout.Default,
//     ),
//     actionButtons: [
//       NotificationActionButton(
//         key: 'MARK_DONE',
//         label: 'Mark Done',
//       )
//     ],
//     schedule: NotificationCalendar(
//       weekday: notificationSchedule.dayOfTheWeek,
//       hour: notificationSchedule.timeOfDay.hour,
//       minute: notificationSchedule.timeOfDay.minute,
//       second: 0,
//       millisecond: 0,
//     ),
//   );
// }

Future<void> cancelScheduledNotifications(int uniq) async {
  await AwesomeNotifications().cancelSchedule(uniq);
}

Future<void> cancelAllGroupScheduledNotifications(String groupkey) async {
  await AwesomeNotifications().cancelSchedulesByGroupKey(groupkey);
}

Future<void> cancelAllNotifications(String groupkey) async {
  await AwesomeNotifications().cancelAll();
}
