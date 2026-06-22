import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// مسارات الملفات الخاصة بمشروعك
import '../chat/chats_tab.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../utils/app_colors.dart';

class HomeScreenUI extends StatefulWidget {
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

  @override
  State<HomeScreenUI> createState() => _HomeScreenUIState();
}

class _HomeScreenUIState extends State<HomeScreenUI> {
  bool _isSearching = false; 
  final TextEditingController _searchController = TextEditingController();

  final List<Widget> _screens = const [
    ChatsTab(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _isSearching = false;
          _searchController.clear();
          widget.onSearch('');
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
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
                  toolbarHeight: 70, 
                  titleSpacing: 0,
                  title: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: GlassContainer(
                      borderRadius: 24, 
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      // AnimatedSize adds fluid expansion/contraction when search opens
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.02, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _isSearching 
                              ? _buildExpandedSearchBar(context) 
                              : _buildHeaderContent(context),
                        ),
                      ),
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
          padding: const EdgeInsets.only(bottom: 24.0, left: 32.0, right: 32.0),
          child: _buildFloatingIslandNavBar(),
        ),
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return Container(
      key: const ValueKey('NormalHeader'),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // إضافة لمسة جمالية للنص عبر ShaderMask (تأثير معدني خفيف)
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'chatx',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w800,
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
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
                  color: AppColors.bgDark.withOpacity(0.95), 
                  elevation: 8,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  onSelected: (value) {
                    if (value == 'channel') widget.onCreateChannel();
                    if (value == 'group') widget.onCreateGroup();
                  },
                  itemBuilder: (context) => [
                    _buildPopupMenuItem('channel', Icons.campaign_rounded, 'Create Channel'),
                    _buildPopupMenuItem('group', Icons.group_add_rounded, 'Create Group'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white70, size: 18),
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

  Widget _buildExpandedSearchBar(BuildContext context) {
    return Container(
      key: const ValueKey('ExpandedSearch'),
      height: 48,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isSearching = false;
                _searchController.clear();
                widget.onSearch('');
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true, 
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              onChanged: (value) {
                widget.onSearch(value);
                setState(() {}); 
              },
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3), 
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _searchController.clear();
                          widget.onSearch('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIslandNavBar() {
    return SafeArea(
      top: false,
      child: GlassContainer(
        borderRadius: 36,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _AnimatedNavItem(
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
              index: 0,
              currentIndex: widget.currentIndex,
              onTap: widget.onTabSelected,
            ),
            _AnimatedNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              index: 1,
              currentIndex: widget.currentIndex,
              onTap: widget.onTabSelected,
            ),
            _AnimatedNavItem(
              icon: Icons.tune_rounded,
              activeIcon: Icons.tune_rounded,
              index: 2,
              currentIndex: widget.currentIndex,
              onTap: widget.onTabSelected,
            ), 
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Widgets المساعدة المعزولة لرفع الأداء وتحسين الـ UX
// ==========================================

/// ويدجت زر الملاحة المعزول برمجياً للتعامل مع حركات الـ Spring بامتياز
class _AnimatedNavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AnimatedNavItem({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
                  color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4),
                  size: 26, 
                ),
              ),
              const SizedBox(height: 6),
              // المؤشر السفلي تم تحويله إلى كبسولة دقيقة بدلاً من دائرة بسيطة
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                height: 4,
                width: isSelected ? 16 : 0, 
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.6),
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

/// كبسولة زجاجية محسنة بظلال عميقة وأداء عالي
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
        // محاكاة انعكاس الضوء على الحواف عبر جراديانت خفيف جداً
        border: Border.all(
          color: Colors.white.withOpacity(0.15), 
          width: 0.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
        ),
        boxShadow: [
          // ظل ناعم للعمق العام
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          // ظل دقيق لتحديد الحواف السفلية
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // RepaintBoundary لضمان عدم تأثر باقي الشاشة بإعادة رسم الـ Blur المكلف
      child: RepaintBoundary( 
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
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
