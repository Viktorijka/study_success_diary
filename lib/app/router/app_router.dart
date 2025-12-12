import 'package:flutter/material.dart';
import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/register_screen.dart';
import '../../features/home/view/home_screen.dart'; 

class AppRouter {
  static const String loginRoute = '/';
  static const String homeRoute = '/home';
  static const String registerRoute = '/register'; 

  static Map<String, WidgetBuilder> get routes {
    return {
      loginRoute: (context) => const LoginScreen(),
      homeRoute: (context) => const HomeScreen(),
      registerRoute: (context) => const RegisterScreen(), 
    };
  }
}