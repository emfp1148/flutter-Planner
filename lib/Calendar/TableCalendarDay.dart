import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './database_helper.dart';
import './AddEventScreen.dart';
import './View.dart';

class SimpleCalendarScreen extends StatefulWidget {
  const SimpleCalendarScreen({super.key});

  @override
  State<SimpleCalendarScreen> createState() => _SimpleCalendarScreenState();
}

class _SimpleCalendarScreenState extends State<SimpleCalendarScreen> {
  List<Event> selectedEvents = [];
  DateTime selectedDay = DateTime.now();

  final TextEditingController _eventController = TextEditingController();

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  Future<void> _loadEventsForSelectedDay() async {
    final eventsFromDb =
        await DatabaseHelper.instance.readEventsByDate(selectedDay);
    setState(() {
      selectedEvents = eventsFromDb;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEventsForSelectedDay();
  }

  void _moveToNextDay() {
    setState(() {
      selectedDay = selectedDay.add(const Duration(days: 1));
    });
    _loadEventsForSelectedDay();
  }

  void _moveToPreviousDay() {
    setState(() {
      selectedDay = selectedDay.subtract(const Duration(days: 1));
    });
    _loadEventsForSelectedDay();
  }

  Future<void> _addEvent(Event event, DateTime date, TimeOfDay startTime,
      TimeOfDay endTime) async {
    final eventsFromDb = await DatabaseHelper.instance.readEventsByDate(date);
    final eventExists = eventsFromDb.any((e) =>
        e.title == event.title &&
        e.date == event.date &&
        e.startTime == event.startTime &&
        e.endTime == event.endTime);

    if (!eventExists) {
      await DatabaseHelper.instance.create(event);
      if (isSameDay(selectedDay, date)) {
        setState(() {
          selectedEvents.add(event);
        });
      }
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calendar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _moveToPreviousDay,
                  ),
                  Text(
                    DateFormat.yMMMMd().format(selectedDay),
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _moveToNextDay,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '오늘의 일정',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            eventListView(
                selectedEvents: selectedEvents,
                eventController: _eventController)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEventScreen(
                onAddEvent: (event, date, startTime, endTime) async {
                  await _addEvent(event, date, startTime, endTime);
                  return true;
                },
              ),
            ),
          );
          if (result == true) {
            await _loadEventsForSelectedDay();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
