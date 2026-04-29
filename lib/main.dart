import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDMbgMfJkuiEc4EmN8S_nOLVIghAZSzQiE",
      appId: "1:560030093300:android:ad0677ea0cd7b0b36433a1",
      messagingSenderId: "560030093300",
      projectId: "messengerapp-d6e7c",
      databaseURL: "https://messengerapp-d6e7c-default-rtdb.firebaseio.com",
      storageBucket: "messengerapp-d6e7c.firebasestorage.app",
    ),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const bool openChatDirectly = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatX',
      theme: ThemeData.dark(),
      home: openChatDirectly
          ? const ChatScreen()
          : const HomeScreen(),
    );
  }
}
