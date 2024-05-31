import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_application/Calendar/TimerScreen.dart';
import 'package:table_calendar/table_calendar.dart';

import './AddEventScreen.dart';
import './database_helper.dart';
import './AddEventScreen.dart';
import './View.dart';

class TableCalendarScreen extends StatefulWidget {
  const TableCalendarScreen({super.key});

  @override
  State<TableCalendarScreen> createState() => _TableCalendarScreenState();
}

class _TableCalendarScreenState extends State<TableCalendarScreen> {
  Map<DateTime, List<Event>> events = {};
  List<Event> selectedEvents = [];

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  final TextEditingController _eventController = TextEditingController();

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  void _addEvent(
      Event event, DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    setState(() {
      events[date] = [..._getEventsForDay(date), event];
      _loadEventsForSelectedDay(); // 새로운 이벤트를 추가한 후 다시 로드
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Calendar'),
        leading: PopupMenuButton<String>(
          itemBuilder: (BuildContext context) {
            return {'캘린더', '타이머'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
          onSelected: (value) {
            if (value == '캘린더') {
            } else if (value == '타이머') {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const TimerScreen(),
                ),
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              '자율설계',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TableCalendar(
              //locale: 'Ko_KR',
              firstDay: DateTime.utc(2021, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: focusedDay,
              eventLoader: _getEventsForDay,
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
                _loadEventsForSelectedDay(); // 날짜가 선택될 때 이벤트 로드
              },
              selectedDayPredicate: (DateTime day) {
                return isSameDay(selectedDay, day);
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextFormatter: (date, locale) =>
                    DateFormat.yMMMM(locale).format(date),
                formatButtonVisible: false,
              ),
              calendarStyle: const CalendarStyle(
                canMarkersOverflow: false,
                markersAutoAligned: true,
                markerSize: 10.0,
                rangeHighlightScale: 1.0,
                rangeHighlightColor: Color(0xFFBBDDFF),
                selectedTextStyle: TextStyle(
                  color: Color(0xFFFAFAFA),
                  fontSize: 16.0,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF5C6BC0),
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.red),
              ),
            ),
            EventListView(
              selectedEvents: selectedEvents,
              eventController: _eventController,
            ),
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
