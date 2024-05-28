import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './database_helper.dart';
import './AddEventScreen.dart';

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

  void _addEvent(
      Event event, DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    setState(() {
      DatabaseHelper.instance.create(event);
      _loadEventsForSelectedDay(); // 새로운 이벤트를 추가한 후 다시 로드
    });
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
            if (selectedEvents.isNotEmpty) ...[
              ...selectedEvents.map((event) => ListTile(
                    title: Text(event.title),
                    subtitle: Text('${event.startTime} - ${event.endTime}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _eventController.text = event.title;
                      },
                    ),
                  )),
            ] else ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '일정이 없습니다.',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEventScreen(
                onAddEvent: _addEvent,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
