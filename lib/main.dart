import 'package:english_mentor_ai2/injector.dart';
import 'package:flutter/material.dart';

import 'presentation/pages/chat_list_screen.dart';

void main() {
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
      home:  ChatListScreen(), // جعل ChatListScreen الشاشة الرئيسية
    );
  }
}