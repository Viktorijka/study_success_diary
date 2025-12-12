// import 'package:flutter/foundation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../data/models/user_model.dart';

// class UserRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   String? get currentUserId => _auth.currentUser?.uid;

//   Future<UserModel?> getUserData() async {
//     if (currentUserId == null) return null;

//     try {
//       final doc = await _firestore.collection('users').doc(currentUserId).get();
//       if (doc.exists && doc.data() != null) {
//         return UserModel.fromMap(doc.data()!, doc.id);
//       }
//     } catch (e) {
//       debugPrint('Error getting user data: $e');
//     }
//     return null;
//   }

//   Future<void> updateUser(UserModel user) async {
//     if (currentUserId == null) return;
//     await _firestore.collection('users').doc(currentUserId).update(user.toMap());
//   }
// }


import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Отримання даних або СТВОРЕННЯ, якщо їх немає
  Future<UserModel?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        // Варіант А: Користувач вже є в базі -> повертаємо його дані
        return UserModel.fromMap(doc.data()!, doc.id);
      } else {
        // Варіант Б: Користувача немає в базі -> СТВОРЮЄМО ЙОГО
        final newUser = UserModel(
          id: user.uid,
          name: user.displayName ?? 'Новий користувач', // Беремо ім'я з Google або стандартне
          email: user.email ?? '',
          specialty: 'Студент', // Стандартне значення
          university: '',
          avatarUrl: user.photoURL, // Беремо фото з Google, якщо є
        );

        // Зберігаємо в Firestore
        await docRef.set(newUser.toMap());
        
        return newUser;
      }
    } catch (e) {
      debugPrint('Error getting user data: $e');
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    if (currentUserId == null) return;
    // set з параметром merge: true дозволяє оновити поля або створити документ, якщо він зник
    await _firestore.collection('users').doc(currentUserId).set(
      user.toMap(),
      SetOptions(merge: true), 
    );
  }
}