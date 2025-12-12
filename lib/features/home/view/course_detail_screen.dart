import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../../../app/theme/app_theme.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/grade_model.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/reminder_model.dart'; 
import '../viewmodel/home_viewmodel.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});
  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- ДІАЛОГ РЕДАГУВАННЯ КУРСУ (ОПИСУ) ---
  void _showEditCourseDialog(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    // Беремо актуальні дані курсу (бо вони могли змінитись)
    final currentCourse = viewModel.courses.firstWhere((c) => c.id == widget.course.id, orElse: () => widget.course);

    final titleController = TextEditingController(text: currentCourse.title);
    final lecturerController = TextEditingController(text: currentCourse.lecturer);
    final descController = TextEditingController(text: currentCourse.description);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Редагувати курс', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF156254))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Назва курсу'),
              _buildTextField(titleController),
              const SizedBox(height: 15),
              _buildLabel('Викладач'),
              _buildTextField(lecturerController),
              const SizedBox(height: 15),
              _buildLabel('Опис'),
              _buildTextField(descController, maxLines: 4),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Скасувати'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        viewModel.updateCourse(
                          currentCourse.id, 
                          titleController.text, 
                          lecturerController.text, 
                          descController.text
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A085),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Зберегти'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ДІАЛОГ НАГАДУВАННЯ ---
  void _showReminderDialog(BuildContext context, {Reminder? reminderToEdit}) {
    final titleController = TextEditingController(text: reminderToEdit?.title ?? '');
    DateTime selectedDate = reminderToEdit?.deadline ?? DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(reminderToEdit == null ? 'Додати нагадування' : 'Редагувати нагадування', 
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF156254))),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Текст нагадування'),
                  _buildTextField(titleController),
                  const SizedBox(height: 15),
                  _buildLabel('Дата та час'),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Скасувати'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            final viewModel = Provider.of<HomeViewModel>(context, listen: false);
                            if (reminderToEdit == null) {
                              viewModel.addReminderToCurrentCourse(titleController.text, selectedDate);
                            } else {
                              // Для нагадувань у нас немає окремого методу update, тому видаляємо старе і створюємо нове (спрощено)
                              // Або треба додати updateReminder в репозиторій. 
                              // Для лабораторної часто достатньо delete+add або просто ігнорувати редагування.
                              // Але давай зробимо:
                              viewModel.deleteReminder(reminderToEdit.id);
                              viewModel.addReminderToCurrentCourse(titleController.text, selectedDate);
                            }
                            Navigator.pop(ctx);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A085),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Зберегти'),
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  // --- ДІАЛОГ ОЦІНКИ ---
  void _showGradeDialog(BuildContext context, {Grade? gradeToEdit}) {
    final titleController = TextEditingController(text: gradeToEdit?.title ?? '');
    final scoreController = TextEditingController(text: gradeToEdit?.score.toString() ?? '');
    // Тип оцінки
    String selectedType = gradeToEdit?.type ?? 'Лабораторна'; 
    // ДОДАНО КОНТРОЛЬНУ
    final types = ['Лабораторна', 'Практична', 'Контрольна', 'Екзамен', 'Інше'];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: StatefulBuilder( 
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(gradeToEdit == null ? 'Додати оцінку' : 'Редагувати оцінку', 
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF156254))),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Назва роботи'),
                  _buildTextField(titleController),
                  const SizedBox(height: 15),
                  _buildLabel('Тип роботи'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: types.contains(selectedType) ? selectedType : types.first,
                        isExpanded: true,
                        items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) => setState(() => selectedType = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildLabel('Бали'),
                  _buildTextField(scoreController, isNumber: true),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Скасувати'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty && scoreController.text.isNotEmpty) {
                            final score = int.tryParse(scoreController.text) ?? 0;
                            final viewModel = Provider.of<HomeViewModel>(context, listen: false);
                            
                            if (gradeToEdit == null) {
                              viewModel.addGradeToCurrentCourse(titleController.text, selectedType, score);
                            } else {
                              viewModel.updateGrade(gradeToEdit.id, titleController.text, selectedType, score);
                            }
                            Navigator.pop(ctx);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A085),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Зберегти'),
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  // --- ДІАЛОГ НОТАТКИ ---
  void _showNoteDialog(BuildContext context, {Note? noteToEdit}) {
    final titleController = TextEditingController(text: noteToEdit?.title ?? '');
    final contentController = TextEditingController(text: noteToEdit?.content ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(noteToEdit == null ? 'Нова нотатка' : 'Редагувати нотатку', 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF156254))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              _buildLabel('Заголовок'),
              _buildTextField(titleController),
              const SizedBox(height: 15),
              _buildLabel('Вміст'),
              _buildTextField(contentController, maxLines: 4),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Скасувати'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        final viewModel = Provider.of<HomeViewModel>(context, listen: false);
                        if (noteToEdit == null) {
                           viewModel.addNoteToCurrentCourse(titleController.text, contentController.text);
                        } else {
                           viewModel.updateNote(noteToEdit.id, titleController.text, contentController.text, noteToEdit.courseId);
                        }
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A085),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Зберегти'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3735))),
    );
  }
  Widget _buildTextField(TextEditingController controller, {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Використовуємо Consumer, щоб екран оновлювався при зміні курсу
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        // Отримуємо актуальну версію курсу зі списку (якщо його відредагували)
        final displayCourse = viewModel.courses.firstWhere(
          (c) => c.id == widget.course.id, 
          orElse: () => widget.course // Про всяк випадок
        );

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton( icon: const Icon(Icons.arrow_back), onPressed: viewModel.unselectCourse ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        displayCourse.title, 
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold), 
                        overflow: TextOverflow.ellipsis
                      )
                    ),
                    // ДОДАНО КНОПКУ РЕДАГУВАННЯ КУРСУ
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.accentGreen),
                      tooltip: "Редагувати курс",
                      onPressed: () => _showEditCourseDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [ Tab(text: 'Опис'), Tab(text: 'Оцінки'), Tab(text: 'Нотатки'), Tab(text: 'Нагадування') ],
                    labelColor: Theme.of(context).colorScheme.secondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).colorScheme.secondary,
                    indicatorWeight: 3.0,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDescriptionTab(displayCourse.description),
                      _buildGradesTab(context),
                      _buildNotesTab(context),
                      _buildRemindersTab(context),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildDescriptionTab(String description) {
    return _buildLeftAccentCard(child: Padding(padding: const EdgeInsets.all(20.0), child: Text(description.isEmpty ? "Опис відсутній" : description)));
  }

  Widget _buildGradesTab(BuildContext context) {
     final viewModel = Provider.of<HomeViewModel>(context);
     final grades = viewModel.grades;
     
     return Column(
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween, // Розподіляємо елементи по краях
           children: [
             // Фільтр
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey.shade300),
               ),
               child: DropdownButtonHideUnderline(
                 child: DropdownButton<String>(
                   value: viewModel.selectedGradeType, // Значення беремо з ViewModel
                   icon: const Icon(Icons.filter_list, color: AppTheme.accentGreen),
                   underline: null,
                   items: viewModel.gradeTypes.map((String type) {
                     return DropdownMenuItem<String>(
                       value: type,
                       child: Text(type, style: const TextStyle(fontSize: 14)),
                     );
                   }).toList(),
                   onChanged: (String? newValue) {
                     // Викликаємо метод сортування
                     viewModel.sortGrades(newValue);
                   },
                 ),
               ),
             ),
             
             // Кнопка додавання
             _buildAddButton('Додати оцінку', () => _showGradeDialog(context)),
           ],
         ),
         const SizedBox(height: 20),
         Expanded(
           child: grades.isEmpty
            ? const Center(child: Text("Оцінок ще немає"))
            : ListView.builder(
             itemCount: grades.length,
             itemBuilder: (context, index) {
               final grade = grades[index];
               return _buildLeftAccentCard(
                 child: ListTile(
                   title: Text(grade.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: Text('Тип: ${grade.type}'),
                   trailing: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Text('${grade.score} балів', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDarkGreen)),
                       const SizedBox(width: 8),
                       IconButton(
                         icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                         constraints: const BoxConstraints(), 
                         padding: const EdgeInsets.all(8),
                         onPressed: () => _showGradeDialog(context, gradeToEdit: grade),
                       ),
                       IconButton(
                         icon: const Icon(Icons.delete, size: 20, color: Colors.grey),
                         constraints: const BoxConstraints(), 
                         padding: const EdgeInsets.all(8),
                         onPressed: () => viewModel.deleteGrade(grade.id),
                       ),
                     ],
                   ),
                 ),
               );
             },
           ),
         )
       ],
     );
  }
  
  Widget _buildNotesTab(BuildContext context) {
      final viewModel = Provider.of<HomeViewModel>(context);
      final notes = viewModel.currentNotes;

      return Column(
        children: [
          Row(children: [const Spacer(), _buildAddButton('Додати нотатку', () => _showNoteDialog(context))]),
          const SizedBox(height: 20),
          Expanded(
            child: notes.isEmpty
            ? const Center(child: Text("Нотаток до цього курсу немає"))
            : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _buildLeftAccentCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                             Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey), 
                                  constraints: const BoxConstraints(), 
                                  padding: const EdgeInsets.all(8),
                                  onPressed: () => _showNoteDialog(context, noteToEdit: note)
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 18, color: Colors.grey), 
                                  constraints: const BoxConstraints(), 
                                  padding: const EdgeInsets.all(8),
                                  onPressed: () => viewModel.deleteNote(note.id, note.courseId)
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(note.content),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
  }

  Widget _buildRemindersTab(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final reminders = viewModel.reminders;

    return Column(
      children: [
        Row(children: [const Spacer(), _buildAddButton('Додати нагадування', () => _showReminderDialog(context))]),
        const SizedBox(height: 20),
        Expanded(
          child: reminders.isEmpty
              ? _buildLeftAccentCard(child: const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Нагадувань для цього курсу немає.'))))
              : ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    final dateText = reminder.deadline != null 
                        ? DateFormat('dd.MM.yyyy').format(reminder.deadline!)
                        : "";
                        
                    return _buildLeftAccentCard(
                      child: CheckboxListTile(
                        value: reminder.isDone,
                        onChanged: (val) {
                          viewModel.toggleReminderStatus(reminder.id, reminder.isDone);
                        },
                        title: Text(
                          reminder.title,
                          style: TextStyle(
                            decoration: reminder.isDone ? TextDecoration.lineThrough : null,
                            color: reminder.isDone ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: Text(dateText),
                        secondary: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => viewModel.deleteReminder(reminder.id),
                        ),
                        activeColor: AppTheme.accentGreen,
                        controlAffinity: ListTileControlAffinity.leading, // Чекбокс зліва
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLeftAccentCard({required Widget child}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppTheme.accentGreen, width: 4)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildAddButton(String text, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}