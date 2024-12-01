import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pamp_final_project/firebase_options.dart';
import 'package:pamp_final_project/screens/register_page.dart';
import 'package:pamp_final_project/screens/splash_page.dart';
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';
import './providers/todo_provider.dart';
import './screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TodoProvider>(
          create: (context) => TodoProvider(context.read<AuthProvider>()),
          update: (_, authProvider, todoProvider) => TodoProvider(authProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Activity Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashPage(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
        },
      ),
    );
  }
}
