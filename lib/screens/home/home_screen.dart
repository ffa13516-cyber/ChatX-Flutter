import 'package:flutter/material.dart';
import '../chat/chats_tab.dart';
import '../group/groups_tab.dart';
import '../channel/channels_tab.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChatsTab(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = ['ChatX', 'Profile', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: NavigationBar(
            backgroundColor: AppColors.bgSurface,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            indicatorColor: AppColors.primary.withOpacity(0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
                label: 'Chats',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                label: 'Profile',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primary),
                label: 'Settings',
              ),
            ],
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}
