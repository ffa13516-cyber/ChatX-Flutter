import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../chat/chats_tab.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../utils/app_colors.dart'; 
import 'package:chatx/screens/search/search_screen_ui.dart';
// import '../../data/firebase_repo.dart';

class HomeScreenUI extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onCreateChannel;
  final VoidCallback onCreateGroup;
  final ValueChanged<String> onSearch;

  final String myUid;
  final String myName;
  final String? myAvatarUrl; // المتغير الجديد لصورة المستخدم

  const HomeScreenUI({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onCreateChannel,
    required this.onCreateGroup,
    required this.onSearch,
    required this.myUid,
    required this.myName,
    this.myAvatarUrl, 
  });

  @override
  State<HomeScreenUI> createState() => _HomeScreenUIState();
}

class _HomeScreenUIState extends State<HomeScreenUI> with WidgetsBindingObserver {
  final List<Widget> _screens = const [
    ChatsTab(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // تم تغيير اللون للدرجة الزرقاء بناءً على التصميم المرفق
    final activeBlueColor = const Color(0xFF4A72CC); 

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E), 
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
                    accentColor: activeBlueColor,
                    child: _buildHeaderContent(context, activeBlueColor),
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
        padding: const EdgeInsets.only(bottom: 12.0, left: 24.0, right: 24.0),
        child: _buildFloatingIslandNavBar(activeBlueColor),
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context, Color accentColor) {
    return Container(
      key: const ValueKey('NormalHeader'),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [accentColor, Colors.white, Colors.white.withOpacity(0.8)],
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
                onPressed: () {
                  HapticFeedback.mediumImpact();
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
                  color: const Color(0xFF1A1A22).withOpacity(0.96), 
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.85), size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            text, 
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        accentColor: accentColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _AnimatedNavItem(
              title: 'Chats',
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
              index: 0,
              currentIndex: widget.currentIndex,
              onTap: widget.onTabSelected,
              accentColor: accentColor,
            ),
            _AnimatedNavItem(
              title: 'You',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              avatarUrl: widget.myAvatarUrl,
              index: 1,
              currentIndex: widget.currentIndex,
              onTap: widget.onTabSelected,
              accentColor: accentColor,
            ),
            _AnimatedNavItem(
              title: 'Settings',
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
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

class _AnimatedNavItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String? avatarUrl;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color accentColor;

  const _AnimatedNavItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    this.avatarUrl,
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
        scale: _isPressed ? 0.90 : 1.0, 
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? widget.accentColor.withOpacity(0.25) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildIconOrAvatar(isSelected),
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                style: TextStyle(
                  color: isSelected ? widget.accentColor : Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconOrAvatar(bool isSelected) {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty && widget.index == 1) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: widget.accentColor, width: 1.5) : null,
        ),
        child: CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(widget.avatarUrl!),
          backgroundColor: Colors.transparent,
        ),
      );
    }
    
    return Icon(
      isSelected ? widget.activeIcon : widget.icon,
      color: isSelected ? widget.accentColor : Colors.white.withOpacity(0.5),
      size: 24, 
    );
  }
}

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
        border: Border.all(
          color: Colors.white.withOpacity(0.08), 
          width: 0.8,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.01),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 32,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
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

