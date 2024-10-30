import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

class DayViewScreen extends StatefulWidget {
  final Timetable? timetable;
  final DateTime? initialDate;

  final BuildContext context;

  const DayViewScreen(
      {super.key,
      required this.context,
      required this.timetable,
      this.initialDate});

  @override
  State<DayViewScreen> createState() => _DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen> {
  final key = GlobalKey<DayViewState>();

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
            description: widget.timetable!.courses[lecture.courseCode]!,
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
        convertTimetableToCalendarEvents(widget.timetable!.slots);
    DateTime currentDate = widget.initialDate ?? DateTime.now();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          child: DatePicker(
            currentDate,
            initialSelectedDate: currentDate,
            selectionColor: Theme.of(context).cardColor,
            selectedTextColor: Colors.redAccent,
            deactivatedColor: Theme.of(context).textTheme.bodyMedium!.color!,
            dateTextStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            dayTextStyle: GoogleFonts.inter(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500,
            ),
            monthTextStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onDateChange: (date) {
              key.currentState?.animateToDate(date);
              setState(() {
                currentDate = date;
              });
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Expanded(
          child: DayView(
            key: key,
            controller: EventController()..addAll(events),
            backgroundColor: Theme.of(context).canvasColor,
            heightPerMinute: 1,
            showVerticalLine: false,
            initialDay: currentDate,
            keepScrollOffset: true,
            startDuration: Duration(hours: 8),
            liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
              color: Theme.of(context).textTheme.bodyLarge!.color!,
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
          ),
        ),
      ],
    );
  }
}
