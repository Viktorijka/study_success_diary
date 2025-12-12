import 'dart:async';
import 'dart:typed_data'; 
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/course_model.dart';
import '../../../data/models/grade_model.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/supabase_storage.dart';
import '../data/course_repository.dart';
import '../data/user_repository.dart';
import '../../../data/quote_repository.dart';
import '../../../data/models/quote_model.dart';

enum ViewState { initial, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  final CourseRepository _repository = FirestoreCourseRepository();
  final SupabaseStorageRepository _storageRepository = SupabaseStorageRepository();
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _picker = ImagePicker();  
  final QuoteRepository _quoteRepository = QuoteRepository(); 

  StreamSubscription? _coursesSubscription;
  StreamSubscription? _gradesSubscription;
  StreamSubscription? _notesSubscription;
  StreamSubscription? _remindersSubscription;

  final List<StreamSubscription> _allNotesSubscriptions = [];

  ViewState _state = ViewState.initial;
  ViewState get state => _state;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  UserModel _user = UserModel(id: '', name: 'Завантаження...', specialty: '', email: '');
  UserModel get user => _user;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  Quote? _dailyQuote; 
  Quote? get dailyQuote => _dailyQuote; 

  List<Course> _courses = [];
  List<Course> get courses => _courses;
  List<Grade> _currentCourseGrades = [];
  List<Note> _currentCourseNotes = [];
  List<Reminder> _currentCourseReminders = [];
  final List<Note> _allNotes = [];
  List<Note> get allNotes => _allNotes;

  // Фільтрація оцінок
  List<Grade> get grades {
    if (_selectedGradeType == 'Всі типи') return _currentCourseGrades;
    return _currentCourseGrades.where((g) => g.type == _selectedGradeType).toList();
  }
  
  List<Note> get currentNotes => _currentCourseNotes;
  
  List<Reminder> get reminders {
    final list = List<Reminder>.from(_currentCourseReminders);
    list.sort((a, b) {
      if (a.isDone == b.isDone) {
        if (a.deadline == null || b.deadline == null) return 0;
        return a.deadline!.compareTo(b.deadline!);
      }
      return a.isDone ? 1 : -1;
    });
    return list;
  }

  final List<FlSpot> performanceData = const [
    FlSpot(0, 85), FlSpot(1, 88), FlSpot(2, 87), FlSpot(3, 92), FlSpot(4, 91.5),
  ];
  double get averageGrade => 0.0;
  final double progress = 75.0;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  final PageController pageController = PageController(initialPage: 0);

  Course? _selectedCourse;
  Course? get selectedCourse => _selectedCourse;
  bool _isDetailView = false;
  bool get isDetailView => _isDetailView;

  String _selectedGradeType = 'Всі типи';
  String get selectedGradeType => _selectedGradeType;
  
  // Список типів оцінок
  final List<String> gradeTypes = ['Всі типи', 'Лабораторна', 'Практична', 'Контрольна', 'Екзамен', 'Інше'];

  HomeViewModel() {
    _loadSortPreference();
    _initData();
  }

