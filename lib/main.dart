import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import './Calendar/TableCalendar.dart';
import './Calendar/TableCalendarWeek.dart';
import './Calendar/TableCalendarDay.dart';

void main() async {
  await initializeDateFormatting();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // home: TableCalendarScreen(),
      // home: TableCalendarScreenWeek(),
      home: SimpleCalendarScreen(),
    );
  }
}
