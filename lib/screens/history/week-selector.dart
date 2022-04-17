import 'package:flutter/material.dart';
import 'package:moodalyse/helpers/date-helpers.dart';

typedef OnSelectWeekCallback = void Function(DateTime weekStart);

class WeekSelector extends StatefulWidget {
  const WeekSelector({Key? key, required this.weekCallback}) : super(key: key);
  final OnSelectWeekCallback weekCallback;

  @override
  State<StatefulWidget> createState() => _WeekSelectorState();
}

class _WeekSelectorState extends State<WeekSelector> {
  DateTime currentWeek = DateTime.now().getStartOfWeek();
  DateTime _selectedWeek = DateTime.now().getStartOfWeek();

  void _increaseWeek() {
    setState(() {
      _selectedWeek = _selectedWeek.add(const Duration(days: 7));
      widget.weekCallback(_selectedWeek);
    });
  }

  void _decreaseWeek() {
    setState(() {
      _selectedWeek = _selectedWeek.subtract(const Duration(days: 7));
      widget.weekCallback(_selectedWeek);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.calendar_month),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  SizedBox(
                    width: 35,
                    child: TextButton(
                      onPressed: _decreaseWeek,
                      child: const Icon(Icons.chevron_left),
                    ),
                  ),
                  SizedBox(
                    width: 35,
                    child: TextButton(
                      onPressed: _selectedWeek == currentWeek ? null : _increaseWeek,
                      child: const Icon(Icons.chevron_right),
                    ),
                  ),
                ],
              ),
            ),
            title: Text(_selectedWeek.toLocaleDateString(context) +
                '\n' +
                _selectedWeek.add(const Duration(days: 6)).toLocaleDateString(context)),
          ),
        ],
      ),
    );
  }
}
