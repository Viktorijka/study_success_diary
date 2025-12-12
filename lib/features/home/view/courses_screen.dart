import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/home_viewmodel.dart';
import '../../../data/models/course_model.dart';
import '../../../app/theme/app_theme.dart'; 

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  // --- ДІАЛОГ РЕДАГУВАННЯ КУРСУ ---
  void _showEditCourseDialog(BuildContext context, Course course, HomeViewModel viewModel) {
    final titleController = TextEditingController(text: course.title);
    final lecturerController = TextEditingController(text: course.lecturer);
    final descController = TextEditingController(text: course.description);

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
                        viewModel.updateCourse(course.id, titleController.text, lecturerController.text, descController.text);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Мої Курси', 
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    Row(
                      children: [
                         IconButton(
                          icon: const Icon(Icons.error_outline, color: Colors.red),
                          tooltip: "Симулювати помилку",
                          onPressed: () => viewModel.fetchData(simulateError: true),
                        ),
                        IconButton(
                           icon: const Icon(Icons.refresh, color: AppTheme.accentGreen),
                           tooltip: "Оновити дані",
                           onPressed: () => viewModel.fetchData(simulateError: false),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildBody(context, viewModel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
    switch (viewModel.state) {
      case ViewState.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGreen)
        );
      
      case ViewState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 60),
              const SizedBox(height: 10),
              Text(
                viewModel.errorMessage, 
                style: const TextStyle(fontSize: 16), 
                textAlign: TextAlign.center
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => viewModel.fetchData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Спробувати ще раз'),
              ),
            ],
          ),
        );

      case ViewState.success:
      case ViewState.initial:
        if (viewModel.courses.isEmpty) {
           return const Center(child: Text("Курсів поки немає"));
        }
        return ListView.builder(
          itemCount: viewModel.courses.length,
          itemBuilder: (context, index) {
            final course = viewModel.courses[index];
            return _buildCourseCard(
              context: context,
              course: course,
              viewModel: viewModel, // Передаємо VM для доступу до методів
            );
          },
        );
    }
  }

  // Кастомна картка курсу
  Widget _buildCourseCard({
    required BuildContext context,
    required Course course,
    required HomeViewModel viewModel,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () => viewModel.selectCourse(course),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppTheme.accentGreen, width: 6)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 5),
                      Text('Викладач: ${course.lecturer}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                // --- КНОПКА РЕДАГУВАННЯ ---
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.grey[600], size: 22), 
                  onPressed: () => _showEditCourseDialog(context, course, viewModel),
                ),
                // --- КНОПКА ВИДАЛЕННЯ ---
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.grey[600], size: 22), 
                  onPressed: () => viewModel.deleteCourse(course.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}