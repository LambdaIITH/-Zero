import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/widgets/timetable/add_lectures_sheet.dart';
import 'package:dashbaord/widgets/timetable/day_view.dart';
import 'package:dashbaord/widgets/timetable/list_view.dart';
import 'package:dashbaord/widgets/timetable/manage_courses_sheet.dart';
import 'package:dashbaord/widgets/timetable/month_view.dart';
import 'package:dashbaord/widgets/timetable/week_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class CalendarScreen extends StatefulWidget {
  final Timetable? timetable;
  final Function(String, String, List<Lecture>)? onLectureAdded;
  final Function(Timetable)? onEditTimetable;

  const CalendarScreen({
    super.key,
    required this.timetable,
    required this.onLectureAdded,
    required this.onEditTimetable,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String selectedViewType = "List";
  List<String> viewTypeList = ["List", "Day", "Week", "Month"];
  Timetable? timetable;

  final List<CalendarEventData> _events = [];

  @override
  void initState() {
    super.initState();
    timetable = widget.timetable;
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController()..addAll(_events),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Calendar",
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),
          leadingWidth: 65,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "refresh") {
                } else if (value == "manageCourses") {
                  _showManageCoursesBottomSheet(context);
                } else if (value == "shareCode") {
                  _shareSchedule();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: "refresh",
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.redAccent),
                      SizedBox(width: 5),
                      Text("Refresh"),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: "manageCourses",
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.redAccent),
                      SizedBox(width: 5),
                      Text("Manage Courses"),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: "shareCode",
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.redAccent),
                      SizedBox(width: 5),
                      Text("Share Timetable"),
                    ],
                  ),
                ),
              ],
              icon: Icon(Icons.more_vert),
              color: Theme.of(context).cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
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
          timetable: timetable,
        );
      case "Day":
        return DayViewScreen(
          context: context,
          timetable: timetable,
        );
      case "Week":
        return WeekViewScreen(
          context: context,
          timetable: timetable,
        );
      case "Month":
        return MonthViewScreen(
          context: context,
          timetable: timetable,
        );
      default:
        return DayViewScreen(
          context: context,
          timetable: timetable,
        );
    }
  }

  void _showAddEventBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddLectureBottomSheet(
          timetable: widget.timetable,
          onLectureAdded: (courseCode, courseName, lectures) {
            setState(() {
              timetable =
                  timetable!.addCourse(courseCode, courseName, lectures);
            });
            widget.onLectureAdded!(courseCode, courseName, lectures);
          },
        );
        // return const AddEventBottomSheet();
      },
      isScrollControlled: true,
    );
  }

  void _showManageCoursesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ManageCoursesBottomSheet(
          timetable: timetable,
          onEditTimetable: (editedTimetable) {
            setState(() {
              timetable = editedTimetable;
            });
            widget.onEditTimetable!(editedTimetable);
          },
        );
      },
      isScrollControlled: true,
    );
  }

  Widget _buildFABs() {
    return SizedBox(
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
    );
  }

  void _shareSchedule() {
    // Convert the courses and their details to a string
    final courseDetails = timetable!.courses.entries.map((entry) {
      final code = entry.key;
      final name = entry.value;
      return '$code: $name';
    }).join('\n');

    String shareableLink =
        'https://dashboard.iith.dev/share/timetable/RANDOM_CODE';

    String shareMessage = '''
      I have registered for these courses:
$courseDetails

Click the link to add these courses to your timetable:
$shareableLink
    ''';

    Share.share(shareMessage);
  }
}
