import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './database_helper.dart';

class AddEventScreen extends StatefulWidget {
  final Function(Event, DateTime, TimeOfDay, TimeOfDay) onAddEvent;

  const AddEventScreen({super.key, required this.onAddEvent});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '일정 제목'),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title:
                  Text('날짜: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            ListTile(
              title: Text('시작 시간: ${_startTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _startTime,
                );
                if (picked != null && picked != _startTime) {
                  setState(() {
                    _startTime = picked;
                  });
                }
              },
            ),
            ListTile(
              title: Text('끝나는 시간: ${_endTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _endTime,
                );
                if (picked != null && picked != _endTime) {
                  setState(() {
                    _endTime = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty) {
                  final event = Event(
                    title: _titleController.text,
                    date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                    startTime: _startTime.format(context),
                    endTime: _endTime.format(context),
                  );
                  // if (_startTime.isAfter(_endTime) ||
                  //     _startTime == _endTime){
                  //   debugPrint('시작 시간이 끝나는 시간보다 늦을 수 없습니다.');
                  //   return;
                  // }
                  final id = await DatabaseHelper.instance.create(event);
                  if (id != 0) {
                    debugPrint('Event added to DB with id: $id');
                  } else {
                    debugPrint('Failed to add event to DB');
                  }

                  widget.onAddEvent(
                    event,
                    _selectedDate,
                    _startTime,
                    _endTime,
                  );

                  // DB에서 모든 이벤트를 가져와서 출력
                  // final allEvents =
                  //     await DatabaseHelper.instance.readAllEvents();
                  // for (var event in allEvents) {
                  //   debugPrint(
                  //       'Event(id: ${event.id}, title: ${event.title}, date: ${event.date}, startTime: ${event.startTime}, endTime: ${event.endTime})');
                  // }

                  Navigator.pop(context);
                }
              },
              child: const Text('일정 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
