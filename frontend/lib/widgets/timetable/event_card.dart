import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String time;
  final String description;

  const EventCard({
    Key? key,
    required this.title,
    required this.time,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.2),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.calendar,
                  color: Colors.yellowAccent,
                ),
              ],
            ),
            const SizedBox(height: 3.0),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
