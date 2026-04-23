import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ChatXApp());
}

class ChatXApp extends StatelessWidget {
  const ChatXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatX Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),
      home: const ProfileScreen(),
    );
  }
}

// ─── Color Palette ────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF0A0E21);
  static const cyan = Color(0xFF00FFFF);
  static const purple = Color(0xFFBF00FF);
  static const violet = Color(0xFF7B2FFF);
  static const blue = Color(0xFF4A90E2);
  static const glassWhite = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B8D0);
  static const online = Color(0xFF00E676);
  static const cardDark = Color(0xFF12182E);
}

// ─── Placeholder image colors for gallery ─────────────────────────────────────
const List<List<Color>> _galleryGradients = [
  [Color(0xFFE040FB), Color(0xFF7B1FA2)],
  [Color(0xFF80DEEA), Color(0xFF0097A7)],
  [Color(0xFFFFB74D), Color(0xFFF57C00)],
  [Color(0xFF69F0AE), Color(0xFF00796B)],
  [Color(0xFFFF8A65), Color(0xFFBF360C)],
  [Color(0xFF90CAF9), Color(0xFF1565C0)],
  [Color(0xFFF48FB1), Color(0xFF880E4F)],
];

// ─── Placeholder story colors ──────────────────────────────────────────────────
const List<List<Color>> _storyGradients = [
  [Color(0xFF9C27B0), Color(0xFF3F51B5)],
  [Color(0xFF00BCD4), Color(0xFF1A237E)],
  [Color(0xFFE91E63), Color(0xFF9C27B0)],
];

const List<String> _storyLabels = ['Now', '12m', '1h ago'];

