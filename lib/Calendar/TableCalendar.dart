import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_application/Calendar/TimerScreen.dart';
import 'package:table_calendar/table_calendar.dart';

import './AddEventScreen.dart';
import './database_helper.dart';
import './View.dart';

class TableCalendarScreen extends StatefulWidget {
  const TableCalendarScreen({super.key});

  @override
  State<TableCalendarScreen> createState() => _TableCalendarScreenState();
}

class _TableCalendarScreenState extends State<TableCalendarScreen> {

  bool isVisible = false;

  Map<DateTime, List<Event>> events = {};
  List<Event> selectedEvents = [];
  List<Event> selectedEventsMonth = [];

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
      _loadEventForMonth();
    });
  }

  Future<void> _loadEventsForSelectedDay() async {
    final eventsFromDb =
        await DatabaseHelper.instance.readEventsByDate(selectedDay);
    setState(() {
      selectedEvents = eventsFromDb;
    });
  }

  Future<void> _loadEventForMonth() async{
    final eventsFromDb =
        await DatabaseHelper.instance.readEventsByMonth(selectedDay);
    setState(() {
      selectedEventsMonth = eventsFromDb;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEventsForSelectedDay();
    _loadEventForMonth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer : Drawer(
        child:ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('lib/assets/image/6915987.png'),
              ),
              accountName: Text('ChosunPoolFive'),
              accountEmail: Text('ChosunPoolFive@chosun.ac.kr'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(
              Icons.open_in_browser,
              color: Colors.grey[850],
            ),
              title: Text('이번 달 일정'),
              onTap: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },

            ),
            Visibility(
              visible: isVisible,
              child: SingleChildScrollView(
                    child:eventListView(
                      selectedEvents: selectedEventsMonth,
                      eventController: _eventController,
                    ),
                ),
            ),
          ],
        ),
        ),
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
            Stack(
              children: <Widget>[
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
                    _loadEventForMonth();
                  },
                  onPageChanged: (day){
                    setState(() {
                      focusedDay = DateTime(day.year, day.month, day.day);
                      selectedDay = DateTime(day.year, day.month, day.day);
                    });
                    _loadEventsForSelectedDay(); // 날짜가 선택될 때 이벤트 로드
                    _loadEventForMonth();
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
                Positioned(
                  top: 10,
                  left: MediaQuery.of(context).size.width/2-80,       //화면 넓이 double,
                  child: Opacity(
                    opacity: 0.5, // 투명도 0으로 할 예정
                    child: ElevatedButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: focusedDay,
                            firstDate: DateTime(2021, 10, 16),
                            lastDate: DateTime(2030, 3, 14),
                          );
                          if (picked != null && picked != focusedDay) {
                            setState(() {
                              focusedDay = picked;
                              selectedDay = picked;
                            });
                            _loadEventsForSelectedDay();
                            _loadEventForMonth();
                          }
                        },
                        child: Container(
                          width: 110,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)
                          ),
                        )
                    ),
                  ),
                ),
               ]
             ),
              eventListView(
                selectedEvents: selectedEvents,
                eventController: _eventController
              )
          ]
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
