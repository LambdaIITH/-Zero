class CourseModel {
  final String courseCode;
  final String title;
  final double? credits;
  final String? segment;
  final String? slot;
  final String? classroom;
  final String? instructor;

  CourseModel({
    required this.courseCode,
    required this.title,
    required this.credits,
    this.segment,
    this.slot,
    this.classroom,
    this.instructor,
  });

  static double? _parseCredits(dynamic credits) {
    if (credits == null) {
      return null;
    }
    if (credits is int) {
      return credits.toDouble();
    } else if (credits is double) {
      return credits;
    }
    return null;
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseCode: json['course_code'] as String? ?? '',
      title: json['name'] as String? ?? '',
      credits: _parseCredits(json['credits']),
      segment: json['segment'] as String?,
      slot: json['slot'] as String?,
      classroom: json['classroom'] as String?,
      instructor: json['instructor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_code': courseCode,
      'segment': segment,
      'title': title,
      'credits': credits,
      'slot': slot,
      'classroom': classroom,
      'instructor': instructor,
    };
  }

  @override
  String toString() {
    return 'Course(title: $title, segment: $segment, credits: $credits, slot: $slot, classroom: $classroom, instructor: $instructor)';
  }
}
