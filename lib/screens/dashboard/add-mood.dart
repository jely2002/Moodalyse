import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moodalyse/mood/saved-mood.dart';

import '../../mood/mood-button.dart';
import '../../mood/mood.dart';

typedef OnAddMoodCallback = void Function(SavedMood mood);

class AddMood extends StatelessWidget {
  const AddMood({Key? key, required this.onPressed, required this.noteController}) : super(key: key);
  final OnAddMoodCallback onPressed;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    void _moodPressed(Mood mood) async {
      onPressed(SavedMood(mood, noteController.value.text, Timestamp.now(), null));
    }

    return Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                children: [
                  const Text('Add a mood to your day',
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500
                      )
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                    child: TextFormField(
                      controller: noteController,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      maxLength: 100,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Add a note'
                      ),
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  Wrap(
                    runSpacing: 5.0,
                    spacing: 1.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      MoodButton(onPressed: _moodPressed, moodIndex: -2),
                      MoodButton(onPressed: _moodPressed, moodIndex: -1),
                      MoodButton(onPressed: _moodPressed, moodIndex: 0),
                      MoodButton(onPressed: _moodPressed, moodIndex: 1),
                      MoodButton(onPressed: _moodPressed, moodIndex: 2),
                    ],
                  )
                ]
            )
        )
    );
  }

}
