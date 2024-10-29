import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/widgets/timetable/manage_lectures_sheet.dart';
import 'package:flutter/material.dart';

class ManageCoursesBottomSheet extends StatefulWidget {
  final Timetable? timetable;
  final Function(Timetable)? onEditTimetable;

  const ManageCoursesBottomSheet({
    super.key,
    required this.timetable,
    required this.onEditTimetable,
  });

  @override
  State<ManageCoursesBottomSheet> createState() =>
      _ManageCoursesBottomSheetState();
}

class _ManageCoursesBottomSheetState extends State<ManageCoursesBottomSheet> {
  late Timetable timetable;

  void _showManageLecturesBottomSheet(
      BuildContext context, String courseCode, String courseName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ManageLecturesBottomSheet(
            courseCode: courseCode,
            courseName: courseName,
            courseSlots: timetable.getSlotsForCourse(courseCode),
            onLectureEdited: (courseCode, courseName, lecturelist) {
              // Step 1: Remove all slots associated with the given courseCode
              timetable.slots
                  .removeWhere((slot) => slot.courseCode == courseCode);

              // Step 2: Add the provided lecture list to the slots list
              timetable.slots.addAll(lecturelist);

              // Step 3: Update the course name in the courses map
              timetable.courses[courseCode] = courseName;

              // Step 4: Notify the framework of state changes
              setState(() {});
            });
      },
      isScrollControlled: true,
    );
  }

  @override
  void initState() {
    super.initState();
    timetable = Timetable(
      courses: Map<String, String>.from(widget.timetable?.courses ?? {}),
      slots: List<Lecture>.from(widget.timetable?.slots ?? []),
    );
  }

  void _removeCourse(String courseCode) {
    setState(() {
      timetable.courses.remove(courseCode);
      timetable.slots
          .removeWhere((lecture) => lecture.courseCode == courseCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      elevation: 12,
      color: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.circular(25), // Add border radius here
      shadowColor: Colors.white.withOpacity(0.3),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Theme.of(context).canvasColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Manage Courses",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Stack(
                children: [
                  ConstrainedBox(
                    // limit the bottom sheet to 45% of the screen height
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.45,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: timetable.courses.length + 1,
                      itemBuilder: (context, index) {
                        if (index == timetable.courses.length) {
                          return SizedBox(height: 35);
                        }
                        final courseCode =
                            timetable.courses.keys.elementAt(index);
                        final courseName = timetable.courses[courseCode];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 4),
                          child: Card(
                            elevation: 3,
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  courseCode.substring(0, 2),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                courseName ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              subtitle: Text(
                                "Code: $courseCode",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showManageLecturesBottomSheet(context,
                                          courseCode, courseName ?? '');
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      _removeCourse(courseCode);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).canvasColor == Colors.white
                                  ? const Color.fromARGB(100, 255, 255, 255)
                                  : Colors.transparent,
                              Theme.of(context).canvasColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onEditTimetable != null) {
                      widget.onEditTimetable!(timetable);
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white, // Button color
                  ),
                  icon: Icon(Icons.check), // Leading icon
                  label: Text(
                    "Save",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
