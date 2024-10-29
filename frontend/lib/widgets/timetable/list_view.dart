import 'package:collection/collection.dart';
import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/widgets/timetable/event_card.dart';
import 'package:dashbaord/widgets/timetable/scroll_to_today_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListViewScreen extends StatefulWidget {
  final BuildContext context;
  final Timetable? timetable;

  const ListViewScreen(
      {super.key, required this.context, required this.timetable});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> convertTimetableToEvents(List<Lecture> lectures) {
    final now = DateTime.now();
    int month;
    if (now.month >= 1 && now.month <= 4) {
      month = 5;
    } else if (now.month >= 8 && now.month <= 11) {
      month = 12;
    } else {
      month = now.month;
    }

    DateTime endDate = DateTime(now.year, month, 5);
    final events = <Map<String, dynamic>>[];

    final Map<String, int> dayToWeekday = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    for (var lecture in lectures) {
      int? targetWeekday = dayToWeekday[lecture.day];

      int daysToAdd = (targetWeekday! - now.weekday) % 7;
      if (daysToAdd < 0) {
        daysToAdd += 7;
      }

      DateTime nextOccurrence = now.add(Duration(days: daysToAdd));

      while (nextOccurrence.isBefore(endDate) ||
          nextOccurrence.isAtSameMomentAs(endDate)) {
        events.add({
          "title": lecture.courseCode,
          "date": nextOccurrence,
          "time": "${lecture.startTime} - ${lecture.endTime}",
          "description": widget.timetable!.courses[lecture.courseCode]!,
          "type": "class"
        });

        nextOccurrence = nextOccurrence.add(Duration(days: 7));
      }
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    final events = convertTimetableToEvents(widget.timetable!.slots);

    events.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    events.sort((a, b) {
      int dateComparison =
          (a['date'] as DateTime).compareTo(b['date'] as DateTime);
      if (dateComparison != 0) {
        return dateComparison;
      }

      String aStartTime = a['time'].split(' - ')[0].trim();
      String bStartTime = b['time'].split(' - ')[0].trim();

      DateTime aStartDateTime = DateFormat('h:mm a').parse(aStartTime);
      DateTime bStartDateTime = DateFormat('h:mm a').parse(bStartTime);

      return aStartDateTime.compareTo(bStartDateTime);
    });

    final groupedEvents =
        groupBy(events, (event) => event['date'].toString().split(' ')[0]);

    void scrollToToday() {
      debugPrint(Theme.of(context).canvasColor.toString());

      final todayKey = DateTime.now().toString().split(' ')[0];
      final index =
          groupedEvents.keys.toList().indexWhere((date) => date == todayKey);

      if (index != -1) {
        double position = 0;
        for (int i = 0; i < index; i++) {
          position +=
              (groupedEvents[groupedEvents.keys.elementAt(i)]!.length + 1) *
                  50.0;
        }

        _scrollController.animateTo(
          position,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    String getFormattedDate(String dateKey) {
      final DateTime date = DateTime.parse(dateKey);
      final DateTime now = DateTime.now();

      final int difference = DateTime(date.year, date.month, date.day)
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;

      switch (difference) {
        case 0:
          return "Today";
        case 1:
          return "Tomorrow";
        case -1:
          return "Yesterday";
        default:
          return DateFormat('E, MMM d, yyyy').format(date);
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: groupedEvents.keys.length,
            itemBuilder: (context, index) {
              final dateKey = groupedEvents.keys.elementAt(index);
              final eventList = groupedEvents[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, bottom: 12.0, top: 12),
                    child: Row(
                      children: [
                        Text(
                          getFormattedDate(dateKey),
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleSmall?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.3), // Soft divider color
                            thickness: 0.8,
                            indent: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...eventList.map((event) {
                    return EventCard(
                      title: event['title'] as String,
                      time: event['time'] as String,
                      description: event['description'] as String,
                      type: event['type'] as String,
                    );
                  }),
                ],
              );
            },
          ),
          TodayButton(onPressed: scrollToToday),
        ],
      ),
    );
  }
}
