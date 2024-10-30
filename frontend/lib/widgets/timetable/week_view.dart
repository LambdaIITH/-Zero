import 'package:calendar_view/calendar_view.dart';
import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WeekViewScreen extends StatefulWidget {
  final BuildContext context;
  final Timetable? timetable;

  const WeekViewScreen(
      {super.key, required this.context, required this.timetable});

  @override
  State<WeekViewScreen> createState() => _WeekViewScreenState();
}

class _WeekViewScreenState extends State<WeekViewScreen> {
  final weekkey = GlobalKey<WeekViewState>();

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
            description: widget.timetable!.courses[lecture.courseCode]!,
            startTime: startTime,
            endTime: endTime,
          ));
        }
      }
    }

    return events;
  }

  DateTime initialDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final List<CalendarEventData> events =
        convertTimetableToCalendarEvents(widget.timetable!.slots);

    return WeekView(
      key: weekkey,
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
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
        color: Theme.of(context).textTheme.bodyLarge!.color!,
      ),
      weekPageHeaderBuilder: (startDate, endDate) {
        final dateFormat = DateFormat('MMM dd');
        final String formattedStartDate = dateFormat.format(startDate);
        final String formattedEndDate = dateFormat.format(endDate);
        bool isCurrentWeek = (DateTime.now().isBefore(endDate) &&
            DateTime.now().isAfter(startDate));
        return WeekPageHeader(
            formattedStartDate: formattedStartDate,
            formattedEndDate: formattedEndDate,
            isCurrentWeek: isCurrentWeek,
            weekkey: weekkey);
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

class WeekPageHeader extends StatelessWidget {
  const WeekPageHeader({
    super.key,
    required this.formattedStartDate,
    required this.formattedEndDate,
    required this.isCurrentWeek,
    required this.weekkey,
  });

  final String formattedStartDate;
  final String formattedEndDate;
  final bool isCurrentWeek;
  final GlobalKey<WeekViewState<Object?>> weekkey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Week Overview",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "$formattedStartDate - $formattedEndDate",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isCurrentWeek ? FontWeight.w500 : FontWeight.w400,
                  color: isCurrentWeek
                      ? Colors.redAccent
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  debugPrint("CLICKED PREVIOUS");
                  weekkey.currentState?.animateToWeek(
                    weekkey.currentState!.currentDate.subtract(
                      Duration(days: 7),
                    ),
                  );
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              IconButton(
                onPressed: () {
                  debugPrint("CLICKED NEXT ${weekkey.currentState}");
                  weekkey.currentState?.animateToWeek(
                    weekkey.currentState!.currentDate.add(
                      Duration(days: 7),
                    ),
                  );
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
