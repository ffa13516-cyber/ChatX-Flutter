import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_colors.dart';
import 'screens/chat/neon_chat_screen.dart';

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

  runApp(const ChatXApp());
}

class ChatXApp extends StatelessWidget {
  const ChatXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0F14),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const ChatScreen(),
    );
  }
}
