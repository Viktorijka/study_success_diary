import 'package:flutter/material.dart';
import '../data/auth_repository.dart'; 
import '../../../app/router/app_router.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;

  // Метод для входу за допомогою Email/Пароля
  Future<void> _signInWithEmailAndPassword() async {
    // Перевірка, чи всі поля форми валідні
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Показ індикатора завантаження
      });
      try {
        await _authRepository.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Перевірка, чи віджет все ще існує, перш ніж робити навігацію
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
      } catch (e) {
        // Показ помилки, якщо вхід не вдався
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка входу: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // У будь-якому випадку приховується індикатор завантаження
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Метод для входу за допомогою Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authRepository.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка входу через Google: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Очищення контролерів, щоб уникнути витоків пам'яті
  @override
  void dispose() {
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
            // Огортання все у Form і прив'язка до _formKey
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 35.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Вхід', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.primary)),
                      const SizedBox(height: 30),
                      // Додавання контролерів та валідаторів до полів вводу
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
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      // Якщо йде завантаження, показується індикатор, інакше - кнопка
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Увійти',
                            onPressed: _signInWithEmailAndPassword,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text('або'),
                        const SizedBox(height: 15),
                        // Кнопка для входу через Google
                        OutlinedButton.icon(
                          icon: Image.asset('assets/images/google_logo.png', height: 22.0),
                          label: const Text('Увійти через Google'),
                          onPressed: _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(onPressed: () => Navigator.pushNamed(context, AppRouter.registerRoute), child: const Text('Реєстрація')),
                          const Text('|'),
                          TextButton(onPressed: () {}, child: const Text('Забули пароль?')),
                        ],
                      )
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