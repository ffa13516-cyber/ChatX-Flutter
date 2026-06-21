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
                  backgroundColor: Colors.transparent, // جعل الخلفية شفافة لتبدو الكبسولة عائمة
                  pinned: true,   
                  floating: false,
                  snap: false,
                  elevation: 0, 
                  toolbarHeight: 70, // ارتفاع متناسق وملموم جداً للهيدر العائم
                  titleSpacing: 0,
                  // وضع الكبسولة الزجاجية العائمة هنا بمسافات جانبية معقولة ومدروسة
                  title: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: GlassContainer(
                      borderRadius: 24, // انحناء انسيابي متناسق مع النوافذ السفلية
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
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
              ];
            },
            body: IndexedStack(
              index: widget.currentIndex,
              children: _screens,
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 40.0, right: 40.0),
          child: _buildFloatingIslandNavBar(),
        ),
      ),
    );
  }

  // محتوى الهيدر داخل الكبسولة الزجاجية
  Widget _buildHeaderContent(BuildContext context) {
    return Container(
      key: const ValueKey('NormalHeader'),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'chatx',
            style: TextStyle(
              fontSize: 24, // حجم خط عصري ومناسب للكبسولة الملمومة
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
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
                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
                  color: Colors.black.withOpacity(0.85), 
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  onSelected: (value) {
                    if (value == 'channel') widget.onCreateChannel();
                    if (value == 'group') widget.onCreateGroup();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'channel',
                      child: Row(
                        children: [
                          Icon(Icons.campaign_rounded, color: Colors.white70, size: 20),
                          SizedBox(width: 10),
                          Text('Create Channel', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'group',
                      child: Row(
                        children: [
                          Icon(Icons.group_add_rounded, color: Colors.white70, size: 20),
                          SizedBox(width: 10),
                          Text('Create Group', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // شريط البحث المدمج بذكاء وانسيابية داخل نفس الكبسولة الزجاجية
  Widget _buildExpandedSearchBar(BuildContext context) {
    return Container(
      key: const ValueKey('ExpandedSearch'),
      height: 48,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
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
              style: const TextStyle(color: Colors.white, fontSize: 15),
              onChanged: (value) {
                widget.onSearch(value);
                setState(() {}); 
              },
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.35), 
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.5), size: 18),
                        onPressed: () {
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

  // الملاحة السفلية العائمة (Floating Island NavBar)
  Widget _buildFloatingIslandNavBar() {
    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), 
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06), 
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIslandNavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 0),
                _buildIslandNavItem(Icons.person_outline_rounded, Icons.person_rounded, 1),
                _buildIslandNavItem(Icons.tune_rounded, Icons.tune_rounded, 2), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIslandNavItem(IconData icon, IconData activeIcon, int index) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); 
        widget.onTabSelected(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min, 
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
                size: 24, 
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 4,
              width: isSelected ? 4 : 0, 
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.8),
                          blurRadius: 8,
                          spreadRadius: 1,
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

// ويدجت الـ Glassmorphic المخصصة للكبسولات
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
