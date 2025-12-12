import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart'; 
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'features/home/viewmodel/home_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Ініціалізація Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Ініціалізація Supabase 
  await Supabase.initialize(
    url: 'https://rryqgpmjplrdrefonmxh.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJyeXFncG1qcGxyZHJlZm9ubXhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ5MzIyNDUsImV4cCI6MjA4MDUwODI0NX0.1px0e52eZiV0pY7evUjDqFQnzwyXyW0I4k-C5gB1-6g',
  );

  // 3. Ініціалізація Sentry
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://b94d76c3560688c211412dd63d36508c@o4510360725880832.ingest.de.sentry.io/4510360728371280';
      options.tracesSampleRate = 1.0; 
    },
    appRunner: () {
      debugPaintSizeEnabled = false; 
      runApp(
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(),
          child: const MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Success Diary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.loginRoute,
      routes: AppRouter.routes,
    );
  }
}