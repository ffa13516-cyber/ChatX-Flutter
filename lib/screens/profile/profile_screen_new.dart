import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ProfileScreen(),
    );
  }
}

// ─── Color System ───────────────────────────────────────────────────────────

class AppColors {
  static const background   = Color(0xFF020B18);
  static const glassWhite   = Color(0x0DFFFFFF);   // 5% white
  static const glassBorder  = Color(0x1AFFFFFF);   // 10% white
  static const primaryBlue  = Color(0xFF4D7CFF);
  static const primaryPurple= Color(0xFF9B51E0);
  static const accentPink   = Color(0xFFFF2E63);
  static const onlineGreen  = Color(0xFF27AE60);
  static const textMuted    = Color(0xFF8E8E93);
  static const white        = Colors.white;
}

// ─── Gradients ───────────────────────────────────────────────────────────────

final primaryGradient = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primaryBlue, AppColors.primaryPurple],
);

final sweepBorderGradient = const SweepGradient(
  colors: [
    AppColors.primaryBlue,
    AppColors.primaryPurple,
    AppColors.accentPink,
    AppColors.primaryBlue,
  ],
);

// ─── ProfileScreen ────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background radial glow from top-center
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryBlue.withOpacity(0.28),
                      AppColors.primaryPurple.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Second accent glow (teal / cyan)
          Positioned(
            top: 60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00C6FF).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _HeaderSection(),
                  const SizedBox(height: 20),
                  _UserInfo(),
                  const SizedBox(height: 24),
                  _ActionButtons(),
                  const SizedBox(height: 28),
                  _SocialSection(),
                  const SizedBox(height: 28),
                  _GalleryGrid(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header: story cards + avatar ────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Story cards row
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _StoryCard(color: const Color(0xFF6A1B9A), label: 'Now')),
                  const SizedBox(width: 4),
                  Expanded(child: _StoryCard(color: const Color(0xFF1565C0), label: 'Then', isCenter: true)),
                  const SizedBox(width: 4),
                  Expanded(child: _StoryCard(color: const Color(0xFFAD1457), label: '1h ago')),
                ],
              ),
            ),
          ),

          // Avatar centered, overlapping bottom of cards
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(child: _GlowAvatar()),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final Color color;
  final String label;
  final bool isCenter;

  const _StoryCard({required this.color, required this.label, this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated image with gradient fill
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.9),
                  color.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Silhouette shape
          Center(
            child: Container(
              width: 50,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          // Blur on sides
          if (!isCenter)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Container(color: Colors.transparent),
            ),
          // Label
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar with sweep gradient border + glow ─────────────────────────────────

class _GlowAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.55),
            blurRadius: 28,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.40),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SweepBorderPainter(borderWidth: 3),
        child: Container(
          width: 96,
          height: 96,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFF6B8A),
                const Color(0xFF8B2FC9),
                const Color(0xFF1A0533),
              ],
            ),
          ),
          child: ClipOval(
            child: _AvatarPlaceholder(),
          ),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B8A).withOpacity(0.8),
            const Color(0xFF8B2FC9),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.person, color: Colors.white.withOpacity(0.6), size: 44),
      ),
    );
  }
}

class _SweepBorderPainter extends CustomPainter {
  final double borderWidth;
  const _SweepBorderPainter({required this.borderWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = sweepBorderGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2 - borderWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── User Info ────────────────────────────────────────────────────────────────

class _UserInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Name + verified badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Kristin Watson',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Online status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.onlineGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onlineGreen.withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Online',
                style: TextStyle(
                  color: AppColors.onlineGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bio
          const Text(
            "I'm a generous and girl, hope my enthusiasm add more color to your life... More",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _GlassCircleButton(icon: Icons.share_outlined),
          const SizedBox(width: 16),
          _GradientMessageButton(),
          const SizedBox(width: 16),
          _GlassCircleButton(icon: Icons.person_add_outlined),
        ],
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  const _GlassCircleButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glassWhite,
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _GradientMessageButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: const StadiumBorder(),
        ),
        child: const Text(
          'Message',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Social Section ───────────────────────────────────────────────────────────

class _SocialSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _SocialCard(label: 'Friends Flow', count: '+123', colors: [
            const Color(0xFF6A1B9A),
            const Color(0xFF1565C0),
            const Color(0xFFAD1457),
            const Color(0xFF4CAF50),
          ])),
          const SizedBox(width: 16),
          Expanded(child: _SocialCard(label: 'Mutual Groups', count: '+12', colors: [
            const Color(0xFFFF5722),
            const Color(0xFF9C27B0),
            const Color(0xFF2196F3),
            const Color(0xFFFF9800),
          ])),
        ],
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  final String label;
  final String count;
  final List<Color> colors;

  const _SocialCard({required this.label, required this.count, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StackedAvatars(colors: colors, count: count),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StackedAvatars extends StatelessWidget {
  final List<Color> colors;
  final String count;
  const _StackedAvatars({required this.colors, required this.count});

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    const overlap = 20.0;

    return SizedBox(
      height: size,
      width: (size + (colors.length - 1) * overlap) + 44,
      child: Stack(
        children: [
          for (int i = 0; i < colors.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[i],
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
          Positioned(
            left: colors.length * overlap,
            child: Container(
              width: size + 8,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder, width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gallery Grid ─────────────────────────────────────────────────────────────

class _GalleryGrid extends StatelessWidget {
  final List<_GalleryItem> items = const [
    _GalleryItem(color1: Color(0xFFFF6B6B), color2: Color(0xFF4ECDC4)),
    _GalleryItem(color1: Color(0xFFA8EDEA), color2: Color(0xFFFED6E3)),
    _GalleryItem(color1: Color(0xFFFFD89B), color2: Color(0xFF19547B)),
    _GalleryItem(color1: Color(0xFF6A3093), color2: Color(0xFFA044FF)),
    _GalleryItem(color1: Color(0xFFFF9A9E), color2: Color(0xFFFECFEF)),
    _GalleryItem(color1: Color(0xFFF8CDDA), color2: Color(0xFF1D2B64)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Row 1: square + wide rectangle
          Row(
            children: [
              Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _GalleryCell(item: items[0]),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 2,
                  child: _GalleryCell(item: items[1]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: 3 equal portrait cards
          Row(
            children: [
              Expanded(child: AspectRatio(aspectRatio: 0.8, child: _GalleryCell(item: items[2]))),
              const SizedBox(width: 8),
              Expanded(child: AspectRatio(aspectRatio: 0.8, child: _GalleryCell(item: items[3]))),
              const SizedBox(width: 8),
              Expanded(child: AspectRatio(aspectRatio: 0.8, child: _GalleryCell(item: items[4]))),
            ],
          ),
        ],
      ),
    );
  }
}

@immutable
class _GalleryItem {
  final Color color1;
  final Color color2;
  const _GalleryItem({required this.color1, required this.color2});
}

class _GalleryCell extends StatelessWidget {
  final _GalleryItem item;
  const _GalleryCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.color1, item.color2],
              ),
            ),
          ),
          // Subtle noise / pattern overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),
          // Decorative shape
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
