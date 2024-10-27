import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';

DateTime get _now => DateTime.now();

class DayViewScreen extends StatelessWidget {
  final BuildContext context;

  DayViewScreen({super.key, required this.context});

  final List<CalendarEventData> _events = [
    CalendarEventData(
      date: _now,
      title: "LSSP",
      description: "LHC 4",
      startTime: DateTime(_now.year, _now.month, _now.day, 14, 30),
      endTime: DateTime(_now.year, _now.month, _now.day, 16),
    ),
    CalendarEventData(
      date: _now,
      startTime: DateTime(_now.year, _now.month, _now.day, 16),
      endTime: DateTime(_now.year, _now.month, _now.day, 17, 30),
      title: "Statistical Analysis using R",
      description: "LHC 9",
    ),
    CalendarEventData(
      date: _now.add(Duration(days: 1)),
      startTime: DateTime(_now.year, _now.month, _now.day, 18),
      endTime: DateTime(_now.year, _now.month, _now.day, 19),
      title: "Wedding anniversary",
      description: "Attend uncle's wedding anniversary.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DayView(
      controller: EventController()..addAll(_events),
      backgroundColor: Theme.of(context).canvasColor,
      heightPerMinute: 1,
      showVerticalLine: false,
      initialDay: _now,
      keepScrollOffset: true,
      startDuration: Duration(hours: 8),
      headerStyle: HeaderStyle(
        headerTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade800,
              width: 1,
            ),
          ),
        ),
      ),
      dayTitleBuilder: (date) {
        return Container();
      },
      timeLineBuilder: (date) {
        return Container(
          width: 60,
          alignment: Alignment.center,
          child: Text(
            DateFormat('h a').format(date),
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
      eventTileBuilder: (date, events, rect, startTime, endTime) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(8),
          height: 80, // Set your desired height here
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                events[0].title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (events[0].description != null)
                Text(
                  events[0].description!,
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        );
      },
      onEventTap: (event, date) {
        debugPrint(Theme.of(context).canvasColor.toString());
      },
    );
  }
}
