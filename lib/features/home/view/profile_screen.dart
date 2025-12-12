import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../app/router/app_router.dart';
import 'package:study_success_diary/features/auth/data/auth_repository.dart';
import '../viewmodel/home_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, HomeViewModel viewModel) {
    final nameController = TextEditingController(text: viewModel.user.name);
    final specialtyController = TextEditingController(text: viewModel.user.specialty);
    final universityController = TextEditingController(text: viewModel.user.university); // <--- НОВИЙ КОНТРОЛЕР

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Редагувати профіль', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF156254))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              
              const Text("Повне ім'я", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 15),

              const Text("Спеціальність", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: specialtyController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 15),

              // --- НОВЕ ПОЛЕ В ДІАЛОЗІ ---
              const Text("Університет", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: universityController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              // ---------------------------

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
                      // Передаємо 3 параметри
                      viewModel.updateUserProfile(
                        nameController.text.trim(), 
                        specialtyController.text.trim(),
                        universityController.text.trim(),
                      );
                      Navigator.pop(ctx);
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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final user = viewModel.user;
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Профіль', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: viewModel.isUploading ? null : () => viewModel.updateProfileImage(),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: user.avatarUrl != null 
                                  ? NetworkImage(user.avatarUrl!) 
                                  : const AssetImage('assets/images/avatar.jpg') as ImageProvider,
                              child: viewModel.isUploading 
                                  ? const CircularProgressIndicator() 
                                  : null,
                            ),
                            if (!viewModel.isUploading)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF16A085),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            Text(user.specialty, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(178))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20), 

                      OutlinedButton.icon(
                        icon: Icon(Icons.logout, color: Colors.red.shade400),
                        label: Text('Вийти', style: TextStyle(color: Colors.red.shade400)),
                        onPressed: () async {
                          await AuthRepository().signOut();
                          if (context.mounted) {
                             Navigator.pushNamedAndRemoveUntil(context, AppRouter.loginRoute, (route) => false);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade300),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                           shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  _buildProfileTextField("Повне ім'я", user.name, theme),
                  _buildProfileTextField("Спеціальність", user.specialty, theme),
                  // --- ТУТ ТЕПЕР ВІДОБРАЖАЄТЬСЯ РЕАЛЬНИЙ УНІВЕРСИТЕТ ---
                  _buildProfileTextField("Університет", user.university.isEmpty ? "Не вказано" : user.university, theme),
                  
                  const SizedBox(height: 20),
                  
                  OutlinedButton(
                    onPressed: () => _showEditProfileDialog(context, viewModel),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      foregroundColor: theme.colorScheme.onSurface.withAlpha(178),
                      side: BorderSide(color: theme.colorScheme.onSurface.withAlpha(76)),
                    ),
                    child: const Text('Редагувати профіль'),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        throw Exception('Це моя тестова некритична помилка для Sentry!');
                      } catch (e, stackTrace) {
                        await Sentry.captureException(e, stackTrace: stackTrace);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Некритичну помилку надіслано в Sentry!')),
                          );
                        }
                      }
                    },
                    child: const Text('Надіслати НЕКРИТИЧНУ помилку'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      throw Exception('Це моя тестова КРИТИЧНА помилка для Sentry!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Надіслати КРИТИЧНУ помилку'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileTextField(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: theme.brightness == Brightness.dark ? Colors.white.withAlpha(12) : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}