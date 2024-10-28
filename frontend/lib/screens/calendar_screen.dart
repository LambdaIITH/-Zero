import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/widgets/timetable/add_lectures_sheet.dart';
import 'package:dashbaord/widgets/timetable/day_view.dart';
import 'package:dashbaord/widgets/timetable/list_view.dart';
import 'package:dashbaord/widgets/timetable/month_view.dart';
import 'package:dashbaord/widgets/timetable/week_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:share_plus/share_plus.dart';

class CalendarScreen extends StatefulWidget {
  final Timetable? timetable;
  const CalendarScreen({super.key, required this.timetable});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String selectedViewType = "List";
  List<String> viewTypeList = ["List", "Day", "Week", "Month"];

  final List<CalendarEventData> _events = [];

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
              constraints: BoxConstraints(
                minHeight: 40.0,
                minWidth: MediaQuery.of(context).size.width * 2 / 9,
              ),
              children: viewTypeList.map((String viewType) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    viewType,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: viewType == selectedViewType
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _getCurrentView(context),
              ),
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

  Widget _getCurrentView(BuildContext context) {
    switch (selectedViewType) {
      case "List":
        return ListViewScreen(
          context: context,
          timetable: widget.timetable,
        );
      case "Day":
        return DayViewScreen(
          context: context,
          timetable: widget.timetable,
        );
      case "Week":
        return WeekViewScreen(
          context: context,
          timetable: widget.timetable,
        );
      case "Month":
        return MonthViewScreen(
          context: context,
          timetable: widget.timetable,
        );
      default:
        return DayViewScreen(
          context: context,
          timetable: widget.timetable,
        );
    }
  }

  void _showAddEventBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddLectureBottomSheet();
        // return const AddEventBottomSheet();
      },
      isScrollControlled: true,
    );
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
            backgroundColor: Colors.red,
            child: Icon(
              Icons.ios_share,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: 64,
          height: 64,
          child: FloatingActionButton(
            onPressed: () {
              _showAddEventBottomSheet(context);
            },
            backgroundColor: Colors.red,
            child: Icon(
              CupertinoIcons.add,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }

  void _shareSchedule() {
    String eventList = _events.join('\n');
    Share.share('Here is my schedule: \n$eventList');
  }
}
