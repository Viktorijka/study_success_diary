import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/home_viewmodel.dart';
import 'dashboard_screen.dart'; 
import 'courses_screen.dart';
import 'notes_screen.dart';
import 'profile_screen.dart';
import 'course_detail_screen.dart';
import 'faq_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFabExpanded = false;

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }

  void _closeFab() {
    if (_isFabExpanded) {
      setState(() {
        _isFabExpanded = false;
      });
    }
  }

  // --- ДІАЛОГИ ---
  
  // 1. Курс
  void _showAddCourseDialog(BuildContext context) {
    _closeFab();
    final titleController = TextEditingController();
    final lecturerController = TextEditingController();
    final descController = TextEditingController();
    
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
                  const Text('Додати новий курс', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF156254))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
               const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Назва курсу', style: TextStyle(fontWeight: FontWeight.bold))),
               TextField(controller: titleController, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
               const SizedBox(height: 15),
               const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Викладач', style: TextStyle(fontWeight: FontWeight.bold))),
               TextField(controller: lecturerController, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
               const SizedBox(height: 15),
               const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Опис', style: TextStyle(fontWeight: FontWeight.bold))),
               TextField(controller: descController, maxLines: 3, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
               const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Скасувати'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        Provider.of<HomeViewModel>(context, listen: false)
                            .addNewCourse(titleController.text, lecturerController.text, descController.text);
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A085),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  // 2. Нотатка (Універсальна)
  void _showAddNoteDialog(BuildContext context) {
    _closeFab();
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);

    // 1. Перевірка: якщо курсів взагалі немає, ми не можемо створити нотатку
    if (viewModel.courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Спочатку створіть хоча б один курс!")),
      );
      return;
    }

    // 2. Логіка визначення курсу за замовчуванням
    String? selectedCourseId;
    if (viewModel.isDetailView && viewModel.selectedCourse != null) {
      selectedCourseId = viewModel.selectedCourse!.id;
    } else {
      selectedCourseId = viewModel.courses.first.id;
    }

    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // Потрібен для оновлення Dropdown всередині діалогу
        builder: (context, setState) {
          return Dialog(
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
                      const Text('Створити нотатку', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF156254))),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // --- ВИБІР КУРСУ (Показуємо тільки якщо ми НЕ в деталях курсу) ---
                  if (!viewModel.isDetailView) ...[
                    const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Оберіть курс', style: TextStyle(fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCourseId,
                          isExpanded: true,
                          items: viewModel.courses.map((course) {
                            return DropdownMenuItem(
                              value: course.id,
                              child: Text(course.title, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedCourseId = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Заголовок', style: TextStyle(fontWeight: FontWeight.bold))),
                  TextField(controller: titleController, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
                  const SizedBox(height: 15),
                  const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Вміст', style: TextStyle(fontWeight: FontWeight.bold))),
                  TextField(controller: contentController, maxLines: 4, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Скасувати'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty && selectedCourseId != null) {
                            viewModel.addNote(selectedCourseId!, titleController.text, contentController.text);
                            Navigator.pop(ctx);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A085),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Зберегти'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  // 3. Нагадування
  void _tryAddReminder(BuildContext context) {
    _closeFab();
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    if (viewModel.isDetailView && viewModel.selectedCourse != null) {
        _showGlobalReminderDialog(context);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Відкрийте курс, щоб додати нагадування")));
    }
  }

  void _showGlobalReminderDialog(BuildContext context) {
      final titleController = TextEditingController();
      DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

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
                       const Text('Додати нагадування', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF156254))),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Текст нагадування', style: TextStyle(fontWeight: FontWeight.bold))),
                  TextField(controller: titleController, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
                  const SizedBox(height: 15),
                  const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Дата та час', style: TextStyle(fontWeight: FontWeight.bold))),
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
                          Text("${selectedDate.day}.${selectedDate.month}.${selectedDate.year} --:--"),
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
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Скасувати'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            Provider.of<HomeViewModel>(context, listen: false)
                                .addReminderToCurrentCourse(titleController.text, selectedDate);
                            Navigator.pop(ctx);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A085),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final theme = Theme.of(context);
    
    // Кнопка показується завжди
    const bool showFab = true; 

    // Адаптація для мобільного пристрою
    return LayoutBuilder(
      builder: (context, constraints) {
        // Якщо ширина менше 800px, вважаємо це мобільним
        final bool isMobile = constraints.maxWidth < 800;


    return Scaffold(

      // Нижнє меню для телефона
      bottomNavigationBar: (isMobile && !viewModel.isDetailView) 
            ? BottomNavigationBar(
                currentIndex: viewModel.currentIndex,
                onTap: (index) => viewModel.onTabTapped(index),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFF156254),
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Успішність'),
                  BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Курси'),
                  BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Нотатки'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профіль'),
                ],
              ) 
            : null,

      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile) 
                  const CustomSidebar(),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: viewModel.isDetailView && viewModel.selectedCourse != null
                      ? CourseDetailScreen(key: ValueKey(viewModel.selectedCourse!.id), course: viewModel.selectedCourse!)
                      : PageView(
                          controller: viewModel.pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            DashboardScreen(),
                            CoursesScreen(),
                            NotesScreen(),
                            ProfileScreen(),
                          ],
                        ),
                ),
              ),
            ],
          ),
          
          if (showFab)
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFabExpanded) ...[
                    // Опції для деталей курсу
                    if (viewModel.isDetailView) ...[
                       _FabOption(
                        icon: Icons.notifications,
                        label: 'Нове нагадування',
                        onTap: () => _tryAddReminder(context),
                      ),
                      const SizedBox(height: 12),
                       _FabOption(
                        icon: Icons.note,
                        label: 'Нова нотатка',
                        onTap: () => _showAddNoteDialog(context),
                      ),
                    ] 
                    // Опції для всіх інших екранів
                    else ...[
                       _FabOption(
                        icon: Icons.note,
                        label: 'Нова нотатка',
                        onTap: () => _showAddNoteDialog(context),
                      ),
                      const SizedBox(height: 12),
                      _FabOption(
                        icon: Icons.book,
                        label: 'Новий курс', 
                        onTap: () => _showAddCourseDialog(context),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                  
                  // Головна кнопка
                  FloatingActionButton(
                    onPressed: _toggleFab,
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: Icon(_isFabExpanded ? Icons.close : Icons.add, size: 32),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    }
    ); 
  }
}


