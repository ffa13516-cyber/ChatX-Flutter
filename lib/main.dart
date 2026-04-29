import 'package:flutter/material.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// 🔥 خليناه false عشان يفتح الهوم
  static const bool openChatDirectly = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData.dark(),
      home: openChatDirectly
          // 🆕 التعديل هنا: تمرير البيانات الإجبارية لحل إيرور "Required named parameter"
          ? const ChatScreen(chatId: "test_chat", myUid: "my_uid_123")
          : const HomeScreen(),
    );
  }
}
