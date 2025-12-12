import 'package:flutter/material.dart';
import '../data/auth_repository.dart'; 
import '../../../app/router/app_router.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Додавання ключів, контролерів та стану завантаження
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;

  // Метод для реєстрації через Email/Пароль
  Future<void> _registerWithEmailAndPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _authRepository.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRouter.homeRoute, (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка реєстрації: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Метод для реєстрації/входу через Google
  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authRepository.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRouter.homeRoute, (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка входу через Google: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Очищення контролерів
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            // Огортання в Form
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 35.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Реєстрація', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.primary)),
                      const SizedBox(height: 30),
                      // Додавання контролерів та валідаторів
                      CustomTextField(
                        controller: _nameController,
                        labelText: "Повне ім'я",
                        validator: (value) => (value?.isEmpty ?? true) ? "Будь ласка, введіть ім'я" : null,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Електронна пошта',
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Будь ласка, введіть пошту';
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Введіть дійсну адресу пошти';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Пароль',
                        isPassword: true,
                        validator: (value) {
                           if (value == null || value.isEmpty) return 'Будь ласка, введіть пароль';
                           if (value.length < 6) return 'Пароль має бути не менше 6 символів';
                           return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Зареєструватися',
                            onPressed: _registerWithEmailAndPassword,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text('або'),
                        const SizedBox(height: 15),
                        OutlinedButton.icon(
                          icon: Image.asset('assets/images/google_logo.png', height: 22.0),
                          label: const Text('Зареєструватися через Google'),
                          onPressed: _registerWithGoogle,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Вже є акаунт? Увійти'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}