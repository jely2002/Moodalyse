import 'package:flutter/material.dart';

class Mood {
  Mood(this.name, this.index);

  static final List<Mood> moods = [
    Mood('Horrible', -2),
    Mood('Bad', -1),
    Mood('Neutral', 0),
    Mood('Good', 1),
    Mood('Excellent', 2),
  ];

  Mood.fromJson(Map<String, Object?> json)
      : this(
          json['name'] as String,
          json['index'] as int,
        );

  final String name;
  final int index;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'index': index,
    };
  }

  static Mood getMood(int index) {
    return moods.firstWhere((element) => element.index == index);
  }

  static Mood getAverage(Iterable<Mood> moods, [int defaultIndex = -5]) {
    if (moods.isEmpty) {
      return Mood('No data', defaultIndex);
    }
    int average = (moods
        .map((e) => e.index)
        .reduce((a, b) => a + b) / moods.length).round();
    return Mood.getMood(average);
  }

  static double getAverageIndex(Iterable<Mood> moods, [double defaultIndex = -5]) {
    if (moods.isEmpty) {
      return defaultIndex;
    }
    return (moods
        .map((e) => e.index)
        .reduce((a, b) => a + b) / moods.length);
  }

  Icon getIcon([double iconSize = 24]) {
    switch (index) {
      case -2:
        return Icon(Icons.sentiment_very_dissatisfied, size: iconSize);
      case -1:
        return Icon(Icons.sentiment_dissatisfied, size: iconSize);
      case -0:
        return Icon(Icons.sentiment_neutral, size: iconSize);
      case 1:
        return Icon(Icons.sentiment_satisfied, size: iconSize);
      case 2:
        return Icon(Icons.sentiment_very_satisfied, size: iconSize);
      default:
        return Icon(Icons.question_mark, size: iconSize);
    }
  }
}
