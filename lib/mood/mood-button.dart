import 'package:flutter/material.dart';
import 'package:moodalyse/mood/mood.dart';

typedef OnPressedCallback = void Function(Mood mood);

class MoodButton extends StatefulWidget {
  const MoodButton({Key? key, required this.onPressed, required this.moodIndex, this.disabled = false }) : super(key: key);
  final OnPressedCallback onPressed;
  final int moodIndex;
  final bool disabled;

  @override
  State<StatefulWidget> createState() => _MoodButtonState();
}

class _MoodButtonState extends State<MoodButton> {

  @override
  Widget build(BuildContext context) {
    Mood mood = Mood.getMood(widget.moodIndex);
    return TextButton(
      onPressed: () { widget.onPressed(mood); },
      child: Column(
        children: [
          mood.getIcon(),
          Text(mood.name)
        ],
      ),
    );
  }
}
