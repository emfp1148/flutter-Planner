import 'package:flutter/material.dart';
import './database_helper.dart';

class EventListView extends StatelessWidget {
  const EventListView({
    super.key,
    required this.selectedEvents,
    required TextEditingController eventController,
  }) : _eventController = eventController;

  final List<Event> selectedEvents;
  final TextEditingController _eventController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
    );
  }
}
