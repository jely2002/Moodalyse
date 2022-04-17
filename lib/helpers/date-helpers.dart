import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateHelpers on DateTime {
  DateTime getLastMidnight() {
    return DateTime(year, month, day);
  }
  DateTime getStartOfWeek() {
    final int currentDay = weekday;
    return subtract(Duration(days: currentDay - 1, hours: hour, minutes: minute, milliseconds: millisecond, microseconds: microsecond));
  }
  String toLocaleTimeString() {
    return DateFormat('HH:mm').format(this);
  }
  String toLocaleDateString(BuildContext context) {
    return const DefaultMaterialLocalizations().formatMediumDate(this);
  }
}
