import 'package:dashbaord/constants/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String time;
  final String description;
  final String type;
  final String? location;

  const EventCard({
    super.key,
    required this.title,
    required this.time,
    required this.description,
    required this.type,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>();

    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 6,
      shadowColor: customColors?.customShadowColor,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  type == "lecture"
                      ? CupertinoIcons.calendar
                      : CupertinoIcons.book,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.yellowAccent
                      : Colors.yellow[600],
                ),
              ],
            ),
            const SizedBox(height: 3.0),
            Text(
              location != null && location != 'null'
                  ? '$time | $location'
                  : time,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleSmall?.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              description,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleSmall?.color,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
