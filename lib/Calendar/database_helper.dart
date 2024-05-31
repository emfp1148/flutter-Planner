import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart'; // Add this line

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('events.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const dateType = 'TEXT NOT NULL';
    const timeType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE events ( 
      ${EventFields.id} $idType, 
      ${EventFields.title} $textType,
      ${EventFields.date} $dateType,
      ${EventFields.startTime} $timeType,
      ${EventFields.endTime} $timeType
      )
    ''');
  }

  Future<int> create(Event event) async {
    final db = await instance.database;

    final id = await db.insert(tableEvents, event.toJson());
    return id;
  }

  Future<List<Event>> readEventsByDate(DateTime date) async {
    final db = await instance.database;

    final result = await db.query(
      tableEvents,
      columns: EventFields.values,
      where: '${EventFields.date} = ?',
      whereArgs: [DateFormat('yyyy-MM-dd').format(date)],
      orderBy: '${EventFields.startTime} ASC', // Order by start time
    );


    return result.map((json) => Event.fromJson(json)).toList();
  }

  Future<List<Event>> readEventsByMonth(DateTime date) async {
    final db = await instance.database;

    final result = await db.query(
      tableEvents,
      columns: EventFields.values,
      where: '${EventFields.date} LIKE ?',
      whereArgs: ['${DateFormat('yyyy-MM').format(date)}%'], // Match year and month
      orderBy: '${EventFields.date} ASC, ${EventFields.startTime} ASC',   // Order by start time

    );

    return result.map((json) => Event.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

const String tableEvents = 'events';

class EventFields {
  static final List<String> values = [id, title, date, startTime, endTime];

  static const String id = '_id';
  static const String title = 'title';
  static const String date = 'date';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';
}

class Event {
  final int? id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;

  const Event({
    this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  Event copy({
    int? id,
    String? title,
    String? date,
    String? startTime,
    String? endTime,
  }) =>
      Event(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
      );

  static Event fromJson(Map<String, Object?> json) => Event(
        id: json[EventFields.id] as int?,
        title: json[EventFields.title] as String,
        date: json[EventFields.date] as String,
        startTime: json[EventFields.startTime] as String,
        endTime: json[EventFields.endTime] as String,
      );

  Map<String, Object?> toJson() => {
        EventFields.id: id,
        EventFields.title: title,
        EventFields.date: date,
        EventFields.startTime: startTime,
        EventFields.endTime: endTime,
      };
}
