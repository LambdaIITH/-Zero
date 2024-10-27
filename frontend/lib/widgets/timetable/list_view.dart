import 'package:collection/collection.dart';
import 'package:dashbaord/widgets/timetable/event_card.dart';
import 'package:dashbaord/widgets/timetable/scroll_to_today_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListViewScreen extends StatefulWidget {
  final BuildContext context;

  const ListViewScreen({super.key, required this.context});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final events = [
      {
        "title": "Numerical Analysis",
        "date": DateTime.now().subtract(Duration(days: 1)),
        "time": "10:00 AM - 11:00 AM",
        "description": "Discuss project updates."
      },
      {
        "title": "Real Analysis",
        "date": DateTime.now().subtract(Duration(days: 1)),
        "time": "2:00 PM - 4:00 PM",
        "description": "Flutter advanced concepts."
      },
      {
        "title": "Climate Change",
        "date": DateTime.now().add(Duration(days: 1)),
        "time": "7:30 PM - 9:00 PM",
        "description": "Restaurant XYZ."
      },
      {
        "title": "Probability Theory",
        "date": DateTime.now().add(Duration(days: 1)),
        "time": "4:00 PM - 5:00 PM",
        "description": "Catch up at the cafe."
      },
      {
        "title": "Epoch Session",
        "date": DateTime.now().add(Duration(days: 2)),
        "time": "6:00 PM - 7:00 PM",
        "description": "Weekly grocery shopping."
      },
      {
        "title": "Algebra",
        "date": DateTime.now().add(Duration(days: 3)),
        "time": "9:00 AM - 10:00 AM",
        "description": "Solve linear equations."
      },
      {
        "title": "Geometry",
        "date": DateTime.now().add(Duration(days: 3)),
        "time": "1:00 PM - 2:30 PM",
        "description": "Discuss angles and shapes."
      },
      {
        "title": "Data Structures",
        "date": DateTime.now().add(Duration(days: 4)),
        "time": "3:00 PM - 4:30 PM",
        "description": "Implement linked lists."
      },
      {
        "title": "Operating Systems",
        "date": DateTime.now().add(Duration(days: 4)),
        "time": "6:00 PM - 8:00 PM",
        "description": "Process scheduling algorithms."
      },
      {
        "title": "New Event 1",
        "date": DateTime.now(),
        "time": "9:00 AM - 10:00 AM",
        "description": "Discuss new project."
      },
      {
        "title": "New Event 2",
        "date": DateTime.now(),
        "time": "2:00 PM - 3:00 PM",
        "description": "Meeting with team."
      },
    ];

    events.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

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
                  10.0;
        }

        _scrollController.animateTo(
          position,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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

              // Formatting the date
              final formattedDate =
                  DateFormat('E, MMM d, yyyy').format(DateTime.parse(dateKey));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(100.0),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(
                                51, 51, 51, 0.10), // Shadow color
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 12.0),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  ...eventList.map((event) {
                    return EventCard(
                        title: event['title'] as String,
                        time: event['time'] as String,
                        description: event['description'] as String);
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
