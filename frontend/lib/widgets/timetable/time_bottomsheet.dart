import 'package:flutter/material.dart';

class TimePickerBottomSheet extends StatefulWidget {
  final DateTime initialTime;
  final Function(DateTime) onTimeSelected;

  const TimePickerBottomSheet({
    Key? key,
    required this.initialTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  _TimePickerBottomSheetState createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = (widget.initialTime.minute >= 30) ? 30 : 0;
  }

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 0;
    final List<String> _options = [
      'Item 1',
      'Item 2',
      'Item 3',
      'Item 4',
      'Item 5'
    ];

    return Container(
      height: 300,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Selected: ${_options[_selectedIndex]}',
                style: TextStyle(fontSize: 18, color: Colors.black)),
            SizedBox(height: 20),
            SizedBox(
              height: 75,
              child: ListWheelScrollView(
                itemExtent: 50,
                physics: FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: _options.map((option) {
                  return Center(
                    child: Text(
                      option,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