// ─── Profile Screen ────────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: _GlassIconButton(icon: Icons.arrow_back_ios_new_rounded),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: _GlassIconButton(icon: Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Background ──────────────────────────────────────────────────────
          _buildBackground(size),
          // ── Scrollable content ───────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildStories(size),
                  const SizedBox(height: 0),
                  _buildHeader(size),
                  const SizedBox(height: 28),
                  _buildActions(size),
                  const SizedBox(height: 28),
                  _buildFriendsRow(size),
                  const SizedBox(height: 24),
                  _buildGallery(size),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Background with neon orbs ───────────────────────────────────────────────
  Widget _buildBackground(Size size) {
    return Stack(
      children: [
        Container(color: AppColors.background),
        // Cyan orb top-left
        Positioned(
          top: -80,
          left: -60,
          child: _NeonOrb(
            color: AppColors.cyan.withOpacity(0.35),
            size: size.width * 0.65,
          ),
        ),
        // Purple orb top-right
        Positioned(
          top: 60,
          right: -80,
          child: _NeonOrb(
            color: AppColors.purple.withOpacity(0.3),
            size: size.width * 0.6,
          ),
        ),
        // Violet orb center
        Positioned(
          top: size.height * 0.3,
          left: size.width * 0.1,
          child: _NeonOrb(
            color: AppColors.violet.withOpacity(0.18),
            size: size.width * 0.5,
          ),
        ),
        // Blue orb bottom
        Positioned(
          bottom: 80,
          right: -40,
          child: _NeonOrb(
            color: AppColors.blue.withOpacity(0.22),
            size: size.width * 0.55,
          ),
        ),
      ],
    );
  }

  // ── Stories row ──────────────────────────────────────────────────────────────
  Widget _buildStories(Size size) {
    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final isCenter = i == 1;
          return _StoryCard(
            gradientColors: _storyGradients[i],
            label: _storyLabels[i],
            isCenter: isCenter,
            width: isCenter ? size.width * 0.32 : size.width * 0.26,
            height: isCenter ? 130 : 110,
          );
        }),
      ),
    );
  }

  // ── Header: avatar + name + bio ──────────────────────────────────────────────
  Widget _buildHeader(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Avatar with dual-glow
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violet.withOpacity(0.7),
                      blurRadius: 32,
                      spreadRadius: 6,
                    ),
                    BoxShadow(
                      color: AppColors.cyan.withOpacity(0.4),
                      blurRadius: 50,
                      spreadRadius: 2,
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [AppColors.cyan, AppColors.violet, AppColors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Avatar container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE040FB), Color(0xFF7B2FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.background,
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white70,
                  ),
                ),
              ),
              // Verified badge
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4A90E2),
                    border: Border.all(color: AppColors.background, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90E2).withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Kristin Watson',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4A90E2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A90E2).withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Online indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.online,
                  boxShadow: [
                    BoxShadow(color: AppColors.online, blurRadius: 6, spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Online',
                style: TextStyle(
                  color: AppColors.online,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Bio
          Text(
            "I'm a generous and girl, hope my enthusiasm\nadd more color to your life... ",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Text(
            'More',
            style: TextStyle(
              color: AppColors.violet,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ───────────────────────────────────────────────────────────
  Widget _buildActions(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Share button (glassmorphic)
          _GlassActionButton(
            icon: Icons.ios_share_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          // Message button (gradient glow)
          _GradientMessageButton(width: size.width * 0.38),
          const SizedBox(width: 12),
          // Follow button (glassmorphic)
          _GlassActionButton(
            icon: Icons.person_add_alt_1_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── Friends Flow + Mutual Groups row ─────────────────────────────────────────
  Widget _buildFriendsRow(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarStack(count: 123),
                    const SizedBox(height: 8),
                    const Text(
                      'Friends Flow',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarStack(count: 12, isPurple: true),
                    const SizedBox(height: 8),
                    const Text(
                      'Mutual Groups',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Masonry-style gallery ─────────────────────────────────────────────────────
  Widget _buildGallery(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Row 1: tall left + wide right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GalleryCell(
                width: size.width * 0.25,
                height: 160,
                gradientColors: _galleryGradients[0],
              ),
              const SizedBox(width: 8),
              _GalleryCell(
                width: size.width * 0.55,
                height: 160,
                gradientColors: _galleryGradients[1],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: three tiles
          Row(
            children: [
              _GalleryCell(
                width: size.width * 0.28,
                height: 140,
                gradientColors: _galleryGradients[2],
              ),
              const SizedBox(width: 8),
              _GalleryCell(
                width: size.width * 0.26,
                height: 140,
                gradientColors: _galleryGradients[3],
              ),
              const SizedBox(width: 8),
              _GalleryCell(
                width: size.width * 0.22,
                height: 140,
                gradientColors: _galleryGradients[4],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 3: wide left + narrow right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GalleryCell(
                width: size.width * 0.45,
                height: 120,
                gradientColors: _galleryGradients[5],
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _GalleryCell(
                    width: size.width * 0.33,
                    height: 56,
                    gradientColors: _galleryGradients[6],
                  ),
                  const SizedBox(height: 8),
                  _GalleryCell(
                    width: size.width * 0.33,
                    height: 56,
                    gradientColors: _galleryGradients[0],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ──────────────────────────────────────────────────────────

class _NeonOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _NeonOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final List<Color> gradientColors;
  final String label;
  final bool isCenter;
  final double width;
  final double height;

  const _StoryCard({
    required this.gradientColors,
    required this.label,
    required this.isCenter,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: isCenter
            ? [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
        border: Border.all(
          color: Colors.white.withOpacity(isCenter ? 0.25 : 0.12),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Icon placeholder
          Center(
            child: Icon(
              Icons.person,
              color: Colors.white.withOpacity(0.5),
              size: 36,
            ),
          ),
          // Label at bottom
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Live dot for center
          if (isCenter)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.online,
                  boxShadow: [
                    BoxShadow(color: AppColors.online, blurRadius: 6, spreadRadius: 1),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.glassWhite,
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassWhite,
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  const _GlassIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassWhite,
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _GradientMessageButton extends StatelessWidget {
  final double width;
  const _GradientMessageButton({required this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: width,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFFBF00FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B2FFF).withOpacity(0.55),
              blurRadius: 22,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Message',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final int count;
  final bool isPurple;
  const _AvatarStack({required this.count, this.isPurple = false});

  @override
  Widget build(BuildContext context) {
    final colors = isPurple
        ? [
            [const Color(0xFFBF00FF), const Color(0xFF7B2FFF)],
            [const Color(0xFF7B2FFF), const Color(0xFF4A90E2)],
            [const Color(0xFF4A90E2), const Color(0xFF00FFFF)],
          ]
        : [
            [const Color(0xFFFF8A65), const Color(0xFFF57C00)],
            [const Color(0xFFE040FB), const Color(0xFF7B1FA2)],
            [const Color(0xFF69F0AE), const Color(0xFF00796B)],
          ];

    return Row(
      children: [
        SizedBox(
          width: 70,
          height: 28,
          child: Stack(
            children: List.generate(3, (i) {
              return Positioned(
                left: i * 18.0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colors[i][0], colors[i][1]],
                    ),
                    border: Border.all(color: AppColors.cardDark, width: 2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '+$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _GalleryCell extends StatelessWidget {
  final double width;
  final double height;
  final List<Color> gradientColors;

  const _GalleryCell({
    required this.width,
    required this.height,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle shine overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Center(
              child: Icon(
                Icons.image_outlined,
                color: Colors.white.withOpacity(0.3),
                size: height * 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
