import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // مستدعى خصيصاً للتفاعل اللمسي الفخم (Haptics)

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

  // الشاشات المعروضة داخل التطبيق
  final List<Widget> _screens = const [
    ChatsTab(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      extendBody: true, // حجر الأساس لجعل المحتوى يتدفق خلف البار الزجاجي بسلاسة
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
      bottomNavigationBar: _buildFullWidthGlassNavBar(),
    );
  }

  // 1. الهيدر العلوي (chatx + القائمة المنسدلة بتأثير زجاجي)
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
              color: Colors.black.withOpacity(0.4), // تأثير داكن زجاجي متناسق مع الخلفية
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.15)),
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

  // 2. شريط البحث العائم والزجاجي
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

  // 3. الـ Navigation Bar السفلي الممتد بعرض الشاشة بالكامل (Ultra-Glassmorphic)
  Widget _buildFullWidthGlassNavBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25), // زيادة التغبيش لمنح مظهر سائل وناعم
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02), // درجة شفافة جداً ومدروسة لمنع بهتان الألوان خلفها
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.12), // خط علوي فائق النعومة ليعطي لمعة قطع الزجاج الحقيقية
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            top: false, // الحفاظ على أبعاد الهواتف التي تحتوي على نتوء سفلي (Gesture Bar)
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 0, 'Chats'),
                  _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 1, 'Profile'),
                  _buildNavItem(Icons.settings_outlined, Icons.settings_rounded, 2, 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 4. بناء عناصر النيڤيجيشن الفردية مع المايكرو-أنيميشن والتأثير اللمسي
  Widget _buildNavItem(IconData icon, IconData activeIcon, int index, String label) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        // تأثير اهتزاز فيزيائي خفيف وذكي عند الضغط لرفع تقييم تجربة المستخدم
        HapticFeedback.lightImpact(); 
        onTabSelected(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.transformCurves([Curves.easeOutCubic]), // حركة انسيابية سريعة في النهاية ومريحة للعين
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أنيميشن تبديل الأيقونات مع تكبير وتصغير (Scale Drop) احترافي
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  child: child,
                );
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.5),
                size: 24,
              ),
            ),
            // تمدد ذكي جداً لظهور النص وانبثاقه بدون حدوث قفزة فجائية في الواجهة
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// ويدجت الـ Glassmorphic المخصصة للعناصر العائمة (كشريط البحث)
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
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.2),
        color: Colors.white.withOpacity(0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
