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

  void _showEditDialog(BuildContext context, Event event) {
    final controller = TextEditingController(text: event.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('일정 수정'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '일정 입력'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final updatedEvent = event.copy(title: controller.text);
                await DatabaseHelper.instance.update(updatedEvent);

                Navigator.of(context).pop();
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(int id) async {
    await DatabaseHelper.instance.delete(id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedEvents.isNotEmpty) ...[
          ...selectedEvents.map((event) => ListTile(
                title: Text(event.title),
                subtitle: Text('${event.startTime} - ${event.endTime}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () {
                          _deleteEvent(event.id!);
                        },
                        icon: Icon(Icons.delete)),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditDialog(context, event);
                      },
                    ),
                  ],
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
