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
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000); // Convert to milliseconds
    DateTime now = DateTime.now();

    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      return "Today ${DateFormat('h:mma').format(dateTime).toLowerCase()}";
    } else {
      return DateFormat('MMMM d, yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).brightness == Brightness.dark
          ? Color.fromRGBO(41, 41, 41, 1)
          : Color.fromRGBO(255, 255, 255, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                '${_apiServices.backendUrl}$image',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color.fromRGBO(48, 48, 48, 1)
                      : Color.fromRGBO(255, 255, 255, 1),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 2, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              source,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.headlineLarge!.color,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              formatDate(int.parse(date)),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Important',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.headlineLarge!.color,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if ('Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\','
                              .length >
                          200)
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.transparent],
                          ).createShader(bounds),
                          blendMode: BlendMode.dstIn,
                          child: Text(
                            '${'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\','.substring(0, 200)}...', // Show only first 100 characters followed by ellipsis
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge!.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\'Join us for a review of our performance over the last quarter. We will discuss key achievements and areas for improvement.\',',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
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
