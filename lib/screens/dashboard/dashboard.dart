import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moodalyse/helpers/date-helpers.dart';
import 'package:moodalyse/mood/mood-card.dart';
import 'package:moodalyse/screens/dashboard/current-mood.dart';
import 'package:moodalyse/mood/mood.dart';
import 'package:moodalyse/mood/saved-mood.dart';

import '../../location/location.dart';
import 'add-mood.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Mood _averageMood = Mood('No data', -5);
  final TextEditingController _noteController = TextEditingController();
  late StreamSubscription<QuerySnapshot> _moodStream;
  final List<SavedMood> _dailyMoods = [];

  void _addMood(SavedMood mood) async {
    Location? location = await Location.now();
    if (location != null) mood.location = location;

    _noteController.clear();

    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    CollectionReference moods = firestore.collection(user.uid);

    moods.add(mood.toJson());

    AwesomeNotifications().dismissAllNotifications();

    setState(() {
      _averageMood = mood.mood;
      _averageMood
          .getIcon()
          .size;
    });
  }

  StreamSubscription<QuerySnapshot<Object>> _watchMoods(String uid) {
    return FirebaseFirestore.instance
        .collection(uid)
        .where('timestamp',
        isGreaterThanOrEqualTo: DateTime.now().getLastMidnight())
        .snapshots()
        .listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        Map<String, dynamic> rawData = change.doc.data() ?? {};
        final SavedMood savedMood = SavedMood.fromJson(
            rawData.map((key, value) => MapEntry(key, value as Object?)));

        final index = _dailyMoods
            .indexWhere((element) => element.timestamp == savedMood.timestamp);
        setState(() {
          if (index >= 0 && change.type == DocumentChangeType.modified) {
            _dailyMoods[index] = savedMood;
          } else if (change.type == DocumentChangeType.added) {
            _dailyMoods.add(savedMood);
          } else if (index >= 0 && change.type == DocumentChangeType.removed) {
            _dailyMoods.removeAt(index);
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _moodStream = _watchMoods(user.uid);
    });
  }

  @override
  void dispose() {
    _moodStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _dailyMoods.length + 2,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == 0) {
          return CurrentMood(current: _dailyMoods.map((e) => e.mood));
        } else if (index == 1) {
          return AddMood(
              onPressed: (SavedMood mood) {
                if (mood.note.isEmpty) {
                  showConfirmDialog(context, mood);
                } else {
                  _addMood(mood);
                }
              },
              noteController: _noteController);
        }
        index -= 2;
        SavedMood saved = _dailyMoods[index];
        return MoodCard(
            savedMood: saved,
        );
      },
    );
  }

  // TODO move this dialog and logic to add-mood
  showConfirmDialog(BuildContext context, SavedMood mood) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop();
        _addMood(mood);
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Mood without note"),
      content: const Text("Are you sure you want to add a mood without note?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
