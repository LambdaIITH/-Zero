import 'package:calendar_view/calendar_view.dart';
import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime get _now => DateTime.now();

class WeekViewScreen extends StatelessWidget {
  final BuildContext context;
  final Timetable? timetable;

  WeekViewScreen({super.key, required this.context, required this.timetable});

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
            date: date, // Optional, based on your requirements
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
    return WeekView(
      controller: EventController()..addAll(events),
      startDay: WeekDays.sunday,
      keepScrollOffset: true,
      scrollOffset: 450,
      backgroundColor: Theme.of(context).canvasColor,
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
      weekPageHeaderBuilder: (startDate, fromDate) {
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
          padding: const EdgeInsets.all(2),
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
                  fontSize: 12,
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
