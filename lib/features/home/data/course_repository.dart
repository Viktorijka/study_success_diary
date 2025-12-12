import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/grade_model.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/reminder_model.dart';

abstract class CourseRepository {
  Stream<List<Course>> getUserCourses();
  Future<void> addCourse(Course course);
  Future<void> updateCourse(Course course); 
  Future<void> deleteCourse(String courseId);

  Stream<List<Grade>> getGrades(String courseId);
  Future<void> addGrade(String courseId, Grade grade);
  Future<void> updateGrade(String courseId, Grade grade); 
  Future<void> deleteGrade(String courseId, String gradeId);
  
  Stream<List<Note>> getNotes(String courseId);
  Future<void> addNote(String courseId, Note note);
  Future<void> updateNote(String courseId, Note note); 
  Future<void> deleteNote(String courseId, String noteId);

  Stream<List<Reminder>> getReminders(String courseId);
  Future<void> addReminder(String courseId, Reminder reminder);
  Future<void> deleteReminder(String courseId, String reminderId);
  Future<void> toggleReminderStatus(String courseId, String reminderId, bool currentStatus);
}

class FirestoreCourseRepository implements CourseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  @override
  Stream<List<Course>> getUserCourses() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('courses')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Course.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> addCourse(Course course) async {
    if (_userId == null) return;
    final data = course.toMap();
    data['userId'] = _userId;
    await _firestore.collection('courses').add(data);
  }

  @override
  Future<void> updateCourse(Course course) async {
    await _firestore.collection('courses').doc(course.id).update(course.toMap());
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _firestore.collection('courses').doc(courseId).delete();
  }

  // Grades 
  @override
  Stream<List<Grade>> getGrades(String courseId) {
    return _firestore.collection('courses').doc(courseId).collection('grades')
        .snapshots()
        .map((s) => s.docs.map((d) => Grade.fromMap(d.data(), d.id)).toList());
  }

  @override
  Future<void> addGrade(String courseId, Grade grade) async {
    await _firestore.collection('courses').doc(courseId).collection('grades').add(grade.toMap());
  }

  @override
  Future<void> updateGrade(String courseId, Grade grade) async {
     await _firestore.collection('courses').doc(courseId).collection('grades').doc(grade.id).update(grade.toMap());
  }

  @override
  Future<void> deleteGrade(String courseId, String gradeId) async {
    await _firestore.collection('courses').doc(courseId).collection('grades').doc(gradeId).delete();
  }

  // Notes 
  @override
  Stream<List<Note>> getNotes(String courseId) {
    return _firestore.collection('courses').doc(courseId).collection('notes')
        .snapshots()
        .map((s) => s.docs.map((d) => Note.fromMap(d.data(), d.id)).toList());
  }

  @override
  Future<void> addNote(String courseId, Note note) async {
    final data = note.toMap();
    data['courseId'] = courseId; // Ensure courseId is saved
    await _firestore.collection('courses').doc(courseId).collection('notes').add(data);
  }

  @override
  Future<void> updateNote(String courseId, Note note) async {
    final data = note.toMap();
    data['courseId'] = courseId;
    await _firestore.collection('courses').doc(courseId).collection('notes').doc(note.id).update(data);
  }

   @override
  Future<void> deleteNote(String courseId, String noteId) async {
    await _firestore.collection('courses').doc(courseId).collection('notes').doc(noteId).delete();
  }


  // Reminders
  @override
  Stream<List<Reminder>> getReminders(String courseId) {
    return _firestore.collection('courses').doc(courseId).collection('reminders')
        .snapshots()
        .map((s) => s.docs.map((d) => Reminder.fromMap(d.data(), d.id)).toList());
  }

  @override
  Future<void> addReminder(String courseId, Reminder reminder) async {
    await _firestore.collection('courses').doc(courseId).collection('reminders').add(reminder.toMap());
  }
  
  @override
  Future<void> deleteReminder(String courseId, String reminderId) async {
    await _firestore.collection('courses').doc(courseId).collection('reminders').doc(reminderId).delete();
  }

  @override
  Future<void> toggleReminderStatus(String courseId, String reminderId, bool currentStatus) async {
    await _firestore.collection('courses').doc(courseId).collection('reminders')
        .doc(reminderId).update({'isDone': !currentStatus});
  }
}