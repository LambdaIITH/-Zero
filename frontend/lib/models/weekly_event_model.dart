class WeeklyEvent {
  final int id;
  final String title;
  final String description;
  final int dayOfWeek; // 1=Monday, 2=Tuesday, etc.
  final int hour;
  final int minute;

  WeeklyEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.dayOfWeek,
    required this.hour,
    required this.minute,
  });
}
