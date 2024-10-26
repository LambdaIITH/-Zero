import 'package:dashbaord/widgets/timetable/day_view.dart';
import 'package:dashbaord/widgets/timetable/list_view.dart';
import 'package:dashbaord/widgets/timetable/month_view.dart';
import 'package:dashbaord/widgets/timetable/week_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:share_plus/share_plus.dart';

class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

DateTime get _now => DateTime.now();

class _TimeTableScreenState extends State<TimeTableScreen> {
  String selectedViewType = "List";
  List<String> viewTypeList = ["List", "Day", "Week", "Month"];

  final List<CalendarEventData> _events = [
    CalendarEventData(
      date: _now,
      title: "Project meeting",
      description: "Today is project meeting.",
      startTime: DateTime(_now.year, _now.month, _now.day, 18, 30),
      endTime: DateTime(_now.year, _now.month, _now.day, 22),
    ),
    CalendarEventData(
      date: _now.add(Duration(days: 1)),
      startTime: DateTime(_now.year, _now.month, _now.day, 18),
      endTime: DateTime(_now.year, _now.month, _now.day, 19),
      title: "Wedding anniversary",
      description: "Attend uncle's wedding anniversary.",
    ),
    CalendarEventData(
      date: _now,
      startTime: DateTime(_now.year, _now.month, _now.day, 14),
      endTime: DateTime(_now.year, _now.month, _now.day, 17),
      title: "Football Tournament",
      description: "Go to football tournament.",
    ),
    CalendarEventData(
      date: _now.add(Duration(days: 3)),
      startTime: DateTime(
          _now.add(Duration(days: 3)).year,
          _now.add(Duration(days: 3)).month,
          _now.add(Duration(days: 3)).day,
          10),
      endTime: DateTime(
          _now.add(Duration(days: 3)).year,
          _now.add(Duration(days: 3)).month,
          _now.add(Duration(days: 3)).day,
          14),
      title: "Sprint Meeting.",
      description: "Last day of project submission for last year.",
    ),
    CalendarEventData(
      date: _now.subtract(Duration(days: 2)),
      startTime: DateTime(
          _now.subtract(Duration(days: 2)).year,
          _now.subtract(Duration(days: 2)).month,
          _now.subtract(Duration(days: 2)).day,
          14),
      endTime: DateTime(
          _now.subtract(Duration(days: 2)).year,
          _now.subtract(Duration(days: 2)).month,
          _now.subtract(Duration(days: 2)).day,
          16),
      title: "Team Meeting",
      description: "Team Meeting",
    ),
    CalendarEventData(
      date: _now.subtract(Duration(days: 2)),
      startTime: DateTime(
          _now.subtract(Duration(days: 2)).year,
          _now.subtract(Duration(days: 2)).month,
          _now.subtract(Duration(days: 2)).day,
          10),
      endTime: DateTime(
          _now.subtract(Duration(days: 2)).year,
          _now.subtract(Duration(days: 2)).month,
          _now.subtract(Duration(days: 2)).day,
          12),
      title: "Chemistry Viva",
      description: "Today is Joe's birthday.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController()..addAll(_events),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Calendar",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 30,
              shadows: [
                Shadow(
                  offset: Offset(0, 1.5),
                  color: Colors.black,
                )
              ],
            ),
          ),
          leadingWidth: 65,
          leading: Builder(builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 40),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            );
          }),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 2,
            ),
            ToggleButtons(
              isSelected: viewTypeList
                  .map((viewType) => viewType == selectedViewType)
                  .toList(),
              onPressed: (int index) {
                setState(() {
                  selectedViewType =
                      viewTypeList[index]; // Update the selected view type
                });
              },
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: Colors.red,
              color: Colors.black,
              constraints: BoxConstraints(
                minHeight: 40.0,
                minWidth: MediaQuery.of(context).size.width * 2 / 9,
              ),
              children: viewTypeList.map((String viewType) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    viewType,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _getCurrentView(),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
        floatingActionButton: _buildFABs(),
      ),
    );
  }

  Widget _getCurrentView() {
    switch (selectedViewType) {
      case "List":
        return ListViewScreen();
      case "Day":
        return DayViewScreen();
      case "Week":
        return WeekViewScreen();
      case "Month":
        return MonthViewScreen();

      default:
        return DayViewScreen();
    }
  }

  Widget _buildFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: FloatingActionButton(
            onPressed: () {
              _shareSchedule();
            },
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.share),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: 64,
          height: 64,
          child: FloatingActionButton(
            onPressed: () {
              _showAddEventDialog();
            },
            backgroundColor: Colors.deepPurple,
            child: Icon(
              CupertinoIcons.add,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddEventDialog() {
  }

  void _shareSchedule() {
    String eventList = _events.join('\n');
    Share.share('Here is my schedule: \n$eventList');
  }
}
