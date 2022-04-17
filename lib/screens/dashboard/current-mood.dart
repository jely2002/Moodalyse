import 'package:flutter/material.dart';

import '../../mood/mood.dart';

class CurrentMood extends StatefulWidget {
  CurrentMood({Key? key, required this.current}) : super(key: key);
  Iterable<Mood> current;

  @override
  State<StatefulWidget> createState() => _CurrentMoodState();
}

class _CurrentMoodState extends State<CurrentMood> {
  @override
  Widget build(BuildContext context) {
     final Mood mood = Mood.getAverage(widget.current);
     final IconData iconData = mood.getIcon().icon ?? Icons.question_mark;

    return Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5,
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                children: [
              const Text(r"""Today's average mood""",
                  style: TextStyle(
                      fontSize: 15.0, fontWeight: FontWeight.w500)),
              Column(
                children: [
                  Icon(
                    iconData,
                    size: 100,
                    color: Colors.pinkAccent,
                  ),
                  Text(
                    mood.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.pinkAccent,
                    ),
                  ),
                ],
              )
            ])
        )
    );
  }

}
