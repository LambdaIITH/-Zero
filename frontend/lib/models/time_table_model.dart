import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/weekly_event_model.dart';
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

  void cleanUp() {
    courses.removeWhere((key, _) => key.trim().isEmpty);
    slots.removeWhere((lecture) => lecture.courseCode.trim().isEmpty);
  }

  factory Timetable.fromJson(Map<String, dynamic> json) {
    var courseMap = (json['courses'] as Map<String, dynamic>)
        .map<String, Map<String, String>>(
      (key, value) {
        if (value is Map<String, dynamic> && value.containsKey('title')) {
          return MapEntry(key, {
            'title': value['title'].toString(),
            if (value.containsKey('classroom') && value['classroom'] != null)
              'classroom': value['classroom'].toString(),
            if (value.containsKey('slot') && value['slot'] != null)
              'slot': value['slot'].toString(),
          });
        }
        return MapEntry(key, {
          'title': '',
          if (value.containsKey('classroom') && value['classroom'] != null)
            'classroom': value['classroom'].toString(),
          if (value.containsKey('slot') && value['slot'] != null)
            'slot': value['slot'].toString(),
        });
      },
    );

    List<Lecture> slotList = (json['slots'] as List).map((slotJson) {
      Lecture local = Lecture.fromJson(slotJson);

      var courseInfo = courseMap[slotJson['course_code']];
      if (courseInfo != null && courseInfo.containsKey('classroom')) {
        local.classRoom = courseInfo['classroom'];
      }

      return local;
    }).toList();

    return Timetable(
      courses: courseMap,
      slots: slotList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': courses.map((key, value) => MapEntry(key, {
            'title': value['title'],
            if (value['classroom'] != null) 'classroom': value['classroom'],
            if (value['slot'] != null) 'slot': value['slot'],
          })),
      'slots': slots.map((lecture) => lecture.toJson()).toList(),
    };
  }

  Timetable addCourse(
          String courseCode, String courseName, List<Lecture> lectures,
          {String? classRoom, String? slot}) =>
      Timetable(
        courses: {
          ...courses,
          courseCode: {
            'title': courseName,
            if (classRoom?.isNotEmpty ?? false) 'classroom': classRoom!,
            if (slot?.isNotEmpty ?? false) 'slot': slot!,
          }
        },
        slots: [...slots, ...lectures],
      );

  List<WeeklyEvent> convertTimetableToWeeklyEvents(int reminderOffsetMinutes) {
    List<WeeklyEvent> weeklyEvents = [];
    int idCounter = 1;

    for (Lecture lecture in slots) {
      int? dayOfWeek = _dayStringToWeekday(lecture.day);
      print("TITLE: ${lecture.courseCode} DAY: ${lecture.day}");
      if (dayOfWeek == null) {
        continue;
      }

      DateFormat timeFormat = DateFormat("hh:mm a");
      DateTime parsedTime = timeFormat.parse(lecture.startTime);
      DateTime reminderTime =
          parsedTime.subtract(Duration(minutes: reminderOffsetMinutes));
      int hour = reminderTime.hour;
      int minute = reminderTime.minute;
      String courseTitle =
          courses[lecture.courseCode]?['title'] ?? lecture.courseCode;
      String? classRoom = courses[lecture.courseCode]?['classroom'];
      String title = classRoom != null
          ? "Upcoming: $courseTitle at $classRoom"
          : "Upcoming: $courseTitle";

      weeklyEvents.add(
        WeeklyEvent(
          id: idCounter++,
          title: title,
          description: 'Lecture starts in $reminderOffsetMinutes minutes!',
          dayOfWeek: dayOfWeek,
          hour: hour,
          minute: minute,
        ),
      );
    }
    return weeklyEvents;
  }

  int? _dayStringToWeekday(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return null;
    }
  }
}