  Future<void> _fetchUserData() async {
    final userData = await _userRepository.getUserData();
    if (userData != null) {
      _user = userData;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(String name, String specialty, String university) async {
    _user = _user.copyWith(name: name, specialty: specialty, university: university);
    notifyListeners();
    await _userRepository.updateUser(_user);
  }

  Future<void> updateProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, 
      );

      if (pickedFile == null) return;

      _isUploading = true;
      notifyListeners();

      final Uint8List fileBytes = await pickedFile.readAsBytes();
      String downloadUrl = await _storageRepository.uploadAvatar(fileBytes, _userRepository.currentUserId ?? 'temp');

      _user = _user.copyWith(avatarUrl: downloadUrl);
      await _userRepository.updateUser(_user);
      
    } catch (e) {
      debugPrint("Upload error: $e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void _initData() {
    _state = ViewState.loading;
    notifyListeners();

    _fetchUserData();
    _fetchQuote(); 

    _coursesSubscription?.cancel();
    _coursesSubscription = _repository.getUserCourses().listen(
      (coursesList) {
        _courses = coursesList;
        _state = ViewState.success;
        _subscribeToAllNotes(); 
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _state = ViewState.error;
        notifyListeners();
      },
    );
  }

  Future<void> _fetchQuote() async {
    _dailyQuote = await _quoteRepository.getRandomQuote();
    notifyListeners();
  }

  void _subscribeToAllNotes() {
    for (var sub in _allNotesSubscriptions) {
      sub.cancel();
    }
    _allNotesSubscriptions.clear();
    _allNotes.clear();

    for (var course in _courses) {
      var sub = _repository.getNotes(course.id).listen((notes) {
        _allNotes.removeWhere((n) => n.courseId == course.id);
        _allNotes.addAll(notes);
        notifyListeners();
      });
      _allNotesSubscriptions.add(sub);
    }
  }

   Future<void> addNewCourse(String title, String lecturer, String description) async {
    final uid = _userRepository.currentUserId ?? '';
    if (uid.isEmpty) return; // Захист, якщо юзер не залогінився

    await _repository.addCourse(Course(
      id: '', 
      title: title, 
      lecturer: lecturer, 
      description: description, 
      userId: uid 
    ));
  }

   Future<void> updateCourse(String id, String title, String lecturer, String desc) async {
      final uid = _userRepository.currentUserId ?? '';
      
      await _repository.updateCourse(Course(
        id: id, 
        title: title, 
        lecturer: lecturer, 
        description: desc, 
        userId: uid // <--- ТУТ БУЛА ПОМИЛКА (було '')
      ));
  }
  Future<void> deleteCourse(String courseId) async {
    await _repository.deleteCourse(courseId);
    if (_selectedCourse?.id == courseId) unselectCourse();
  }
  Future<void> addGradeToCurrentCourse(String title, String type, int score) async {
    if (_selectedCourse == null) return;
    await _repository.addGrade(_selectedCourse!.id, Grade(id: '', title: title, type: type, score: score));
  }
  Future<void> updateGrade(String gradeId, String title, String type, int score) async {
    if (_selectedCourse == null) return;
    await _repository.updateGrade(_selectedCourse!.id, Grade(id: gradeId, title: title, type: type, score: score));
  }
  Future<void> deleteGrade(String gradeId) async {
     if (_selectedCourse == null) return;
     await _repository.deleteGrade(_selectedCourse!.id, gradeId);
  }
  Future<void> addNoteToCurrentCourse(String title, String content) async {
    if (_selectedCourse == null) return;
    await _repository.addNote(_selectedCourse!.id, Note(id: '', title: title, content: content, courseId: _selectedCourse!.id));
  }
  Future<void> addNote(String courseId, String title, String content) async {
    await _repository.addNote(courseId, Note(id: '', title: title, content: content, courseId: courseId));
  }
  Future<void> updateNote(String noteId, String title, String content, String courseId) async {
    if (noteId.isEmpty || courseId.isEmpty) return;
    await _repository.updateNote(courseId, Note(id: noteId, title: title, content: content, courseId: courseId));
  }
  Future<void> deleteNote(String noteId, String courseId) async {
     await _repository.deleteNote(courseId, noteId);
  }
  Future<void> addReminderToCurrentCourse(String title, DateTime deadline) async {
    if (_selectedCourse == null) return;
    final reminder = Reminder(id: '', title: title, deadline: deadline, isDone: false);
    await _repository.addReminder(_selectedCourse!.id, reminder);
  }
  Future<void> toggleReminderStatus(String reminderId, bool currentStatus) async {
    if (_selectedCourse == null) return;
    await _repository.toggleReminderStatus(_selectedCourse!.id, reminderId, currentStatus);
  }
  Future<void> deleteReminder(String reminderId) async {
    if (_selectedCourse == null) return;
    await _repository.deleteReminder(_selectedCourse!.id, reminderId);
  }

  void selectCourse(Course course) {
    _selectedCourse = course;
    _isDetailView = true;
    notifyListeners();
    _subscribeToCourseDetails(course.id);
  }

  void _subscribeToCourseDetails(String courseId) {
    _cancelDetailSubscriptions();
    _gradesSubscription = _repository.getGrades(courseId).listen((data) {
      _currentCourseGrades = data;
      notifyListeners();
    });
    _notesSubscription = _repository.getNotes(courseId).listen((data) {
      _currentCourseNotes = data;
      notifyListeners();
    });
    _remindersSubscription = _repository.getReminders(courseId).listen((data) {
      _currentCourseReminders = data;
      notifyListeners();
    });
  }

  void unselectCourse() {
    _isDetailView = false;
    _selectedCourse = null;
    _cancelDetailSubscriptions();
    notifyListeners();
  }

  void _cancelDetailSubscriptions() {
    _gradesSubscription?.cancel();
    _notesSubscription?.cancel();
    _remindersSubscription?.cancel();
  }

  void onTabTapped(int index) {
    if (_isDetailView) {
      unselectCourse();
      Future.delayed(const Duration(milliseconds: 300), () {
        _currentIndex = index;
        pageController.jumpToPage(index);
        notifyListeners();
      });
    } else {
      _currentIndex = index;
      pageController.jumpToPage(index);
      notifyListeners();
    }
  }
  
  void fetchData({bool simulateError = false}) {
    if (simulateError) {
      // Спочатку показується стан завантаження
      _state = ViewState.loading;
      notifyListeners();

      // Через 1 секунду штучно викликається помилка
      Future.delayed(const Duration(seconds: 1), () {
        _errorMessage = "Не вдалося завантажити дані. Перевірте з'єднання.";
        _state = ViewState.error;
        notifyListeners(); // Оновлюється UI, щоб показати помилку
      });
    } else {
      // Якщо це не симуляція, завантаження даних по-справжньому
      _initData();
    }
  }

  void sortGrades(String? type) {
    if (type != null) {
      _selectedGradeType = type;
      _saveSortPreference(type);
      notifyListeners();
    }
  }

  // Збереження обраного типу сортування 
  Future<void> _saveSortPreference(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('grade_sort_pref', type);
  }

  // Відновлення налаштувань при запуску застосунку
  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedType = prefs.getString('grade_sort_pref');
    if (savedType != null && gradeTypes.contains(savedType)) {
      _selectedGradeType = savedType;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _coursesSubscription?.cancel();
    for (var sub in _allNotesSubscriptions) {
      sub.cancel();
    }
    _cancelDetailSubscriptions();
    super.dispose();
  }
}