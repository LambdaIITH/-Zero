import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/widgets/timetable/scroll_to_today_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';

class MonthViewScreen extends StatefulWidget {
  final BuildContext context;
  final Timetable? timetable;
  final Function(DateTime) onDayPressed;

  const MonthViewScreen(
      {super.key,
      required this.context,
      required this.timetable,
      required this.onDayPressed});

  @override
  State<MonthViewScreen> createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToToday() {
    DateTime today = DateTime.now();
    double offset = today.day * 1;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> countEventsForWeekdays(List<Lecture> lectures) {
      final eventCounts = <String, int>{
        'Monday': 0,
        'Tuesday': 0,
        'Wednesday': 0,
        'Thursday': 0,
        'Friday': 0,
        'Saturday': 0,
        'Sunday': 0,
      };

      for (var lecture in lectures) {
        if (eventCounts.containsKey(lecture.day)) {
          eventCounts[lecture.day] = eventCounts[lecture.day]! + 1;
        }
      }

      return eventCounts;
    }

    Map<String, int> lectureCountEachWeekday =
        countEventsForWeekdays(widget.timetable!.slots);

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Stack(
        children: [
          PagedVerticalCalendar(
            minDate: DateTime.now().subtract(Duration(days: 30)),
            scrollController: _scrollController,
            addAutomaticKeepAlives: true,
            startWeekWithSunday: true,
            monthBuilder: (context, month, year) {
              final formattedMonth =
                  DateFormat('MMMM yyyy').format(DateTime(year, month));
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  formattedMonth,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              );
            },
            dayBuilder: (context, date) {
              double maxOpacity = 0.8;
              double minOpacity = 0.1;
              int maxLectures = 5;
              int lectureCount =
                  lectureCountEachWeekday[DateFormat('EEEE').format(date)]!;
              double opacity = (lectureCount / maxLectures).clamp(0, 1) *
                      (maxOpacity - minOpacity) +
                  minOpacity;
              Color backgroundColor = lectureCount > 0
                  ? const Color.fromARGB(255, 255, 86, 74).withOpacity(opacity)
                  : Theme.of(context).cardColor;

              bool isToday = DateTime.now().day == date.day &&
                  DateTime.now().month == date.month &&
                  DateTime.now().year == date.year;

              return Container(
                margin: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: isToday ? Colors.blueAccent : backgroundColor,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Color.fromRGBO(51, 51, 51, 0.10),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isToday
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
            onDayPressed: (date) {
              widget.onDayPressed(date);
            },
          ),
          TodayButton(onPressed: _scrollToToday),
        ],
      ),
    );
  }
}
