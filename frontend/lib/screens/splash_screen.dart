import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.isLoading = true,
    required this.nextPagePath,
    this.delay = const Duration(milliseconds: 900),
  });

  final String nextPagePath; 
  final Duration delay;
  final bool isLoading;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  openNextPage() {
    Future.delayed(widget.delay, () {
      context.go(widget.nextPagePath);
    });
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isLoading) {
      openNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: "splash_icon",
              child: Image.asset(
                "assets/icons/logo.png",
                height: 190,
                width: 190,
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.only(bottom: 48),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "IITH ",
                style: GoogleFonts.inter(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xff272D2F)
                      : const Color.fromARGB(255, 142, 142, 142),
                ),
                children: [
                  TextSpan(
                    text: "\nDashboard",
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xff272D2F)
                          : const Color.fromARGB(255, 142, 142, 142),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
