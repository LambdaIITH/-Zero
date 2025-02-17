import 'package:dashbaord/models/user_model.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:dashbaord/services/shared_service.dart';
import 'package:dashbaord/utils/bold_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomBookingForm extends StatefulWidget {
  final UserModel? user;
  const RoomBookingForm({super.key, required this.user});

  @override
  State<RoomBookingForm> createState() => _RoomBookingFormState();
}

class _RoomBookingFormState extends State<RoomBookingForm> {
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  UserModel? userModel;
  int status = 0;
  int totalOperation = 2;
  bool isLoading = true;

  String _relationWithStudent = "Father";

  void changeState() {
    setState(() {
      status++;
      if (status >= totalOperation) {
        isLoading = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getThemeMode();

    if (widget.user == null) {
      getUserData();
    } else {
      if (widget.user != null) {
        userModel = widget.user;
        changeState();
      } else {
        fetchUser();
      }
    }
  }

  getThemeMode() async {
    const String themeKey = 'is_dark';
    final prefs = await SharedPreferences.getInstance();
    prefs.getInt(themeKey);
    setState(() {});
  }

  Future<void> fetchUser() async {
    final response = await ApiServices().getUserDetails(context);
    // if (response == null) {
    //   setState(() {
    //     changeState();
    //   });

    // context.go('/login');

    //   return;
    // }
    setState(() {
      userModel = response;
      changeState();
    });
  }

  getUserData() async {
    final user = await SharedService().getUserDetails();
    if (user['name'] == null || user['email'] == null) {
      await fetchUser();
      UserModel userM = UserModel(
          email: user['email'] ?? 'user@iith.ac.in',
          name: user['name'] ?? 'User');
      setState(() {
        userModel = userM;
        changeState();
      });
    } else {
      UserModel userM = UserModel(
          email: user['email'] ?? 'user@iith.ac.in',
          name: user['name'] ?? 'User');
      setState(() {
        userModel = userM;
        changeState();
        changeState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: BoldText(
              text: 'IGH Room Boooking',
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
              size: 28,
            ),
            automaticallyImplyLeading: true,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        width: double.infinity,
                        height: 200,
                        image: AssetImage(
                          'assets/icons/igh.jpg',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TextField(
                          readOnly: true,
                          controller: _studentNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: userModel?.name,
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
                          readOnly: true,
                          controller: _emailController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: userModel?.email,
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
                          controller: _customerName,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Enter the name of the customer',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: TextField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Age',
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  isExpanded: true,
                                  items: [
                                    DropdownMenuItem(
                                      value: "Father",
                                      child: Text(
                                        "Father",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                        value: "Mother",
                                        child: Text("Mother",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color))),
                                    DropdownMenuItem(
                                      value: "Sibling",
                                      child: Text("Sibling",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color)),
                                    ),
                                    DropdownMenuItem(
                                      value: "Gaurdian",
                                      child: Text("Gaurdian",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color)),
                                    ),
                                  ],
                                  value: _relationWithStudent,
                                  onChanged: (String? selectedValue) {
                                    if (selectedValue is String) {
                                      setState(() {
                                        _relationWithStudent = selectedValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      onTap: () async {
                        Map<String, dynamic> bookingDetails = {
                          "student_name": userModel!.name,
                          "student_email": userModel!.email,
                          "customer_name": _customerName.text,
                          "age": int.tryParse(_ageController.text) ?? 0,
                          "relation_with_student":
                              _relationWithStudent, // Ensure this is assigned before calling
                        };

                        bool success = await ApiServices()
                            .bookIghRoom(context, bookingDetails);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(success
                                  ? "Room booked successfully!"
                                  : "Room booking failed.")),
                        );
                        if (success) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30.0, 8, 30, 8),
                          child: Text('Submit',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
