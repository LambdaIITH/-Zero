import 'dart:async';

import 'package:dashbaord/models/user_model.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/widgets/notif_perm.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/services/analytics_service.dart';
import 'package:dashbaord/utils/loading_widget.dart';
import 'package:dashbaord/widgets/cab_details.dart';
import 'package:dashbaord/widgets/cab_search_form.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/models/booking_model.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class CabSharingScreen extends StatefulWidget {
  final UserModel? user;
  final bool isMyRide;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? from;
  final String? to;
  const CabSharingScreen(
      {super.key,
      required this.user,
      this.isMyRide = false,
      this.endTime,
      this.from,
      this.startTime,
      this.to});
  @override
  State<CabSharingScreen> createState() => _CabSharingScreenState();
}

class _CabSharingScreenState extends State<CabSharingScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedOption;
  String? selectedOption2;
  DateTime? startTime;
  DateTime? endTime;
  bool isTabOneSelected = true;
  final analyticsService = FirebaseAnalyticsService();
  bool isLoading = true;
  int state = 0;

  bool sortBySeatsSelected = false;
  bool sortBySeatsDescendingSelected = false;
  bool sortByEndTimeSelected = false;
  bool sortByEndTimeDescendingSelected = false;

  void requestNotifPerms(BuildContext bc) async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      return;
    }

    DateTime now = DateTime.now();
    String? lastDate = await SharedService().getLastPermsRequestDate();

    bool shouldAsk = false;

    if (lastDate != null) {
      DateTime lastDateParsed = DateFormat('dd-MM-yyyy').parse(lastDate.trim());
      Duration difference = now.difference(lastDateParsed);
      if (difference.inDays >= 1) {
        //TODO: change if it is annoying
        shouldAsk = true;
      }
    } else {
      shouldAsk = true;
    }

    if (shouldAsk) {
      _showNotificationPermissionSheet(context);
    }
  }

  void _showNotificationPermissionSheet(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const NotificationPermissionRequestBottomSheet();
      },
    );
  }

  changeLoadingState() {
    state++;
    if (state >= 3) {
      isLoading = false;
    }
    setState(() {});
  }

  UserModel? userModel;

  Future<void> fetchUser() async {
    final response = await ApiServices().getUserDetails(context);
    if (response == null) {
      context.go('/login');
      return;
    }
    setState(() {
      userModel = response;
      changeLoadingState();
    });
  }

  getUserData() async {
    final user = await SharedService().getUserDetails();
    if (user['name'] == null || user['email'] == null) {
      await fetchUser();
    } else {
      UserModel userM = UserModel(
          email: user['email'] ?? 'user@iith.ac.in',
          name: user['name'] ?? 'User');

      setState(() {
        userModel = userM;
        changeLoadingState();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestNotifPerms(context);
    });

    if (widget.startTime != null ||
        widget.endTime != null ||
        widget.from != null ||
        widget.to != null) {
      updateSearchForm(
        start: widget.startTime,
        end: widget.endTime,
        searchSelectedOption: widget.from,
        searchSelectedOption2: widget.to,
      );
      changeLoadingState();
    } else {
      getAllCabs();
    }
    // 1 time loading status

    isTabOneSelected = !widget.isMyRide;
    analyticsService.logScreenView(screenName: "Cab Share Screen");
    getUserCabs();
    // 2 times loading status

    if (widget.user == null) {
      getUserData();
    } else {
      userModel = widget.user;
      changeLoadingState();
    }
    // 3 times loading status
  }

  void updateSearchForm({
    DateTime? start,
    DateTime? end,
    String? searchSelectedOption,
    String? searchSelectedOption2,
  }) {
    setState(() {
      selectedOption = searchSelectedOption;
      selectedOption2 = searchSelectedOption2;
      startTime = start;
      endTime = end;
    });
    searchCabs(start, end, searchSelectedOption, searchSelectedOption2);
  }

  // From the API service
  ApiServices apiServices = ApiServices();

  List<BookingModel> allBookings = [];
  List<BookingModel> allBookingsSTORED = [];
  getAllCabs() async {
    final cabs = await apiServices.getBookings(context);
    if (cabs.isEmpty && allBookingsSTORED.isNotEmpty) {
      return;
    }
    setState(() {
      allBookings = cabs;
      allBookingsSTORED = [...cabs];
      sortBySeatsSelected = false;
      sortBySeatsDescendingSelected = false;
      sortByEndTimeDescendingSelected = false;
      sortByEndTimeSelected = false;
    });
    changeLoadingState();
  }

  searchCabs(DateTime? startTime, DateTime? endTime,
      String? searchSelectedOption, String? searchSelectedOption2) async {
    final cabs = await apiServices.getBookings(context,
        fromLoc: selectedOption,
        toLoc: selectedOption2,
        startTime: startTime?.toIso8601String(),
        endTime: endTime?.toIso8601String());
    setState(() {
      allBookings = cabs;
    });
  }

  List<BookingModel> userBookings = [];
  getUserCabs() async {
    final cabs = await apiServices.getUserBookings(context);
    setState(() {
      userBookings = cabs;
    });
    changeLoadingState();
  }

  openFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Rides',
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: CabSearch(
              onSearch: updateSearchForm,
              startDate: startTime,
              endDate: endTime,
              from: selectedOption,
              to: selectedOption2,
            ),
          ),
        );
      },
    );
  }

  void sortBySeats() {
    setState(() {
      sortBySeatsSelected = !sortBySeatsSelected;
      if (sortBySeatsSelected) {
        sortBySeatsDescendingSelected = false;
        sortByEndTimeDescendingSelected = false;
        sortByEndTimeSelected = false;
        allBookings.sort((a, b) => (a.capacity - a.travellers.length)
            .compareTo(b.capacity - b.travellers.length));
      } else {
        allBookings = [...allBookingsSTORED];
      }
    });
  }

  void sortBySeatsDescending() {
    setState(() {
      sortBySeatsDescendingSelected = !sortBySeatsDescendingSelected;
      if (sortBySeatsDescendingSelected) {
        sortBySeatsSelected = false;
        sortByEndTimeDescendingSelected = false;
        sortByEndTimeSelected = false;
        allBookings.sort((a, b) => (b.capacity - b.travellers.length)
            .compareTo(a.capacity - a.travellers.length));
      } else {
        allBookings = [...allBookingsSTORED];
      }
    });
  }

  void sortByEndTime() {
    setState(() {
      sortByEndTimeSelected = !sortByEndTimeSelected;
      if (sortByEndTimeSelected) {
        sortByEndTimeDescendingSelected = false;
        sortBySeatsSelected = false;
        sortBySeatsDescendingSelected = false;
        allBookings.sort((a, b) => a.endTime.compareTo(b.endTime));
      } else {
        allBookings = [...allBookingsSTORED];
      }
    });
  }

  void sortByEndTimeDescending() {
    setState(() {
      sortByEndTimeDescendingSelected = !sortByEndTimeDescendingSelected;
      if (sortByEndTimeDescendingSelected) {
        sortByEndTimeSelected = false;
        sortBySeatsSelected = false;
        sortBySeatsDescendingSelected = false;
        allBookings.sort((a, b) => b.endTime.compareTo(a.endTime));
      } else {
        allBookings = [...allBookingsSTORED];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    final List<Widget> tabNames = [
      Text(
        'All Rides',
        style: GoogleFonts.inter(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      Text(
        'My Rides',
        style: GoogleFonts.inter(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    ];
    Widget allRides = RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          const Duration(seconds: 1),
          () {
            getAllCabs();
          },
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<int>(
                  icon: const Icon(
                    Icons.sort_outlined,
                    size: 30.0,
                    color: Color(0xffFE724C),
                  ),
                  onSelected: (value) {
                    if (value == 1) {
                      sortBySeats();
                    } else if (value == 2) {
                      sortBySeatsDescending();
                    } else if (value == 3) {
                      sortByEndTime();
                    } else if (value == 4) {
                      sortByEndTimeDescending();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: [
                          Checkbox(
                            value: sortBySeatsSelected,
                            onChanged: (value) {
                              sortBySeats();
                              // Navigator.pop(context);
                              context.pop();
                            },
                          ),
                          const Text('Sort by Seats'),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: [
                          Checkbox(
                            value: sortBySeatsDescendingSelected,
                            onChanged: (value) {
                              sortBySeatsDescending();
                              // Navigator.pop(context);
                              context.pop();
                            },
                          ),
                          const Text('Sort by Seats Desc'),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 3,
                      child: Row(
                        children: [
                          Checkbox(
                            value: sortByEndTimeSelected,
                            onChanged: (value) {
                              sortByEndTime();
                              // Navigator.pop(context);
                              context.pop();
                            },
                          ),
                          const Text('Sort by End Time'),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 4,
                      child: Row(
                        children: [
                          Checkbox(
                            value: sortByEndTimeDescendingSelected,
                            onChanged: (value) {
                              sortByEndTimeDescending();
                              // Navigator.pop(context);
                              context.pop();
                            },
                          ),
                          const Text('Sort by End Time Desc'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10.0),
                InkWell(
                  onTap: openFilterDialog,
                  child: const Icon(
                    Icons.filter_alt_outlined,
                    size: 30.0,
                    color: Color(0xffFE724C),
                  ),
                ),
              ],
            ),
          ),
          allBookings.isEmpty
              ? Expanded(
                  child: ListView(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'No rides found',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: allBookings.length,
                    itemBuilder: (ctx, inx) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: allBookings[inx].capacity !=
                              allBookings[inx].travellers.length
                          ? CabCard(
                              onRefresh: () {
                                return Future.delayed(
                                  const Duration(seconds: 1),
                                  () {
                                    getAllCabs();
                                  },
                                );
                              },
                              cab: allBookings[inx],
                              user: userModel ??
                                  UserModel(
                                      email: "user@iith.ac.in", name: "User"),
                            )
                          : null,
                    ),
                  ),
                ),
        ],
      ),
    );

    Widget myRides = RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          const Duration(seconds: 1),
          () {
            getUserCabs();
          },
        );
      },
      child: Column(
        children: [
          // TODO : Add both past and future rides
          userBookings.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    itemCount: userBookings.length,
                    itemBuilder: (ctx, inx) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CabCard(
                        onRefresh: () {
                          return Future.delayed(
                            const Duration(seconds: 1),
                            () {
                              getUserCabs();
                            },
                          );
                        },
                        cab: userBookings[inx],
                        user: userModel ??
                            UserModel(email: "user@iith.ac.in", name: "User"),
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        width: double.infinity,
                        child: Text(
                          'You have no rides',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      )
                    ],
                  ),
                )
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Cab Sharing',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
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
              context.go('/home');
            }
          },
        ),
      ),
      floatingActionButton: isTabOneSelected
          ? Container()
          : FloatingActionButton(
              onPressed: () async {
                context.push('/cabsharing/add');
                // Navigator.push(
                //   context,
                //   CustomPageRoute(
                //     startPos: const Offset(0, 1),
                //     child: CabAddScreen(
                //       user: widget.user,
                //       image: widget.image,
                //     ),
                //   ),
                // );
              },
              backgroundColor: const Color.fromARGB(204, 254, 115, 76),
              child: const Icon(
                Icons.add,
                size: 30.0,
              ),
            ),
      body: isLoading
          ? const CustomLoadingScreen()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 6,
                  ),
                  Container(
                    decoration: const BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(51, 51, 51, 0.10), // Shadow color
                        offset: Offset(0, 4), // Offset in the x, y direction
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                      ),
                    ]),
                    child: ToggleButtons(
                      direction: Axis.horizontal,
                      onPressed: (index) {
                        setState(() {
                          isTabOneSelected = index == 0;
                        });
                      },
                      borderRadius:
                          const BorderRadius.all(Radius.circular(7.0)),
                      fillColor: const Color.fromRGBO(254, 114, 76, 0.70),
                      constraints: const BoxConstraints(
                        minHeight: 44.0,
                        minWidth: 130.0,
                      ),
                      isSelected: [isTabOneSelected, !isTabOneSelected],
                      children: tabNames,
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Expanded(child: isTabOneSelected ? allRides : myRides),
                ],
              ),
            ),
    );
  }
}
