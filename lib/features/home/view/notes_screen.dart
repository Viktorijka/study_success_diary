import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/home_viewmodel.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/course_model.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _searchQuery = '';

  void _showNoteDialog(BuildContext context, Note noteToEdit, HomeViewModel viewModel) {
    final titleController = TextEditingController(text: noteToEdit.title);
    final contentController = TextEditingController(text: noteToEdit.content);

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
                  const Text('Редагувати нотатку', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF156254))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Заголовок', style: TextStyle(fontWeight: FontWeight.bold))),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 15),
              const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('Вміст', style: TextStyle(fontWeight: FontWeight.bold))),
              TextField(
                controller: contentController, maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Скасувати'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        viewModel.updateNote(
                          noteToEdit.id, 
                          titleController.text, 
                          contentController.text, 
                          noteToEdit.courseId
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A085), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Зберегти'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final allNotes = viewModel.allNotes;

    final filteredNotes = allNotes.where((note) {
      final query = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(query) || 
             note.content.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Всі Нотатки', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2D3735))),
          const SizedBox(height: 20),
          
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Введіть заголовок або вміст...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          Expanded(
            child: filteredNotes.isEmpty 
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty ? "Нотаток поки немає" : "Нічого не знайдено",
                    style: const TextStyle(color: Colors.grey),
                  )
                ) 
              : ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                
                final course = viewModel.courses.firstWhere(
                  (c) => c.id == note.courseId, 
                  orElse: () => Course(id: '', title: 'Невідомий курс', lecturer: '', description: '', userId: '')
                );
                final courseName = course.title.isNotEmpty ? course.title : 'Без назви';

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                note.title, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20), 
                                  onPressed: () => _showNoteDialog(context, note, viewModel)
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20), 
                                  onPressed: () => viewModel.deleteNote(note.id, note.courseId)
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const Divider(height: 30),
                        Text('Курс: $courseName', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}