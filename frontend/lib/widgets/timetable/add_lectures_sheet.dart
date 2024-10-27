import 'package:dashbaord/utils/normal_text.dart';
import 'package:dashbaord/widgets/timetable/lecture_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddLectureBottomSheet extends StatefulWidget {
  @override
  _AddLectureBottomSheetState createState() => _AddLectureBottomSheetState();
}

class _AddLectureBottomSheetState extends State<AddLectureBottomSheet> {
  final _nameController = TextEditingController();

  List<Map<String, String>> slots = [
    {"day": "Monday", "from": "02:30pm", "to": "05:30pm"},
    {"day": "Tuesday", "from": "08:00am", "to": "09:00am"}
  ];
  String? selectedDay;

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

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return LectureTimePickerBottomSheet(
          initialDate: selectedDate,
          onDateSelected: (DateTime newDate) {
            setState(() {
              selectedDate = newDate;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
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
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Lecture Title',
                  labelStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
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
                      _showDatePicker();
                      debugPrint(selectedDate.toIso8601String());
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
                    key: Key(slot['day']! + slot['from']! + slot['to']!),
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
                              text: slot['day'] ?? '',
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                          Row(
                            children: [
                              NormalText(
                                  text: "${slot['from']} - ${slot['to']}",
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(

                      // backgroundColor: Colors.redAccent,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white // Button color
                      ),
                  child: const Text(
                    "Add Event",
                    style: TextStyle(fontSize: 18),
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
