import 'package:flutter/material.dart';
import 'package:your_app_name/screens/chat_screen.dart'; // 👈 عدل الاسم هنا

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(), // 👈 بيفتح شاشة الشات
    );
  }
}
