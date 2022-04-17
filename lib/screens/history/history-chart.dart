import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moodalyse/mood/saved-mood.dart';

import '../../mood/mood.dart';

typedef OnSelectDayCallback = void Function(int day);

class HistoryChart extends StatefulWidget {
  const HistoryChart({Key? key, required this.history, required this.selectDay})
      : super(key: key);

  final List<SavedMood> history;
  final OnSelectDayCallback selectDay;

  @override
  State<StatefulWidget> createState() => _HistoryChartState();
}

class _HistoryChartState extends State<HistoryChart> {
  static const double barWidth = 22;
  int touchedIndex = -1;
  List<BarChartGroupData> _groups = [];

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.black, fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mon';
        break;
      case 1:
        text = 'Tue';
        break;
      case 2:
        text = 'Wed';
        break;
      case 3:
        text = 'Thu';
        break;
      case 4:
        text = 'Fri';
        break;
      case 5:
        text = 'Sat';
        break;
      case 6:
        text = 'Sun';
        break;
      default:
        return Container();
    }
    return Center(child: Text(text, style: style));
  }

  Widget getAxisTitles(double value, TitleMeta meta) {
    Icon icon = Mood.getMood(value.round()).getIcon();
    return Icon(icon.icon, color: Colors.pink);
  }

  List<BarChartGroupData> generateGroups() {
    List<BarChartGroupData> groups = [];
    for (var day = 1; day < 8; day++) {
      Iterable<SavedMood> dailyMoods = widget.history
          .where((element) => element.timestamp.toDate().weekday == day);
      double value = Mood.getAverageIndex(dailyMoods.map((e) => e.mood));
      int x = day - 1;
      if (dailyMoods.isEmpty) {
        print(day);
        widget.history.forEach((element) { print("WEEKDAY " + element.timestamp.toDate().weekday.toString() ); });
      }

      if (value < -2) value = 0;
      bool isTop = value > 0;

      final isTouched = touchedIndex == x;

      BorderRadius borderRadius = isTop
          ? const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            )
          : const BorderRadius.only(
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
            );

      if (value == 0) {
        borderRadius = const BorderRadius.all(Radius.circular(6));
      }

      double fromY = value == 0 ? -0.2 : (isTop ? -0.015 : 0.015);
      double toY = value == 0 && dailyMoods.isNotEmpty ? 0.2 : value;
      if (dailyMoods.isEmpty) {
        fromY = 0;
        toY = 0;
      }
      groups.add(BarChartGroupData(
        x: x,
        groupVertically: true,
        showingTooltipIndicators: isTouched && (toY != 0 && fromY != 0) ? [0] : [],
        barRods: [
          BarChartRodData(
            toY: toY,
            fromY: fromY,
            width: barWidth,
            color: isTouched ? Colors.amber : Colors.pinkAccent,
            borderRadius: borderRadius,
          ),
        ],
      ));
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _groups = generateGroups();
    });
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: 2,
              minY: -2,
              groupsSpace: 13,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey.shade200,
                    fitInsideVertically: true,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        Mood.getMood(rod.toY.round()).name,
                        const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                handleBuiltInTouches: false,
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      barTouchResponse == null ||
                      barTouchResponse.spot == null) {
                    setState(() {
                      // touchedIndex = -1;
                    });
                    return;
                  }
                  setState(() {
                    int x = barTouchResponse.spot?.touchedBarGroupIndex ?? 0;
                    widget.selectDay(x + 1);
                    touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  });
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: getTitles,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: getTitles,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getAxisTitles,
                    interval: 1,
                    reservedSize: 42,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getAxisTitles,
                    interval: 1,
                    reservedSize: 42,
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                checkToShowHorizontalLine: (value) => value == 0,
                getDrawingHorizontalLine: (value) {
                  if (value == 0) {
                    return FlLine(color: Colors.pinkAccent, strokeWidth: 2);
                  }
                  return FlLine(
                    color: Colors.grey.shade600,
                    strokeWidth: 0.8,
                  );
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              barGroups: _groups,
            ),
          ),
        ),
      ),
    );
  }
}
