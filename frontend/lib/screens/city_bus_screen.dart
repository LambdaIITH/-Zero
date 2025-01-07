import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/utils/bus_schedule.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/transport_qr_model.dart';
import '../widgets/bus_timing_list_widget.dart';

class CityBusScreen extends StatefulWidget {
  CityBusScreen({super.key});

  @override
  State<CityBusScreen> createState() => _CityBusScreenState();
}

class _CityBusScreenState extends State<CityBusScreen>
    with TickerProviderStateMixin {
  final TextEditingController transactionIdController = TextEditingController();
  final TextEditingController transactionAmountController =
      TextEditingController();
  late final Map<String, int> toIITH;
  late final Map<String, int> fromIITH;

  final ApiServices apiServices = ApiServices();

  Map<String, dynamic>? transactionDetails;

  late TabController _tabController;

  String startingPoint = "Starting";
  String destination = "Destination";

  CityBusSchedule? busSchedule;

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

  Future<void> fetchBus() async {
    final response = await ApiServices().getCityBusSchedule(context);
    if (response == null) {
      showError(msg: "Server Refresh Failed...");
      final res = await SharedService().getCityBusSchedule();

      setState(() {
        busSchedule = res;
        toIITH = busSchedule?.toIITH ?? {};
        fromIITH = busSchedule?.fromIITH ?? {};
      });
    } else {
      setState(() {
        busSchedule = response;
        toIITH = busSchedule?.toIITH ?? {};
        fromIITH = busSchedule?.fromIITH ?? {};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRecentTransaction();
    fetchBus();
  }

  Future<void> _fetchRecentTransaction() async {
    try {
      final result = await ApiServices().getRecentTransaction(context);
      if (result != null) {
        final user = await SharedService().getUserDetails();
        DateTime paymentDateTime = DateTime.parse(result['payment_time']);
        String paymentDate =
            "${paymentDateTime.year}-${paymentDateTime.month.toString().padLeft(2, '0')}-${paymentDateTime.day.toString().padLeft(2, '0')}";

        setState(() {
          transactionDetails = {
            'transactionId': result['transaction_id'],
            'travelDate': paymentDate,
            'paymentTime': result['payment_time'],
            'busTiming': result['bus_timing'],
            'name': user['name'],
            'email': user['email'],
          };
        });
      }
    } catch (e) {
      debugPrint("Error fetching recent transaction: $e");
    }
  }

  @override
  void dispose() {
    _tabController
        .dispose(); // Dispose of the tab controller when the widget is removed
    super.dispose();
  }

  Future<void> submitTransactionID() async {
    final result =
        await apiServices.submitTransactionID(transactionIdController.text);

    final email = (await SharedService().getUserDetails())['email'];
    final name = (await SharedService().getUserDetails())['name'];

    setState(() {
      final transactionId = (result['data']).transactionId;
      final PaymentTime = result['data'].paymentTime;
      final BusTime = result['data'].busTiming;
      final isUsed = result['data'].isUsed;

      transactionDetails = {
        'transactionId': transactionId,
        'travelDate': '2022-01-01',
        'paymentTime': PaymentTime,
        'busTiming': BusTime,
        'name': name,
        'email': email,
        'isUsed': isUsed,
      };
    });

    _tabController.animateTo(2);
  }

  String? _validateTransactionId(String value) {
    if (!RegExp(r'^\d{12}$').hasMatch(value)) {
      return 'UPI transaction ID must be 12 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title: Text('City Bus',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Payment Form'),
                Tab(text: 'Bus Schedule'),
                Tab(text: 'Show QR'),
              ],
            )),
        body: TabBarView(
          controller: _tabController,
          children: [paymentFormTab(), schedule(), showQRTab()],
        ),
      ),
    );
  }

  Column paymentFormTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startingPoint,
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  Text(
                    destination,
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                ],
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      final temp = startingPoint;
                      startingPoint = destination;
                      destination = temp;
                    });
                  },
                  icon: Icon(
                    Icons.swap_vert_rounded,
                    size: 40,
                  )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Text(
            'Transaction ID for next bus will be noted from 4pm',
            style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 16),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TextField(
              controller: transactionAmountController,
              keyboardType: TextInputType.numberWithOptions(
                  decimal: false, signed: false),
              decoration: InputDecoration(
                hintText: 'Transaction Amount',
                filled: true,
                fillColor: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.1),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TextField(
              controller: transactionIdController,
              keyboardType: TextInputType.numberWithOptions(
                  decimal: false, signed: false),
              decoration: InputDecoration(
                hintText: 'Transaction ID',
                filled: true,
                fillColor: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.1),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Expanded(child: SizedBox()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              onTap: () {
                if (_validateTransactionId(transactionIdController.text) ==
                    null) {
                  submitTransactionID();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 8, 30, 8),
                  child: Text('Submit',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column showQRTab() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        transactionDetails != null
            ? Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Transaction Details',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.8),
                        fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '${transactionDetails?['name']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.8),
                        fontSize: 24),
                  ),
                  Text(
                    '${transactionDetails?['email']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.8),
                        fontSize: 20),
                  ),
                  Text(
                    '${transactionDetails?['travelDate']}, ${transactionDetails?['busTiming']}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.8),
                        fontSize: 24),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Amount Paid: 60',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.8),
                        fontSize: 24),
                  ),
                  Text(
                    'Transaction ID: ${transactionDetails?['transactionId']}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.8),
                        fontSize: 24),
                  ),
                ],
              )
            : SizedBox(),
      ],
    );
  }

  Column schedule() {
    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BusTimingList(
                  from: startingPoint,
                  destination: destination,
                  timings: toIITH,
                ),
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: BusTimingList(
                  from: destination,
                  destination: startingPoint,
                  timings: fromIITH,
                ),
              ),
            ],
          ),
        ),
        // _buildNoteWidget(),
      ],
    );
  }
}

class FullScheduleWidget extends StatelessWidget {
  final Map<String, int> toIITH;
  final Map<String, int> fromIITH;

  const FullScheduleWidget({
    Key? key,
    required this.toIITH,
    required this.fromIITH,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BusTimingList(
                  from: 'Maingate',
                  destination: 'Hostel',
                  timings: toIITH,
                ),
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: BusTimingList(
                  from: 'Hostel',
                  destination: 'Maingate',
                  timings: fromIITH,
                ),
              ),
            ],
          ),
        ),
        _buildNoteWidget(),
      ],
    );
  }

  Widget _buildNoteWidget() {
    return Text(
      '* indicates EV',
      style: GoogleFonts.inter(fontSize: 14),
    );
  }
}
