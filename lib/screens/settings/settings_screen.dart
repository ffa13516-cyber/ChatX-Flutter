import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/session_manager.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.bgDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('NOTIFICATIONS'),
          _settingsCard([
            _switchTile('Enable Notifications', Icons.notifications_rounded, true, (_) {}),
            _switchTile('Message Preview', Icons.message_rounded, true, (_) {}),
          ]),

          const SizedBox(height: 16),
          _sectionTitle('PRIVACY'),
          _settingsCard([
            _navTile(context, 'Last Seen', Icons.access_time_rounded),
            _navTile(context, 'Profile Photo', Icons.photo_rounded),
          ]),

          const SizedBox(height: 16),
          _sectionTitle('ACCOUNT'),
          _settingsCard([
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              onTap: () async {
                await SessionManager.instance.clear();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              },
            ),
          ]),

          const SizedBox(height: 16),
          _sectionTitle('ABOUT'),
          _settingsCard([
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('X', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              title: const Text('ChatX', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: const Text('Version 1.0.0', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile(String title, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _navTile(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: () {},
    );
  }
}
