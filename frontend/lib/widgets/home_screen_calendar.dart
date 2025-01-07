import 'package:dashbaord/extensions.dart';
import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/screens/calendar_screen.dart';
import 'package:dashbaord/utils/custom_page_route.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeScreenSchedule extends StatefulWidget {
  final Timetable? timetable;
  final Function(String, String, List<Lecture>)? onLectureAdded;
  final Function(Timetable)? onEditTimetable;

  const HomeScreenSchedule(
      {super.key,
      required this.timetable,
      required this.onLectureAdded,
      required this.onEditTimetable});

  @override
  State<HomeScreenSchedule> createState() => _HomeScreenScheduleState();
}

class _HomeScreenScheduleState extends State<HomeScreenSchedule> {
  // return events for today and true, if there are no events return events for tomorrow and false
  List<dynamic> getNextCourses(int k) {
    final todayEvents = getNextCoursesforDate(k, DateTime.now());

    if (todayEvents.isEmpty) {
      final tomorrowEvents = getNextCoursesforDate(
        k,
        DateTime.now().add(
          Duration(days: 1),
        ),
      );
      return [tomorrowEvents, false];
    }

    return [todayEvents, true];
  }

  // function to get the next k upcoming courses for given date
  List<Lecture> getNextCoursesforDate(int k, DateTime date) {
    DateTime now = DateTime.now();
    String dayString = DateFormat('EEEE').format(date);

    // find out all courses for today from lecture.day and checking for current day
    // with date manipulation
    // For example. if today is Monday, all those lectures with day as
    // Monday will be returned
    List<Lecture> todayCourses = widget.timetable?.slots.where((lecture) {
          return lecture.day == dayString;
        }).toList() ??
        [];

    // return all courses whose start time is after the present time
    List<Lecture> upcomingCourses = todayCourses.where((lecture) {
      TimeOfDay lectureStartTimeText = TimeOfDay.fromDateTime(
          DateFormat('hh:mm a').parse(lecture.startTime));
      // converting lectureStartTime to today's date and adding the time from startTime and endTime
      DateTime lectureStartTime = DateTime(date.year, date.month, date.day,
          lectureStartTimeText.hour, lectureStartTimeText.minute);

      TimeOfDay lectureEndTimeText =
          TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(lecture.endTime));
      // converting lectureStartTime to today's date and adding the time from startTime and endTime
      DateTime lectureEndTime = DateTime(date.year, date.month, date.day,
          lectureEndTimeText.hour, lectureEndTimeText.minute);

      if (!lectureStartTime.isAfter(now)) {
        return now.isAfter(lectureStartTime) && now.isBefore(lectureEndTime);
      } else {
        return true;
      }
    }).toList();

    // sorting the upcomingCourses, so that we get the k lectures in order
    upcomingCourses.sort((a, b) {
      DateTime aStartTime = DateFormat('hh:mm a').parse(a.startTime);
      DateTime bStartTime = DateFormat('hh:mm a').parse(b.startTime);
      return aStartTime.compareTo(bStartTime);
    });

    if (upcomingCourses.length < k) {
      return upcomingCourses.toList();
    }

    return upcomingCourses.take(k).toList();
  }

  @override
  Widget build(BuildContext context) {
    // to show 2 upcoming lectures in the schedule
    int numLectures = 2;
    final eventsObject = getNextCourses(numLectures);
    final events = eventsObject[0];
    bool isEventsForToday = eventsObject[1];

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        CustomPageRoute(
          child: CalendarScreen(
            timetable: widget.timetable,
            onLectureAdded: widget.onLectureAdded,
            onEditTimetable: widget.onEditTimetable,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.customColors.customContainerColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: context.customColors.customShadowColor,
              offset: const Offset(0, 4),
              blurRadius: 10.0,
              spreadRadius: 0.0,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 18, top: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Schedule',
                      style: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    events.isEmpty
                        ? SizedBox()
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              isEventsForToday ? 'Today' : 'Tomorrow',
                              style: GoogleFonts.inter(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            events.isEmpty
                ? Center(
                    child: Padding(
                        padding: EdgeInsets.all(
                          12,
                        ),
                        child: Text('No upcoming events!')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return lectureItem(
                          events[index], widget.timetable, context);
                    },
                  ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

Container lectureItem(
    Lecture lecture, Timetable? timetable, BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff000000).withOpacity(0.25),
          offset: const Offset(
            0,
            1,
          ),
          blurRadius: 1.0,
          spreadRadius: 0.0,
        ),
      ],
    ),
    child: Row(
      children: [
        Text(
          lecture.startTime,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(width: 8),
        Container(
          height: 36,
          width: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            color: Colors.green,
          ),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NormalText(
              text: lecture.courseCode,
              size: 12,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            NormalText(
              text: timetable!.courses[lecture.courseCode]?['title'] ??
                  'Unknown Course',
              size: 18,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ],
        ),
      ],
    ),
  );
}
