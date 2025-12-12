import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String title;
  final DateTime? deadline;
  final bool isDone;

  Reminder({
    required this.id,
    required this.title,
    this.deadline,
    required this.isDone,
  });

  factory Reminder.fromMap(Map<String, dynamic> data, String documentId) {
    return Reminder(
      id: documentId,
      title: data['title'] ?? '',
      // Обробка дати
      deadline: data['deadline'] != null ? (data['deadline'] as Timestamp).toDate() : null,
      isDone: data['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'isDone': isDone,
    };
  }
}