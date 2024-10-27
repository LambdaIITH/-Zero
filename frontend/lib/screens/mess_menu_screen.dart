import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/models/mess_menu_model.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/widgets/mess_menu_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessMenuScreen extends StatefulWidget {
  final MessMenuModel? messMenu;
  const MessMenuScreen({
    super.key,
    required this.messMenu,
  });

  @override
  State<MessMenuScreen> createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen> {
  MessMenuModel? messMenu;
  bool isLoading = true;

  void showError({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Please login to use this feature'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void fetchMessMenu() async {
    final response = await ApiServices().getMessMenu(context);
    if (response == null) {
      showError(msg: "Server Refresh Failed...");
      final res = await SharedService().getMessMenu();
      if (res == null) {
        context.go('/');
        return;
      }
      setState(() {
        messMenu = res;
        isLoading = false;
      });

      return;
    }
    setState(() {
      messMenu = response;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.messMenu == null) {
      fetchMessMenu();
    } else {
      messMenu = widget.messMenu;
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return isLoading
        ? CustomLoadingScreen()
        : Scaffold(
            appBar: AppBar(
              title: Text('Mess Menu',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  )),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  // color: Colors.black,
                  size: 30.0,
                ),
                onPressed: () {
                  // Navigator.pop(context);
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
            ),
            body: SafeArea(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                            child: MessMenuPage(
                      messMenu: messMenu!,
                    ))),
                  ]),
            ),
          );
  }
}

class MessMenuPage extends StatefulWidget {
  final MessMenuModel messMenu;
  const MessMenuPage({
    super.key,
    required this.messMenu,
  });

  @override
  State<MessMenuPage> createState() => _MessMenuPageState();
}

class _MessMenuPageState extends State<MessMenuPage> {
  String whichDay = 'Sunday';
  final List<bool> selectedOption = [true, false];
  // final List<Widget> messToggleButtons = [
  //   Text(
  //     'Mess A',
  //     style: GoogleFonts.inter(
  //         fontSize: 16.0,
  //         fontWeight: FontWeight.w700,
  //         color: const Color.fromARGB(255, 47, 47, 47)),
  //   ),
  //   Text(
  //     'Mess B',
  //     style: GoogleFonts.inter(
  //         fontSize: 16.0,
  //         fontWeight: FontWeight.w700,
  //         color: const Color.fromARGB(255, 47, 47, 47)),
  //   )
  // ];

  String getCurrentDay() {
    DateTime now = DateTime.now();
    String day = DateFormat('EEEE').format(now);
    return day;
  }

  final analyticsService = FirebaseAnalyticsService();

  @override
  void initState() {
    whichDay = getCurrentDay();
    super.initState();
    analyticsService.logScreenView(screenName: "Mess Menu Screen");
  }

  bool isWeekend() {
    return whichDay == 'Sunday' || whichDay == 'Saturday';
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final meals = selectedOption[0]
        ? widget.messMenu.udh[whichDay]
        : widget.messMenu.ldh[whichDay];

    final extras = widget.messMenu.udhAdditional[whichDay];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 3, 0, 0),
              child: DropdownButton<String>(
                elevation: 0,
                underline: Container(),
                value: whichDay,
                items: <String>[
                  'Sunday',
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    whichDay = value!;
                  });
                },
                focusColor: textColor,
              ),
            ),
          ],
        ),
        Column(
          children: [
            const SizedBox(
              height: 8.0,
            ),
            if (meals != null) ...[
              ShowMessMenu(
                extras: extras?.breakfast ?? [],
                whichMeal: 'Breakfast',
                time: isWeekend() ? '8:00AM-10:30AM' : '7:30AM-10:00AM',
                meals: meals.breakfast,
              ),
              ShowMessMenu(
                extras: extras?.lunch ?? [],
                whichMeal: 'Lunch',
                time: '12:30PM-2:45PM',
                meals: meals.lunch,
              ),
              ShowMessMenu(
                extras: extras?.snacks ?? [],
                whichMeal: 'Snacks',
                time: '5:00PM-6:00PM',
                meals: meals.snacks,
              ),
              ShowMessMenu(
                extras: extras?.dinner ?? [],
                whichMeal: 'Dinner',
                time: '7:30PM-9:30PM',
                meals: meals.dinner,
              ),
            ] else
              const Center(child: Text('No meals available for today')),
          ],
        ),
      ],
    );
  }
}
