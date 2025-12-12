// class Note {
//   final int id;
//   final int courseId;
//   final String title;
//   final String content;

//   Note({
//     required this.id,
//     required this.courseId,
//     required this.title,
//     required this.content,
//   });
// }



import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime? date;
  
  // ОСЬ ЦЕ ПОЛЕ, ЯКОГО НЕ ВИСТАЧАЛО
  final String courseId; 

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.date,
    this.courseId = '', // Значення за замовчуванням, щоб не ламалось
  });

  factory Note.fromMap(Map<String, dynamic> data, String documentId) {
    return Note(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      // Зчитуємо courseId, якщо його немає - буде пустий рядок
      courseId: data['courseId'] ?? '', 
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'courseId': courseId,
      'date': date != null ? Timestamp.fromDate(date!) : FieldValue.serverTimestamp(),
    };
  }
}