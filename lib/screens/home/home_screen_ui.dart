import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// مسارات الملفات الخاصة بمشروعك (تأكد من صحتها)
import '../chat/chats_tab.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../utils/app_colors.dart'; 
import 'package:chatx/screens/search/search_screen.dart';

// تم تحديث الملف برؤية هندسية احترافية:
// ✅ إزالة لوجيك البحث الداخلي (Inline Search) بالكامل لتخفيف الـ State والأداء.
// ✅ ربط أيقونة البحث لفتح شاشة Full-Screen Search منفصلة ومعزولة تماماً.
// ✅ الحفاظ على الهوية البصرية الفاخرة Dark Luxury Glass والـ Accents البنفسجية.
// ✅ الحفاظ على أبعاد شريط التنقل السفلي النحيف والكبسولة الزجاجية المحسنة.

class HomeScreenUI extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCreateChannel;
  final VoidCallback onCreateGroup;
  final ValueChanged<String> onSearch;

  // بيانات المستخدم الحالي — مطلوبة لتمريرها لـ SearchScreen
  final String myUid;
  final String myName;

  const HomeScreenUI({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onCreateChannel,
    required this.onCreateGroup,
    required this.onSearch,
    required this.myUid,
    required this.myName,
  });

  @override
  State<HomeScreenUI> createState() => _HomeScreenUIState();
}

