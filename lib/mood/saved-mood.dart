import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moodalyse/mood/mood.dart';

import '../location/location.dart';

class SavedMood {
  SavedMood(this.mood, this.note, this.timestamp, this.location);

  SavedMood.fromJson(Map<String, Object?> json)
      : this (
      Mood.fromJson(json['mood'] as Map<String, Object?>),
      json['note'] as String,
      json['timestamp'] as Timestamp,
      Location.fromJson(json['location'] as Map<String, Object?>?),
  );

  final Mood mood;
  final String note;
  final Timestamp timestamp;
  Location? location;

  void remove() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    QuerySnapshot docs = await FirebaseFirestore.instance
        .collection(user.uid)
        .where('timestamp', isEqualTo: timestamp)
        .get();
    for (var element in docs.docs) {
      element.reference.delete();
    }
  }

  Map<String, Object?> toJson() {
    Map<String, Object?> object = {
      'mood': mood.toJson(),
      'note': note,
      'timestamp': timestamp,
    };
    if (location != null) {
      object['location'] = location?.toJson();
    }
    return object;
  }
}
