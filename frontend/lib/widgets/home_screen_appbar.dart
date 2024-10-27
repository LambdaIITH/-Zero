import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashbaord/utils/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/models/user_model.dart';
import 'package:dashbaord/screens/login_screen.dart';
import 'package:dashbaord/screens/profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreenAppBar extends StatelessWidget {
  const HomeScreenAppBar(
      {super.key,
      required this.onThemeChanged,
      required this.user,
      required this.image,
      required this.isGuest,
      required this.status});

  final UserModel? user;
  final String image;
  final bool isGuest;
  final int status;
  final ValueChanged<int> onThemeChanged;

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final greeting = getGreeting();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$greeting\n',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              TextSpan(
                text: user?.name.split(' ').first ?? 'User',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        isGuest
            ? InkWell(
                onTap: () {
                  context.go('/login', extra: {
                    'onThemeChanged': onThemeChanged,
                  });
                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (ctx) => LoginScreen(
                  //               onThemeChanged: onThemeChanged,
                  //             )),
                  //     (Route<dynamic> route) => false);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(500)),
                  child: const Icon(Icons.logout_rounded),
                ),
              )
            : InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  // Navigator.of(context).push(CustomPageRoute(
                  //   child: ProfileScreen(
                  //     user: user ??
                  //         UserModel(
                  //             email: "xx11btech110xx@iith.ac.in", name: "User"),
                  //     image: image,
                  //     onThemeChanged: onThemeChanged,
                  //   ),
                  // ));
                  context.push('/me', extra: {
                    'user': user ??
                        UserModel(
                            email: "xx11btech110xx@iith.ac.in", name: "User"),
                    'image': image,
                    'onThemeChanged': onThemeChanged,
                  });
                },
                child: Stack(
                  children: [
                    ClipOval(
                      child: CircleAvatar(
                          radius: 24,
                          child: CachedNetworkImage(imageUrl: image)),
                    ),
                    if (status != -1)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: status == 1 ? Colors.green : Colors.red,
                            border: Border.all(
                              color: Colors
                                  .white, // Adds a white border to the dot
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
      ],
    );
  }
}
