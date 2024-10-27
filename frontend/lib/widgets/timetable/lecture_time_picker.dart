import 'package:dashbaord/utils/normal_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LectureTimePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  LectureTimePickerBottomSheet({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<LectureTimePickerBottomSheet> createState() =>
      _LectureTimePickerBottomSheetState();
}

class _LectureTimePickerBottomSheetState
    extends State<LectureTimePickerBottomSheet> {
  String selectedDay = "Monday";
  bool isTimePickerSelected = false;
  DateTime initialDate = DateTime.now();
  int selectedWeekday = DateTime.now().weekday;
  final List<String> slots = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "P",
    "Q",
    "R",
    "S",
    "X",
    "Y",
    "Z"
  ];
  String selectedSlot = "A";

  @override
  Widget build(BuildContext context) {
    void onDateSelected(DateTime newDate) {
      debugPrint("Selected date: $newDate");
    }

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
                      initialDateTime: widget.initialDate,
                      onDateTimeChanged: (DateTime newDate) {
                        onDateSelected(newDate);
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
                      initialDateTime: widget.initialDate,
                      onDateTimeChanged: (DateTime newDate) {
                        onDateSelected(newDate);
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
                          debugPrint(selectedSlot);
                          // widget.onSlotSelected(selectedSlot);
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
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.check, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
