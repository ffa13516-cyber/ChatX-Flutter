import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../utils/session_manager.dart';
import '../../widgets/widgets.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 7) {
      _showSnack('Enter a valid phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check existing user
      UserModel? user = await FirebaseRepo.getUserByPhone(phone);

      if (user == null) {
        // Create new user
        final uid = DateTime.now().millisecondsSinceEpoch.toString();
        final name = 'User ${phone.substring(phone.length - 4)}';
        user = UserModel(
          uid: uid,
          phoneNumber: phone,
          displayName: name,
          lastSeen: DateTime.now().millisecondsSinceEpoch,
          isOnline: true,
        );
        await FirebaseRepo.saveUser(user);
      }

      await SessionManager.instance.saveSession(
        uid: user.uid,
        phone: user.phoneNumber,
        name: user.displayName,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showSnack('Login failed. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),

                // Logo
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'X',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(),

                const SizedBox(height: 32),

                const Center(
                  child: Text(
                    'Welcome to ChatX 👋',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Enter your phone number to continue',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const Spacer(),

                CustomTextField(
                  hint: 'Phone number (e.g. +1234567890)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_rounded,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                const SizedBox(height: 20),

                GradientButton(
                  text: 'Continue',
                  onPressed: _login,
                  isLoading: _isLoading,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
