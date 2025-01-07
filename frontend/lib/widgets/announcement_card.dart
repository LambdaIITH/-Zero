import 'package:dashbaord/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementCard extends StatelessWidget {
  AnnouncementCard({
    super.key,
    required this.image,
    required this.source,
    required this.date,
    required this.title,
    required this.description,
  });

  final String? image;
  final String source;
  final String date;
  final String title;
  final String description;

  final ApiServices _apiServices = ApiServices();

  String formatDate(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000); // Convert to milliseconds
    DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Today ${DateFormat('h:mma').format(dateTime).toLowerCase()}";
    } else {
      return DateFormat('MMMM d, yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                '${_apiServices.backendUrl}${image!}',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      source,
                      style: TextStyle(
                        color: Color.fromRGBO(214, 159, 221, 0.62),
                        fontSize: 14,
                        // fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    Text(
                      ' ·  ${formatDate(int.parse(date))}',
                      style: TextStyle(
                        color: Color.fromRGBO(214, 159, 221, 0.62),
                        fontSize: 14,
                        // fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 26,
                    // fontFamily: 'Outfit',
                    fontWeight: FontWeight.w800
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Color.fromRGBO(246, 246, 246, 1),
                    fontSize: 14,
                    // fontFamily: 'Outfit',
                    fontWeight: FontWeight.w400
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
