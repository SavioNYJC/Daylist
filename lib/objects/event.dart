import 'package:material_ui/material_ui.dart';

class Event {
  final String eventName;
  final String description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final IconData? iconID;
  bool isCompleted;

  Event({
    required this.eventName,
    required this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.iconID,
    this.isCompleted = false,
  });
}
