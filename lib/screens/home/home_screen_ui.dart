import 'dart:ui';
import 'package:flutter/material.dart';

// مسارات الملفات بتاعتك زي ما هي
import '../chat/chats_tab.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../utils/app_colors.dart';

class HomeScreenUI extends StatelessWidget {
  // المتغيرات دي هتيجي من ملف اللوجيك
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCreateChannel;
  final VoidCallback onCreateGroup;
  final ValueChanged<String> onSearch;

  const HomeScreenUI({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onCreateChannel,
    required this.onCreateGroup,
    required this.onSearch,
  });

  // الشاشات اللي هنعرضها
  final List<Widget> _screens = const [
    ChatsTab(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      extendBody: true, // عشان الشات ينزل ورا النيڤيجيشن بار الشفاف
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  // 1. الهيدر (chatx + القائمة الزجاجية)
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'chatx',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: Colors.white.withOpacity(0.15), // لون زجاجي للقائمة
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              onSelected: (value) {
                if (value == 'channel') onCreateChannel();
                if (value == 'group') onCreateGroup();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'channel',
                  child: Row(
                    children: const [
                      Icon(Icons.campaign_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Create Channel', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'group',
                  child: Row(
                    children: const [
                      Icon(Icons.group_add_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Create Group', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. شريط البحث الزجاجي
  Widget _buildSearchBar() {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 24,
      child: TextField(
        onChanged: onSearch,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.7)),
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // 4. الـ Bottom Navigation Bar العائم والزجاجي
  Widget _buildFloatingNavBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 40, right: 40),
        child: GlassContainer(
          borderRadius: 30,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 0),
              _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 1),
              _buildNavItem(Icons.settings_outlined, Icons.settings_rounded, 2),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت مساعدة لزراير النيڤيجيشن
  Widget _buildNavItem(IconData icon, IconData activeIcon, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.6),
          size: 26,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// ويدجت الـ Glassmorphism (تأثير الزجاج) قابلة لإعادة الاستخدام
// -------------------------------------------------------------------
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        color: Colors.white.withOpacity(0.05), // شفافية خفيفة عشان تأثير الإزاز
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // درجة نعومة الزجاج
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
