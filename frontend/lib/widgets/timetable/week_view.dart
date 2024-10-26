import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';

DateTime get _now => DateTime.now();

class WeekViewScreen extends StatelessWidget {
  WeekViewScreen({Key? key}) : super(key: key);

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
    return WeekView(
      controller: EventController()..addAll(_events),
      startDay: WeekDays.sunday,
      keepScrollOffset: true,
      scrollOffset: 450,
      backgroundColor: Colors.black,
      headerStringBuilder: (date, {secondaryDate}) {
        String startDate = DateFormat('d MMM').format(date);
        String endDate = DateFormat('d MMM').format(secondaryDate ?? date);

        return "$startDate - $endDate ${date.year}";
      },
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
      eventTileBuilder: (date, events, rect, startTime, endTime) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(8),
          width: rect.width,
          height: rect.height,
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
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 10,
                  overflow: TextOverflow.ellipsis,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
      onEventTap: (event, date) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(date.toIso8601String()),
        ));
      },
    );
  }
}
