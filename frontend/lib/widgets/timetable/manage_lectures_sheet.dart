import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:dashbaord/widgets/timetable/lecture_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageLecturesBottomSheet extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final String? slot;
  final String? classRoom;
  final List<Lecture> courseSlots;
  final Timetable? timetable;

  final Function(String, String, List<Lecture>, String?, String?)?
      onLectureEdited;

  const ManageLecturesBottomSheet(
      {super.key,
      required this.courseCode,
      required this.courseName,
      required this.courseSlots,
      this.classRoom,
      this.slot,
      required this.onLectureEdited,
      required this.timetable});

  @override
  State<ManageLecturesBottomSheet> createState() =>
      ManageLecturesBottomSheetState();
}

class ManageLecturesBottomSheetState extends State<ManageLecturesBottomSheet> {
  List<Lecture> slots = [];
  String courseName = '';
  String? selectedSlot;

  @override
  void initState() {
    super.initState();
    slots = widget.courseSlots;
    courseName = widget.courseName;
  }

  void _showSlotPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return LectureTimePickerBottomSheet(
          timetable: widget.timetable,
          onSlotSelected: (newSlots, slot) {
            setState(() {
              selectedSlot = slot;
              slots.addAll(newSlots);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                '${widget.courseCode}${widget.classRoom != null ? ' | ${widget.classRoom}' : ''}${widget.slot != null ? ' | ${widget.slot} slot' : ''}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showEditCourseNameDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
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
              const SizedBox(height: 16),
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
                child: Container(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () {
                      widget.onLectureEdited!(
                          widget.courseCode, courseName, slots, null, null);
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Future<dynamic> showEditCourseNameDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title:
              Text('Edit Title', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: TextEditingController(text: courseName),
              onChanged: (value) {
                newName = value;
              },
              decoration: InputDecoration(
                hintText: "Enter new title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  courseName = newName;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
