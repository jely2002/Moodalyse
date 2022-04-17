import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moodalyse/helpers/date-helpers.dart';
import 'package:moodalyse/mood/saved-mood.dart';
import 'package:moodalyse/screens/history/history-chart.dart';
import 'package:moodalyse/screens/history/week-selector.dart';

import '../../mood/mood-card.dart';

class History extends StatefulWidget {
  const History({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final List<SavedMood> _history = [];
  List<SavedMood> _selectedMoods = [];
  int _selectedDay = 0;
  DateTime _week = DateTime.now().getStartOfWeek();
  late StreamSubscription<QuerySnapshot> _moodStream;

  void _setMoodsForDay(int day) {
    setState(() {
      _selectedDay = day;
      _selectedMoods = _history.where((element) => element.timestamp.toDate().weekday == day).toList();
    });
  }

  void _setWeek(DateTime weekStart) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _week = weekStart;
      _moodStream.cancel();
      _history.clear();
      _selectedMoods.clear();
      _moodStream = _watchHistory(user.uid);
    });
  }

  StreamSubscription<QuerySnapshot<Object>> _watchHistory(String uid) {
    return FirebaseFirestore.instance
        .collection(uid)
        .where('timestamp',
        isGreaterThanOrEqualTo: _week)
        .where('timestamp',
        isLessThan: _week.add(const Duration(days: 7)))
        .snapshots()
        .listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        Map<String, dynamic> rawData = change.doc.data() ?? {};
        final SavedMood savedMood = SavedMood.fromJson(
            rawData.map((key, value) => MapEntry(key, value as Object?)));

        final index = _history
            .indexWhere((element) => element.timestamp == savedMood.timestamp);
        setState(() {
          if (index >= 0 && change.type == DocumentChangeType.modified) {
            _history[index] = savedMood;
          } else if (change.type == DocumentChangeType.added) {
            _history.add(savedMood);
          } else if (index >= 0 && change.type == DocumentChangeType.removed) {
            _history.removeAt(index);
          }
          _setMoodsForDay(_selectedDay);
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
      _moodStream = _watchHistory(user.uid);
    });
  }

  @override
  void dispose() {
    _moodStream.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    int itemCount = _selectedMoods.length + 2;
    int indexAdjust = 2;
    if (_selectedMoods.isEmpty) {
      itemCount++;
      indexAdjust++;
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: itemCount,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == 0) {
          return WeekSelector(
            weekCallback: _setWeek,
          );
        } else if (index == 1) {
          return HistoryChart(
            history: _history,
            selectDay: _setMoodsForDay,
          );
        }
        if (_selectedMoods.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 20),
            child:
            Center(
              child: Text(
                'Tap on a bar to see your moods for that day.',
                style: TextStyle(
                  fontSize: 15,
                ),
             )
          )
          );
        }
        index -= indexAdjust;
        SavedMood saved = _selectedMoods[index];
        return MoodCard(
            savedMood: saved,
        );
      },
    );
  }
}
