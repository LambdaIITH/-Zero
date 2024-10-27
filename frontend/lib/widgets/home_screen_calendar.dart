import 'package:dashbaord/extensions.dart';
import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/screens/time_table_screen.dart';
import 'package:dashbaord/utils/custom_page_route.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenCalendar extends StatefulWidget {
  const HomeScreenCalendar({super.key});

  @override
  State<HomeScreenCalendar> createState() => _HomeScreenCalendarState();
}

class _HomeScreenCalendarState extends State<HomeScreenCalendar> {
  final List<Lecture> lectures = [
    Lecture(time: '9:00AM', code: 'MA1120', name: 'Numerical Analysis'),
    Lecture(time: '10:00AM', code: 'EE2120', name: 'LSSP'),
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        CustomPageRoute(
          child: TimeTableScreen(),
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
                child: Text(
                  'Schedule',
                  style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              itemCount: lectures.length,
              itemBuilder: (context, index) {
                return lectureItem(lectures[index], context);
              },
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

Container lectureItem(Lecture lecture, BuildContext context) {
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
          lecture.time,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleSmall?.color,
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
              text: lecture.code,
              size: 12,
              color: Theme.of(context).textTheme.titleSmall?.color,
            ),
            NormalText(
              text: lecture.name,
              size: 18,
              color: Theme.of(context).textTheme.titleSmall?.color,
            ),
          ],
        ),
      ],
    ),
  );
}

