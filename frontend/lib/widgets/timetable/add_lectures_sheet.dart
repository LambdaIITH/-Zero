import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:dashbaord/widgets/timetable/lecture_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddLectureBottomSheet extends StatefulWidget {
  final Timetable? timetable;
  final Function(String, String, List<Lecture>)? onLectureAdded;

  const AddLectureBottomSheet(
      {super.key, required this.timetable, required this.onLectureAdded});

  @override
  State<AddLectureBottomSheet> createState() => _AddLectureBottomSheetState();
}

class _AddLectureBottomSheetState extends State<AddLectureBottomSheet> {
  List<Lecture> slots = [];

  final daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  DateTime selectedDate = DateTime.parse("2024-10-26 09:30:00");

  void _showSlotPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return LectureTimePickerBottomSheet(
          onSlotSelected: (newSlots) {
            setState(() {
              slots.addAll(newSlots);
            });
          },
        );
      },
    );
  }

  final TextEditingController courseTitleController = TextEditingController();
  final TextEditingController courseCodeController = TextEditingController();
  TextInputType currentKeyboardType = TextInputType.text;
  final FocusNode _courseCodeFocusNode = FocusNode();
  final FocusNode _courseTitleFocusNode = FocusNode();
  bool isNotFilled = false;

  String courseCode = '';

  void _checkFields() {
    if (isNotFilled == true) {
      setState(() {
        isNotFilled = courseCodeController.text.isEmpty ||
            courseTitleController.text.isEmpty;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    courseCodeController.addListener(_checkFields);
    courseTitleController.addListener(_checkFields);
  }

  @override
  void dispose() {
    courseCodeController.dispose();
    _courseCodeFocusNode.dispose();
    super.dispose();
  }

  void _refreshKeyboard() {
    _courseCodeFocusNode.unfocus();
    Future.delayed(Duration(milliseconds: 10), () {
      _courseCodeFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Material(
        elevation: 12,
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(25),
        shadowColor: Colors.white.withOpacity(0.3),
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Text(
                "Add Lecture",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: CupertinoTextField(
                      onChanged: (text) {
                        if (text.length >= 2 &&
                            currentKeyboardType != TextInputType.number) {
                          setState(() {
                            currentKeyboardType = TextInputType.number;
                          });
                          _refreshKeyboard();
                        }

                        if (text.length < 2 &&
                            currentKeyboardType != TextInputType.text) {
                          setState(() {
                            currentKeyboardType = TextInputType.text;
                          });
                          _refreshKeyboard();
                        }

                        if (text.length == 6) {
                          _courseTitleFocusNode.requestFocus();
                        }
                      },
                      keyboardType: currentKeyboardType,
                      focusNode: _courseCodeFocusNode,
                      controller: courseCodeController,
                      placeholder: 'Code',
                      textCapitalization: TextCapitalization.characters,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      cursorColor: Colors.blueAccent,
                      placeholderStyle: GoogleFonts.inter(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 11,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CupertinoTextField(
                        focusNode: _courseTitleFocusNode,
                        controller: courseTitleController,
                        placeholder: 'Course Title',
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Colors.blueAccent, // Cursor color
                        placeholderStyle: GoogleFonts.inter(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              isNotFilled
                  ? Text("Please fill in both fields",
                      style: TextStyle(
                        color: Colors.red,
                      ))
                  : SizedBox(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Slots",
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (courseCodeController.text.isEmpty ||
                          courseTitleController.text.isEmpty) {
                        setState(() {
                          isNotFilled = true;
                        });

                        if (courseCodeController.text.isEmpty) {
                          _courseCodeFocusNode.requestFocus();
                        } else if (courseTitleController.text.isEmpty) {
                          _courseTitleFocusNode.requestFocus();
                        }
                        return;
                      }
                      _showSlotPicker();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Slot"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 1),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: slots.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  return Dismissible(
                    key: Key(slot.day + slot.startTime + slot.endTime),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        slots.removeAt(index);
                      });
                    },
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          NormalText(
                              text: slot.day,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                          Row(
                            children: [
                              NormalText(
                                  text: "${slot.startTime} - ${slot.endTime}",
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                              IconButton(
                                icon:
                                    Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  // Add a confirm dialog if you want to ask before deleting
                                  setState(() {
                                    slots.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (courseCodeController.text.isEmpty ||
                        courseTitleController.text.isEmpty) {
                      setState(() {
                        isNotFilled = true;
                      });

                      if (courseCodeController.text.isEmpty) {
                        _courseCodeFocusNode.requestFocus();
                      } else if (courseTitleController.text.isEmpty) {
                        _courseTitleFocusNode.requestFocus();
                      }
                      return;
                    }



                    if (widget.onLectureAdded != null) {
                      widget.onLectureAdded!(
                        courseCodeController.text,
                        courseTitleController.text,
                        slots.map((slot) {
                          return Lecture(
                            day: slot.day,
                            startTime: slot.startTime,
                            endTime: slot.endTime,
                            courseCode: courseCodeController.text,
                          );
                        }).toList(),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white // Button color
                      ),
                  child: const Text(
                    "Add Course",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
