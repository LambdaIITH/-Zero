import 'package:dashbaord/constants/enums/iith_slots.dart';
import 'package:dashbaord/models/lecture_model.dart';
import 'package:dashbaord/models/time_table_model.dart';
import 'package:dashbaord/utils/normal_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LectureTimePickerBottomSheet extends StatefulWidget {
  final Function(List<Lecture>) onSlotSelected;
  final Timetable? timetable;

  const LectureTimePickerBottomSheet(
      {super.key, required this.onSlotSelected, required this.timetable});

  @override
  State<LectureTimePickerBottomSheet> createState() =>
      _LectureTimePickerBottomSheetState();
}

class _LectureTimePickerBottomSheetState
    extends State<LectureTimePickerBottomSheet> {
  String selectedDay = "Monday",
      selectedStartTime = "9:00 AM",
      selectedEndTime = "10:00 AM";
  bool isTimePickerSelected = false;
  DateTime initialDate = DateTime.parse("2024-10-26 09:00:00");

  final List<String> slots = getAllSlots();
  String selectedSlot = "A";

  void _addSlots() {
    List<Lecture> newLectures = [];

    if (isTimePickerSelected) {
      newLectures = [
        Lecture(
            startTime: selectedStartTime,
            endTime: selectedEndTime,
            day: selectedDay,
            courseCode: "")
      ];
    } else {
      newLectures = getSlotFromString(selectedSlot)!.getLectures();
    }


    List<Lecture> existingLectures = widget.timetable?.slots ?? [];
    bool hasAnyCollision = false;
    List<Lecture> conflictingLectures = [];

    for (Lecture newLecture in newLectures) {
      for (Lecture existingLecture in existingLectures) {
        if (lecturesOverlap(newLecture, existingLecture)) {
          hasAnyCollision = true;
          conflictingLectures.add(newLecture);
          break;
        }
      }
    }

    if (hasAnyCollision) {
      String message =
          'The slots you are trying to add conflict with the following existing lectures in your timetable:\n\n';
      for (Lecture lecture in conflictingLectures) {
        message +=
            '- ${lecture.courseCode.isNotEmpty ? lecture.courseCode : ""} on ${lecture.day} from ${lecture.startTime} to ${lecture.endTime}\n';
      }
      message +=
          '\nPlease select different slots or times that do not conflict with your existing timetable.';

      Future.delayed(Duration(milliseconds: 100), () {
        showDialog(
          context: context,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Conflict Detected'),
              content: SingleChildScrollView(
                child: Text(message),
              ),
              actionsAlignment: MainAxisAlignment.center, // Center the actions
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Grey background for cancel
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: 10), // Add space between buttons
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Add Anyway'),
                  onPressed: () {
                    widget.onSlotSelected(newLectures);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    } else {
      widget.onSlotSelected(newLectures);
      Navigator.of(context).pop();
    }
  }

  bool lecturesOverlap(Lecture a, Lecture b) {
    if (a.day != b.day) return false;

    DateFormat format = DateFormat('h:mm a');

    DateTime aStart = format.parse(a.startTime);
    DateTime aEnd = format.parse(a.endTime);
    DateTime bStart = format.parse(b.startTime);
    DateTime bEnd = format.parse(b.endTime);

    DateTime referenceDate = DateTime(2000, 1, 1);
    aStart = DateTime(referenceDate.year, referenceDate.month,
        referenceDate.day, aStart.hour, aStart.minute);
    aEnd = DateTime(referenceDate.year, referenceDate.month, referenceDate.day,
        aEnd.hour, aEnd.minute);
    bStart = DateTime(referenceDate.year, referenceDate.month,
        referenceDate.day, bStart.hour, bStart.minute);
    bEnd = DateTime(referenceDate.year, referenceDate.month, referenceDate.day,
        bEnd.hour, bEnd.minute);

    return aStart.isBefore(bEnd) && aEnd.isAfter(bStart);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(24),
      ),
      color: Theme.of(context).canvasColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 5),
            child: const Text(
              "Add Slot",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: CupertinoSlidingSegmentedControl<bool>(
              // currently selected option [Select Time, Select Slot]
              groupValue: isTimePickerSelected,
              onValueChanged: (bool? value) {
                debugPrint(value.toString());
                if (value != null) {
                  debugPrint("Selected: $value, Actual: $isTimePickerSelected");
                  setState(() {
                    isTimePickerSelected = value;
                  });
                }
              },
              children: {
                false: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: NormalText(
                    text: "Select Slot",
                    size: 14,
                  ),
                ),
                true: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: NormalText(
                    text: "Select Time",
                    size: 14,
                  ),
                ),
              },
            ),
          ),
          if (isTimePickerSelected) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (String day in [
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday",
                    "Sunday"
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 1, horizontal: 4),
                      child: ElevatedButton(
                          onPressed: () {
                            debugPrint("$day $selectedDay");
                            setState(() {
                              debugPrint("$day $selectedDay");
                              selectedDay = day;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedDay == day
                                ? Colors.red
                                : Theme.of(context).cardColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: selectedDay == day
                                    ? Colors.red
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: NormalText(
                            text: day,
                            color: selectedDay == day
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            size: 16,
                          )),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: CupertinoDatePicker(
                      minuteInterval: 30,
                      itemExtent: 50,
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: initialDate,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() {
                          selectedStartTime =
                              DateFormat('h:mm a').format(newDate);
                        });
                      },
                    ),
                  ),
                ),
                Icon(CupertinoIcons.arrow_right),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: CupertinoDatePicker(
                      minuteInterval: 30,
                      itemExtent: 50,
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: initialDate.add(
                        Duration(
                          hours: 1,
                        ),
                      ),
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() {
                          selectedEndTime =
                              DateFormat('h:mm a').format(newDate);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Select Slot",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 50.0,
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          selectedSlot = slots[index];
                        });
                      },
                      children: slots
                          .map((slot) => Center(
                                child: Text(
                                  slot,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () {
                _addSlots();
                // Navigator.of(context).pop();
              },
              child: const Icon(Icons.check, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
