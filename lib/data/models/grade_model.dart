// class Grade {
//   final int id;
//   final int courseId;
//   final String title;
//   final String type; // 'lab', 'kr' etc.
//   final int score;

//   Grade({
//     required this.id,
//     required this.courseId,
//     required this.title,
//     required this.type,
//     required this.score,
//   });
// }



class Grade {
  final String id;
  final String title; 
  final String type;  
  final int score;   

  Grade({
    required this.id,
    required this.title,
    required this.type,
    required this.score,
  });

  factory Grade.fromMap(Map<String, dynamic> data, String documentId) {
    return Grade(
      id: documentId,
      title: data['title'] ?? '',
      type: data['type'] ?? 'Інше',
      score: (data['score'] ?? 0).toInt(), // Захист, якщо раптом там не число
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'score': score,
    };
  }
}