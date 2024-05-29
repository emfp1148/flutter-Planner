import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  final int initialMinutes;
  final int initialSeconds;

  const TimePicker({
    super.key,
    required this.initialMinutes,
    required this.initialSeconds,
  });

  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late int minutes;
  late int seconds;

  @override
  void initState() {
    super.initState();
    minutes = widget.initialMinutes;
    seconds = widget.initialSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Time'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimePicker(minutes, (value) {
            setState(() {
              minutes = value;
            });
          }, 59),
          const Text(':'),
          _buildTimePicker(seconds, (value) {
            setState(() {
              seconds = value;
            });
          }, 59),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newSeconds = minutes * 60 + seconds;
            Navigator.pop(context, newSeconds);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildTimePicker(int value, Function(int) onChanged, int maxValue) {
    return SizedBox(
      width: 80,
      child: ListWheelScrollView.useDelegate(
        perspective: 0.005,
        itemExtent: 50,
        onSelectedItemChanged: (index) => onChanged(index),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: maxValue + 1,
          builder: (context, index) {
            return Text(
              index.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 24),
            );
          },
        ),
      ),
    );
  }
}
