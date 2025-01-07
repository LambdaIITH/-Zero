import 'package:dashbaord/models/lecture_search_model.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:flutter/material.dart';

class CourseSearchBottomSheet extends StatefulWidget {
  final Function(CourseModel)? onCourseSelect;

  const CourseSearchBottomSheet({super.key, required this.onCourseSelect});

  @override
  State<CourseSearchBottomSheet> createState() =>
      _CourseSearchBottomSheetState();
}

class _CourseSearchBottomSheetState extends State<CourseSearchBottomSheet> {
  final TextEditingController courseSearchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<CourseModel> foundCourses = [];
  CourseModel? selectedCourse;

  bool isSearching = false;

  List<CourseModel> allCourses = [];

  @override
  void initState() {
    super.initState();
    fetchAllCourses();

    Future.delayed(Duration(milliseconds: 0), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  Future<void> fetchAllCourses() async {
    final courses = await ApiServices().getAllCourses(context);

    if (courses != null) {
      setState(() {
        allCourses = courses;
      });
    } else {
      debugPrint("Failed to load courses.");
    }
  }

  Future<void> _searchCourses(String query) async {
    setState(() {
      isSearching = true;
      foundCourses.clear();
    });

    setState(() {
      foundCourses = allCourses
          .where((course) =>
              course.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      isSearching = false;
    });
  }

  void _selectCourse(CourseModel course) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Material(
        elevation: 12,
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 5),
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
              TextField(
                controller: courseSearchController,
                focusNode: _focusNode,
                onChanged: _searchCourses,
                decoration: InputDecoration(
                  labelText: 'Search Course',
                  focusColor: Colors.blueAccent,
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                      )),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      if (isSearching)
                        const Center(child: CircularProgressIndicator())
                      else if (foundCourses.isNotEmpty)
                        ...foundCourses.map((course) {
                          return courseCard(
                            context: context,
                            title: course.title,
                            courseCode: course.courseCode.toString(),
                            segment: course.segment,
                            credits: course.credits!.toString(),
                            slot: course.slot,
                            classroom: course.classroom,
                            instructor: course.instructor,
                            isSelected: selectedCourse == course,
                            onTap: () {
                              setState(() {
                                selectedCourse = course;
                              });
                            },
                          );
                        })
                      else if (courseSearchController.text.isNotEmpty)
                        const Text("No courses found."),
                    ],
                  ),
                ),
              ),
              selectedCourse != null
                  ? Container(
                      padding: const EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          if (selectedCourse != null) {
                            widget.onCourseSelect!(selectedCourse!);
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a course.'),
                                duration: const Duration(milliseconds: 1500),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget courseCard({
    required BuildContext context,
    required String title,
    required String courseCode,
    String? segment,
    String? credits,
    String? slot,
    String? classroom,
    String? instructor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    final isDarkMode = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: isSelected
              ? BorderSide(
                  color: isDarkMode
                      ? const Color.fromARGB(220, 255, 255, 255)
                      : const Color.fromARGB(150, 0, 0, 0),
                  width: isDarkMode ? 4.0 : 2.0,
                )
              : BorderSide.none,
        ),
        color: theme.cardColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$courseCode - $title",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _textStyle(textColor, 18.0, FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (credits != null && segment != null)
                        Expanded(
                          flex: 5,
                          child: _buildCourseInfoRow(Icons.school,
                              'Credits: $credits ($segment)', textColor),
                        ),
                      if (slot != null && slot != '')
                        Expanded(
                          flex: 4,
                          child: _buildCourseInfoRow(
                              Icons.schedule, 'Slot: $slot', textColor),
                        ),
                    ],
                  ),
                  if (classroom != null)
                    _buildCourseInfoRow(
                        Icons.meeting_room, 'Classroom: $classroom', textColor),
                  if (instructor != null && instructor != '')
                    _buildCourseInfoRow(
                        Icons.person, instructor, textColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _textStyle(Color? color, double size,
      [FontWeight weight = FontWeight.normal]) {
    return TextStyle(fontSize: size, fontWeight: weight, color: color);
  }

  Widget _buildCourseInfoRow(IconData icon, String text, Color? color) {
    return Container(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18.0, color: color),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(text,
                style: _textStyle(color, 14.0),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
