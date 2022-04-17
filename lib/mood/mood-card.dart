import 'package:flutter/material.dart';
import 'package:moodalyse/helpers/date-helpers.dart';
import 'package:moodalyse/mood/saved-mood.dart';

class MoodCard extends  StatefulWidget {
  const MoodCard({Key? key, required this.savedMood }) :  super(key: key);
  final SavedMood savedMood;

  @override
  State<StatefulWidget> createState() => _MoodCardState();
}

class _MoodCardState extends State<MoodCard> {
  @override
  Widget build(BuildContext context) {
    SavedMood saved = widget.savedMood;
    String note = saved.note.isEmpty ? 'No note available' : saved.note;
    return Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: saved.mood.getIcon(50),
                title: Text(
                    saved.timestamp.toDate().toLocaleTimeString() +
                        " - " +
                        saved.mood.name),
                subtitle:
                Text(note + '\n' + (saved.location?.name ?? "No location")),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('Remove'),
                    onPressed: () {
                      saved.remove();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        )
    );
  }
}