// Віджет для опції меню FAB
class _FabOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FabOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF156254), size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF156254))),
          ],
        ),
      ),
    );
  }
}

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final user = viewModel.user;
    return Container(
      width: 300,
      color: const Color(0xFF156254),
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white, size: 20),
                  onPressed: () => showFaqDialog(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.school, color: Colors.white, size: 36),
                    const SizedBox(width: 10),
                    const Text('Study Success Diary', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              children: [
                // --- ВИПРАВЛЕНА АВАТАРКА ---
                // Тепер вона перевіряє, чи є посилання в user.avatarUrl
                CircleAvatar(
                  radius: 50, 
                  backgroundImage: user.avatarUrl != null 
                    ? NetworkImage(user.avatarUrl!) // Якщо є URL - беремо з інтернету
                    : const AssetImage('assets/images/avatar.jpg') as ImageProvider, // Інакше - стандартна
                ),
                // ---------------------------
                const SizedBox(height: 15),
                Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Студентка', style: TextStyle(color: Colors.white.withAlpha(178), fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _NavListTile( text: 'Успішність', icon: Icons.pie_chart, isActive: viewModel.currentIndex == 0, onTap: () => viewModel.onTabTapped(0) ),
          _NavListTile( text: 'Мої курси', icon: Icons.book, isActive: viewModel.currentIndex == 1, onTap: () => viewModel.onTabTapped(1) ),
          _NavListTile( text: 'Нотатки', icon: Icons.note, isActive: viewModel.currentIndex == 2, onTap: () => viewModel.onTabTapped(2) ),
          _NavListTile( text: 'Профіль', icon: Icons.person, isActive: viewModel.currentIndex == 3, onTap: () => viewModel.onTabTapped(3) ),
          const Spacer(),
          const Center(child: Padding(padding: EdgeInsets.only(bottom: 10.0), child: Text('© 2025 SSD Project', style: TextStyle(color: Colors.white54, fontSize: 12)))),
        ],
      ),
    );
  }
}

class _NavListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavListTile({
    required this.text,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF16A085) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}