class UserModel {
  final String id;
  final String name;
  final String specialty;
  final String university; 
  final String email;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.university = '', 
    required this.email,
    this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      university: data['university'] ?? '', 
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'university': university,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? specialty,
    String? university, 
    String? email,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      university: university ?? this.university, 
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}