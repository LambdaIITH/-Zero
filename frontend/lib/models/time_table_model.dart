import 'package:dashbaord/models/lecture_model.dart';
import 'package:intl/intl.dart';

class Timetable {
  final Map<String, Map<String, String>> courses;
  final List<Lecture> slots;

  Timetable({required this.courses, required this.slots});

  List<Lecture> getCoursesForToday() {
    String today = DateFormat('EEEE').format(DateTime.now());

    List<Lecture> todayCourses =
        slots.where((lecture) => lecture.day == today).toList();

    return todayCourses;
  }

  List<Lecture> getSlotsForCourse(String courseCode) {
    List<Lecture> courseSlots =
        slots.where((lecture) => lecture.courseCode == courseCode).toList();

    return courseSlots;
  }

  factory Timetable.fromJson(Map<String, dynamic> json) {
    var courseMap = (json['courses'] as Map<String, dynamic>)
        .map<String, Map<String, String>>(
      (key, value) {
        if (value is Map<String, dynamic> && value.containsKey('title')) {
          return MapEntry(key, {'title': value['title'].toString()});
        }
        return MapEntry(key, {'title': ''}); // or handle as needed
      },
    );

    List<Lecture> slotList = (json['slots'] as List).map((slotJson) {
      return Lecture.fromJson(slotJson);
    }).toList();

    return Timetable(
      courses: courseMap,
      slots: slotList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses':
          courses.map((key, value) => MapEntry(key, {'title': value['title']})),
      'slots': slots.map((lecture) => lecture.toJson()).toList(),
    };
  }

  Timetable addCourse(
          String courseCode, String courseName, List<Lecture> lectures) =>
      Timetable(
        courses: {
          ...courses,
          courseCode: {'title': courseName}
        },
        slots: [...slots, ...lectures],
      );
}
