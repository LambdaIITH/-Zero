import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreenCardSmall extends StatelessWidget {
  final String title;
  final dynamic child;
  final bool reduceImageSize;
  final bool isImageShow;
  final bool isComingSoon;
  final double width;
  final void Function() onTap;

  const HomeScreenCardSmall(
      {super.key,
      required this.title,
      this.child,
      this.reduceImageSize = false,
      this.isImageShow = true,
      this.isComingSoon = true,
      required this.width,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Widget forWeb = Container(
      height: 200, // Reduced height
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
            offset: Offset(0, 4), // Offset in the x, y direction
            blurRadius: 10.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isImageShow)
              SvgPicture.asset(
                child,
                fit: BoxFit.contain,
                height: reduceImageSize ? min(0.2 * screenWidth, 100) : min(0.32 * screenWidth, 150),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: isComingSoon ? null : onTap,
      child: MediaQuery.of(context).size.width > 450
          ? forWeb
          : Container(
              height: 120, // Reduced height
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                    offset: Offset(0, 4), // Offset in the x, y direction
                    blurRadius: 10.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isImageShow)
                      SvgPicture.asset(
                        child,
                        fit: BoxFit.contain,
                        height: reduceImageSize ? min(0.16 * screenWidth, 80) : min(0.25 * screenWidth, 60),
                      ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          title,
                          // textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
