import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgDark,
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  runApp(ChatXApp(isLoggedIn: isLoggedIn));
}

class ChatXApp extends StatelessWidget {
  final bool isLoggedIn;
  const ChatXApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          background: AppColors.bgDark,
          surface: AppColors.bgSurface,
        ),
        scaffoldBackgroundColor: AppColors.bgDark,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
