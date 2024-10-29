class Lecture {
  final String startTime;
  final String endTime;
  final String day;
  final String courseCode;

  Lecture({
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.courseCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'day': day,
      'course_code': courseCode,
    };
  }
}

extension LectureListExtension on List<Lecture> {
  List<Lecture> remove(String courseCode) {
    return where((lecture) => lecture.courseCode != courseCode).toList();
  }
}
