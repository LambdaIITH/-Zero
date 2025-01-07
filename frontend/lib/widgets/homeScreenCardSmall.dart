import 'dart:math';

import 'package:flutter/foundation.dart';
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
      height: 250,
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
      child: Align(
        alignment: Alignment.center,
        child: Wrap(
          direction: Axis.vertical,
          children: [
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Container(),
                      Spacer(),
                      isImageShow
                          ? reduceImageSize
                              ? SvgPicture.asset(
                                  child,
                                  fit: BoxFit.contain,
                                  width: width,
                                  // width: min(0.2 * screenWidth, 200),
                                  // height: min(0.2 * screenWidth, 200),
                                )
                              : SvgPicture.asset(
                                  child,
                                  fit: BoxFit.contain,
                                  height: min(0.32 * screenWidth, 200),
                                )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Center(
                          child: Text(
                            title,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isComingSoon)
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 57, 57, 57)
                                .withOpacity(0.5)
                            : Colors.white.withOpacity(0.5)),
                    child: Center(
                        child: SizedBox(
                            // height: 120,
                            width: 200,
                            child: Image.asset(
                              "assets/icons/comingsoon.png",
                            ))),
                  )
              ],
            ),
            // Expanded(child: SizedBox()),
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
              height: 170,
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
              child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Container(),
                              Spacer(),
                              isImageShow
                                  ? reduceImageSize
                                      ? SvgPicture.asset(
                                          child,
                                          fit: BoxFit.contain,
                                          height: min(0.25 * screenWidth, 200),
                                        )
                                      : SvgPicture.asset(
                                          child,
                                          fit: BoxFit.contain,
                                          height: min(0.32 * screenWidth, 200),
                                        )
                                  : Container(),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Center(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isComingSoon)
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color.fromARGB(255, 57, 57, 57)
                                        .withOpacity(0.5)
                                    : Colors.white.withOpacity(0.5)),
                            child: Center(
                                child: SizedBox(
                                    // height: double.infinity,
                                    width: width,
                                    child: Image.asset(
                                      "assets/icons/comingsoon.png",
                                      fit: BoxFit.contain,
                                    ))),
                          )
                      ],
                    ),
                    // Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
    );
  }
}