class _HomeScreenUIState extends State<HomeScreenUI> {
  final List<Widget> _screens = const [
    ChatsTab(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // تحديد ألوان الـ Accents للفخامة (بنفسجي مائل للزرقة)
    final luxuryAccentColor = const Color(0xFF6C63FF).withOpacity(0.8);

    return Scaffold(
      // استخدام خلفية سوداء قوية لزيادة التباين والفخامة
      backgroundColor: const Color(0xFF0A0A0E), // أسود أعمق
      extendBody: true, 
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          floatHeaderSlivers: false, 
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Colors.transparent, 
                pinned: true,   
                floating: false,
                snap: false,
                elevation: 0, 
                toolbarHeight: 75, 
                titleSpacing: 0,
                title: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: LuxuryGlassContainer(
                    borderRadius: 24, 
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                    accentColor: luxuryAccentColor,
                    child: _buildHeaderContent(context, luxuryAccentColor),
                  ),
                ),
              ),
            ];
          },
          body: IndexedStack(
            index: widget.currentIndex,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        // تم تقليل المسافة السفلية (bottom) لإنزال الجزيرة أكثر
        padding: const EdgeInsets.only(bottom: 12.0, left: 32.0, right: 32.0),
        child: _buildFloatingIslandNavBar(luxuryAccentColor),
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context, Color accentColor) {
    final luxuryAccentColor = const Color(0xFF6C63FF).withOpacity(0.8);
    return Container(
      key: const ValueKey('NormalHeader'),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ShaderMask محسن لإعطاء النص تأثير معدني فاخر بلمسة بنفسجية
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [luxuryAccentColor, Colors.white, Colors.white.withOpacity(0.8)],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'chatx',
              style: TextStyle(
                fontSize: 26, 
                fontWeight: FontWeight.w900, 
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  // الانتقال السلس لشاشة البحث الكاملة والمنفصلة تماماً
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(
                        myUid: widget.myUid,
                        myName: widget.myName,
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
                  // تحسين قائمة الـ Popup لتكون أكثر تجانساً مع الشكل الزجاجي
                  color: const Color(0xFF1A1A22).withOpacity(0.96), 
                  elevation: 10,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    // إضافة حافة بنفسجية دقيقة لقائمة القائمة
                    side: BorderSide(color: accentColor.withOpacity(0.12)),
                  ),
                  onSelected: (value) {
                    if (value == 'channel') widget.onCreateChannel();
                    if (value == 'group') widget.onCreateGroup();
                  },
                  itemBuilder: (context) => [
                    _buildPopupMenuItem('channel', Icons.campaign_rounded, 'Create Channel', accentColor),
                    _buildPopupMenuItem('group', Icons.group_add_rounded, 'Create Group', accentColor),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon, String text, Color accentColor) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // تغيير خلفية الأيقونة لتكون بلمسة بنفسجية خفيفة
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.85), size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            text, 
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIslandNavBar(Color accentColor) {
    return SafeArea(
      top: false,
      child: LuxuryGlassContainer(
        borderRadius: 36,
        // تم تقليل الـ vertical padding لجعل الجزيرة أنحف
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
        accentColor: accentColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _AnimatedNavItem(
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
              index: 0,
              currentIndex: widget.currentIndex,
              onTap: widget.onTabSelected,
              accentColor: accentColor,
            ),
            _AnimatedNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              index: 1,
              currentIndex: widget.currentIndex,
              onTap: widget.onTabSelected,
              accentColor: accentColor,
            ),
            _AnimatedNavItem(
              icon: Icons.tune_rounded,
              activeIcon: Icons.tune_rounded,
              index: 2,
              currentIndex: widget.currentIndex,
              onTap: widget.onTabSelected,
              accentColor: accentColor,
            ), 
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Widgets المساعدة المعاد بناؤها وتعديلها للفخامة
// ==========================================

/// ويدجت زر الملاحة المعزول برمجياً للتعامل مع حركات الـ Spring بامتياز (تعديل الألوان للـ Luxury)
class _AnimatedNavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color accentColor;

  const _AnimatedNavItem({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.accentColor,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.currentIndex == widget.index;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap(widget.index);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0, // حركة انكماش فيزيائية (Spring Effect)
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          // تم تقليل الـ vertical padding هنا أيضاً لتقليل الارتفاع الكلي
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  isSelected ? widget.activeIcon : widget.icon,
                  key: ValueKey<bool>(isSelected),
                  // استخدام البنفسجي الفاخر للأيقونة المفعلة
                  color: isSelected ? widget.accentColor : Colors.white.withOpacity(0.4),
                  size: 26, 
                ),
              ),
              // تم تقليل المسافة بين الأيقونة والمؤشر لتكون أدمج
              const SizedBox(height: 4),
              // المؤشر السفلي تم تحويله إلى كبسولة دقيقة بدلاً من دائرة بسيطة
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                height: 4,
                width: isSelected ? 16 : 0, 
                decoration: BoxDecoration(
                  // لون المؤشر بنفسجي فاخر
                  color: widget.accentColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isSelected
                      ? [
                          // ظل بنفسجي متوهج بلمسة ناعمة
                          BoxShadow(
                            color: widget.accentColor.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// كبسولة زجاجية محسنة بظلال عميقة وأداء عالي - تمت إعادة بنائها لتكون Luxury
class LuxuryGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color accentColor;

  const LuxuryGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // تعديل الحافة لتكون بلمسة بنفسجية دقيقة ومزدوجة
        border: Border.all(
          // دمج البنفسجي مع الأبيض بـ Opacity منخفض للحافة
          color: accentColor.withOpacity(0.18), 
          width: 0.6,
        ),
        // تحسين الجراديانت الداخلي ليكون بلمسة بنفسجية خفيفة جداً
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.06), // لمسة بنفسجية في الأعلى
            Colors.white.withOpacity(0.04), // لمسة بيضاء في الأسفل
          ],
        ),
        boxShadow: [
          // ظل أعمق وأكثر كثافة لزيادة العمق العام
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
          // ظل دقيق بلمسة بنفسجية ناعمة لتحديد الحواف السفلية بشكل فاخر
          BoxShadow(
            color: accentColor.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: -1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // RepaintBoundary لضمان عدم تأثر باقي الشاشة بإعادة رسم الـ Blur المكلف
      child: RepaintBoundary( 
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            // زيادة قوة الـ Blur لزيادة الفخامة (تأثير Glassmorphism أقوى)
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32), 
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
