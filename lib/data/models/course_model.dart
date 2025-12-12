class Course {
  final String id;
  final String title;
  final String lecturer;
  final String description;
  final String userId;

  Course({
    required this.id,
    required this.title,
    required this.lecturer,
    required this.description,
    required this.userId,
  });

  // Це дозволить старому коду, який шукає .name, працювати з .title
  String get name => title; 

  factory Course.fromMap(Map<String, dynamic> data, String documentId) {
    return Course(
      id: documentId,
      // Беремо 'title', якщо його немає - пробуємо 'name', якщо немає - пустий рядок
      title: data['title'] ?? data['name'] ?? '', 
      lecturer: data['lecturer'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'lecturer': lecturer,
      'description': description,
      'userId': userId,
    };
  }
}