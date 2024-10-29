import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';

DateTime get _now => DateTime.now();

class DayViewScreen extends StatelessWidget {
  final Timetable? timetable;

  final BuildContext context;

  const DayViewScreen(
      {super.key, required this.context, required this.timetable});

  List<CalendarEventData> convertTimetableToCalendarEvents(
      List<Lecture> lectures) {
    final now = DateTime.now();
    final events = <CalendarEventData>[];

    DateTime startDate = DateTime(now.year, now.month, now.day);

    int month;
    if (now.month >= 1 && now.month <= 4) {
      month = 5;
    } else if (now.month >= 8 && now.month <= 11) {
      month = 12;
    } else {
      month = now.month;
    }

    DateTime endDate = DateTime(now.year, month, 5);

    for (DateTime date = startDate;
        date.isBefore(endDate);
        date = date.add(Duration(days: 1))) {
      String dayName = DateFormat('EEEE').format(date);

      for (var lecture in lectures) {
        if (lecture.day == dayName) {
          DateTime startTime = DateTime(
            date.year,
            date.month,
            date.day,
            TimeOfDay.fromDateTime(
                    DateFormat('hh:mm a').parse(lecture.startTime))
                .hour,
            TimeOfDay.fromDateTime(
                    DateFormat('hh:mm a').parse(lecture.startTime))
                .minute,
          );

          DateTime endTime = DateTime(
            date.year,
            date.month,
            date.day,
            TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(lecture.endTime))
                .hour,
            TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(lecture.endTime))
                .minute,
          );

          events.add(CalendarEventData(
            date: date,
            title: lecture.courseCode,
            description: timetable!.courses[lecture.courseCode]!,
            startTime: startTime,
            endTime: endTime,
          ));
        }
      }
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    final List<CalendarEventData> events =
        convertTimetableToCalendarEvents(timetable!.slots);

    return DayView(
      controller: EventController()..addAll(events),
      backgroundColor: Theme.of(context).canvasColor,
      heightPerMinute: 1,
      showVerticalLine: false,
      initialDay: _now,
      keepScrollOffset: true,
      startDuration: Duration(hours: 8),
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
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: endTime.difference(startTime) > Duration(minutes: 40)
              ? EdgeInsets.all(8)
              : EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              if (events[0].description != null &&
                  endTime.difference(startTime) > Duration(minutes: 40))
                Text(
                  events[0].description!,
                  overflow: TextOverflow.fade,
                  maxLines:
                      endTime.difference(startTime) <= Duration(hours: 1)
                          ? 1
                          : 2,
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
