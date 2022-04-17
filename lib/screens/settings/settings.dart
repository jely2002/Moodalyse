import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../location/location.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _notifications = false;
  bool _locations = false;
  String? _schedule;

  void _logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _setNotifications(bool value) async {
    _notifications = value;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (!value) {
        _schedule = null;
        prefs.remove('schedule');
        AwesomeNotifications().cancelAllSchedules();
      }
      prefs.setBool("notifications", value);
    });
  }

  void _setLocations(bool value) async {
    if (value == true) {
      try {
        await Location.checkPermissions();
      } catch(e) {
        return;
      }
    }
    _locations = value;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool("locations", value);
    });
  }

  void _setSchedule() async {
    List<String> schedule = _schedule?.split(':') ?? [];
    TimeOfDay? selectedTime = await showTimePicker(
      initialTime: _schedule == null
          ?
      TimeOfDay.now()
          :
      TimeOfDay(hour: int.parse(schedule[0]), minute: int.parse(schedule[1])),
      context: context,
    );
    if (selectedTime == null) return;
    final now = DateTime.now();
    DateTime referenceTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
    AwesomeNotifications().cancelAllSchedules();
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: (DateTime.now().millisecondsSinceEpoch / 10000).round(),
            channelKey: 'mood_reminders',
            title: r"""How's your mood?""",
            body: 'Tap to add your mood to moodalyse.',
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
        ),
      schedule: NotificationAndroidCrontab.minutely(referenceDateTime: referenceTime, allowWhileIdle: true)
    );
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _schedule = selectedTime.format(context);
      prefs.setString("schedule", selectedTime.format(context));
    });
  }

  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = (prefs.getBool('notifications') ?? false);
      _locations = (prefs.getBool('locations') ?? false);
      _schedule = prefs.getString('schedule');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            ListTile(
              title: const Text('Log out from Moodalyse'),
              leading: const Icon(Icons.logout),
              trailing: ElevatedButton(
                onPressed: _logOut,
                child: const Text('Log out'),
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            SwitchListTile(
                title: const Text('Mood locations'),
                value: _locations,
                secondary: const Icon(Icons.location_on),
                onChanged: _setLocations
            ),
            const Divider(
              height: 10,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            SwitchListTile(
              title: const Text('Daily reminders'),
              value: _notifications,
              secondary: const Icon(Icons.notifications),
              onChanged: _setNotifications
            ),
            ListTile(
              title: const Text('Daily reminder time'),
              leading: const Icon(Icons.schedule),
              trailing: ElevatedButton(
                onPressed: _notifications ? _setSchedule : null,
                child: Text('Schedule' + (_schedule != null ? 'd - ' : '') + (_schedule ?? '')),
              ),
            )
          ],
        )
    );
  }

}
