import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import './database_helper.dart';
import './AddEventScreen.dart';

import 'package:planner_application/Calendar/TimerScreen.dart';
import './TableCalendar.dart';
import './TableCalendarDay.dart';

class TableCalendarScreenWeek extends StatefulWidget {
  const TableCalendarScreenWeek({super.key});

  @override
  State<TableCalendarScreenWeek> createState() =>
      _TableCalendarScreenWeekState();
}

class _TableCalendarScreenWeekState extends State<TableCalendarScreenWeek> {
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
    return events[_normalizeDate(day)] ?? [];
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _addEvent(Event event) async {
    final eventsFromDb = await DatabaseHelper.instance
        .readEventsByDate(DateTime.parse(event.date));
    final eventExists = eventsFromDb.any((e) =>
        e.title == event.title &&
        e.date == event.date &&
        e.startTime == event.startTime &&
        e.endTime == event.endTime);

    if (!eventExists) {
      await DatabaseHelper.instance.create(event);
      await _loadEventsForSelectedDay(); // 새로운 이벤트를 추가한 후 다시 로드
    }
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

  void _moveToNextWeek() {
    setState(() {
      focusedDay = focusedDay.add(const Duration(days: 7));
      selectedDay = focusedDay;
    });
    _loadEventsForSelectedDay();
  }

  void _moveToPreviousWeek() {
    setState(() {
      focusedDay = focusedDay.subtract(const Duration(days: 7));
      selectedDay = focusedDay;
    });
    _loadEventsForSelectedDay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Calendar'),
        leading: PopupMenuButton<String>(
          itemBuilder: (BuildContext context) {
            return {'캘린더', '캘린더(일주일)', '캘린더(하루)', '타이머'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
          onSelected: (value) {
            if (value == '캘린더') {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const TableCalendarScreen(),
                ),
              );
            } else if (value == '캘린더(일주일)') {
            } else if (value == '캘린더(하루)') {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const SimpleCalendarScreen(),
                ),
              );
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
              firstDay: DateTime.utc(2021, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: focusedDay,
              eventLoader: _getEventsForDay,
              calendarFormat: CalendarFormat.week,
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
                leftChevronVisible: false,
                rightChevronVisible: false,
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
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events.map((event) {
                          return Container(
                            width: 7.0,
                            height: 7.0,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _moveToPreviousWeek,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _moveToNextWeek,
                ),
              ],
            ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEventScreen(
                onAddEvent: (Event event, DateTime date, TimeOfDay startTime,
                    TimeOfDay endTime) {
                  _addEvent(event);
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
