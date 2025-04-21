import 'package:english_mentor_ai2/injector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'presentation/pages/chat_list_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(
    'ar',
    null,
  ); // استخدم اللغة التي تعرض بها التواريخ
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Mentor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ChatListScreen(), // جعل ChatListScreen الشاشة الرئيسية
    );
  }
}
