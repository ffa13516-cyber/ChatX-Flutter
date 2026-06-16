import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// مسارات الملفات الخاصة بمشروعك
import '../chat/chats_tab.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../utils/app_colors.dart';

class HomeScreenUI extends StatelessWidget {
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

  final List<Widget> _screens = const [
    ChatsTab(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      // أساسي عشان المحتوى ينزل تحت البار العائم ويدي إحساس العمق
      extendBody: true, 
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
      // استخدام Padding لرفع البار عن حافة الشاشة وعمل تأثير الجزيرة
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 32.0, right: 32.0),
        child: _buildFloatingIslandNavBar(),
      ),
    );
  }

  // 1. الهيدر العلوي
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
              color: Colors.black.withOpacity(0.5), 
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
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
                      Icon(Icons.campaign_rounded, color: Colors.white70),
                      SizedBox(width: 12),
                      Text('Create Channel', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'group',
                  child: Row(
                    children: const [
                      Icon(Icons.group_add_rounded, color: Colors.white70),
                      SizedBox(width: 12),
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

  // 2. شريط البحث
  Widget _buildSearchBar() {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 24,
      child: TextField(
        onChanged: onSearch,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.5)),
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // 3. الجزيرة العائمة (The Floating Island)
  Widget _buildFloatingIslandNavBar() {
    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40), // شكل الكبسولة
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // تغبيش عالي لفخامة الإزاز
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06), // شفافية دقيقة جداً
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withOpacity(0.15), // حافة مضيئة تعطي انعكاس الضوء
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // ظل ناعم لفصل الجزيرة عن الخلفية
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // تغيير الأيقونة لتكون Forum لأنها بتدي انطباع Premium أكتر من البابل العادية
                _buildIslandNavItem(Icons.forum_outlined, Icons.forum_rounded, 0),
                _buildIslandNavItem(Icons.person_outline_rounded, Icons.person_rounded, 1),
                _buildIslandNavItem(Icons.settings_outlined, Icons.settings_rounded, 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 4. بناء عنصر النيڤيجيشن بدون نصوص (Minimalist Glow Dot)
  Widget _buildIslandNavItem(IconData icon, IconData activeIcon, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        // تأثير لمسي أقوى قليلاً ليعطي إحساس بالـ Hardware الحقيقي
        HapticFeedback.mediumImpact(); 
        onTabSelected(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min, // عشان مياخدش مساحة بالطول أكتر من حجمه
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  child: child,
                );
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4),
                size: 28, // حجم أيقونة أكبر نسبياً لتعويض غياب النص
              ),
            ),
            const SizedBox(height: 6),
            // النقطة المضيئة (Glow Indicator)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 5,
              width: isSelected ? 5 : 0, // تختفي وتظهر بنعومة
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// ويدجت الـ Glassmorphic المخصصة (بدون تعديلات كبيرة لأنها ممتازة)
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
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
        color: Colors.white.withOpacity(0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
