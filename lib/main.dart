import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import './Calendar/TableCalendar.dart';
import './Calendar/TableCalendarWeek.dart';
import './Calendar/TableCalendarDay.dart';
import 'package:planner_application/Calendar/TableCalendar.dart';

void main() async {
  await initializeDateFormatting();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Color(0xFF232B55),
          ),
        ),
        cardColor: Color(0xFF81D4FA),
      ),
      home: const TableCalendarScreen(),
    // return const MaterialApp(
      // home: TableCalendarScreen(),
      // home: TableCalendarScreenWeek(),
      // home: SimpleCalendarScreen(),
    );
  }
}
