import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080B14),
      ),
      home: const ProfileScreen(),
    );
  }
}

// ══════════════════════════════════════════════
// COLORS
// ══════════════════════════════════════════════
class C {
  static const bg          = Color(0xFF080B14);
  static const card        = Color(0xFF111520);
  static const blue        = Color(0xFF4D7CFF);
  static const purple      = Color(0xFF9B51E0);
  static const pink        = Color(0xFFFF2E63);
  static const green       = Color(0xFF27AE60);
  static const muted       = Color(0xFF8E8E93);
  static const verifiedBg  = Color(0xFF4F6EF7);
  static const socialCard  = Color(0xFF131826);
}

// ══════════════════════════════════════════════
// PROFILE SCREEN
// ══════════════════════════════════════════════
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: [
          // subtle background radial glow
          Positioned(
            top: -80, left: sw / 2 - 180,
            child: _radialGlow(360, C.blue.withOpacity(0.18)),
          ),
          Positioned(
            top: 20, right: -60,
            child: _radialGlow(240, C.purple.withOpacity(0.12)),
          ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ── HEADER (story cards + avatar)
                  _Header(screenWidth: sw),

                  // ── USER INFO
                  const SizedBox(height: 18),
                  _UserInfo(),

                  // ── ACTION BUTTONS
                  const SizedBox(height: 28),
                  _ActionButtons(),

                  // ── SOCIAL SECTION
                  const SizedBox(height: 32),
                  _SocialSection(),

                  // ── GALLERY
                  const SizedBox(height: 24),
                  _GalleryGrid(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _radialGlow(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, Colors.transparent]),
    ),
  );
}

// ══════════════════════════════════════════════
// HEADER  ─  story cards + avatar overlapping
// ══════════════════════════════════════════════
class _Header extends StatelessWidget {
  final double screenWidth;
  const _Header({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── story cards row fills full width
          Positioned(
            top: 0, left: 0, right: 0,
            child: SizedBox(
              height: 230,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StoryCard(
                    label: 'Now',
                    topColor: const Color(0xFF5B1A8A),
                    bottomColor: const Color(0xFF1A0033),
                    isCenter: false,
                  ),
                  const SizedBox(width: 6),
                  _StoryCard(
                    label: 'Then',
                    topColor: const Color(0xFF1A4A9E),
                    bottomColor: const Color(0xFF0A0D2A),
                    isCenter: true,
                  ),
                  const SizedBox(width: 6),
                  _StoryCard(
                    label: '1h ago',
                    topColor: const Color(0xFF8A1535),
                    bottomColor: const Color(0xFF1A0010),
                    isCenter: false,
                  ),
                ],
              ),
            ),
          ),

          // ── avatar centered, overlapping cards bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Center(child: _GlowAvatar()),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// STORY CARD
// ══════════════════════════════════════════════
class _StoryCard extends StatelessWidget {
  final String label;
  final Color topColor;
  final Color bottomColor;
  final bool isCenter;

  const _StoryCard({
    required this.label,
    required this.topColor,
    required this.bottomColor,
    required this.isCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // base gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [topColor, bottomColor],
                ),
              ),
            ),

            // person silhouette shape
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: isCenter ? 44 : 36,
                    height: isCenter ? 44 : 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.13),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: isCenter ? 60 : 48,
                    height: isCenter ? 52 : 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                ],
              ),
            ),

            // bottom dark fade
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),

            // blur for side cards
            if (!isCenter)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(color: Colors.black.withOpacity(0.08)),
              ),

            // label badge top center
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// AVATAR  ─  glow + sweep border + icon
// ══════════════════════════════════════════════
class _GlowAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // pink/red inner glow
          BoxShadow(
            color: const Color(0xFFFF2E63).withOpacity(0.45),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          // blue outer glow
          BoxShadow(
            color: C.blue.withOpacity(0.35),
            blurRadius: 38,
            spreadRadius: 6,
          ),
          // purple far glow
          BoxShadow(
            color: C.purple.withOpacity(0.25),
            blurRadius: 55,
            spreadRadius: 10,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SweepBorderPainter(strokeWidth: 3.5),
        child: Padding(
          padding: const EdgeInsets.all(3.5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0427A),
                  Color(0xFF9B3FC8),
                  Color(0xFF4D7CFF),
                ],
              ),
            ),
            child: ClipOval(
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 52,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SweepBorderPainter extends CustomPainter {
  final double strokeWidth;
  const _SweepBorderPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF4D7CFF),
          Color(0xFF9B51E0),
          Color(0xFFFF2E63),
          Color(0xFF4D7CFF),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(
      size.center(Offset.zero),
      size.width / 2 - strokeWidth / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════
// USER INFO
// ══════════════════════════════════════════════
class _UserInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Name + verified
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Kristin Watson',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              // verified badge — solid blue circle with white check
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: C.verifiedBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Online status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: C.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: C.green.withOpacity(0.7),
                      blurRadius: 7,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'Online',
                style: TextStyle(
                  color: C.green,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bio
          const Text(
            "I'm a generous and girl, hope my enthusiasm\nadd more color to your life... More",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: C.muted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// ACTION BUTTONS
// ══════════════════════════════════════════════
class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CircleGlassBtn(icon: Icons.share_outlined),
          const SizedBox(width: 20),
          _MessageBtn(),
          const SizedBox(width: 20),
          _CircleGlassBtn(icon: Icons.person_add_outlined),
        ],
      ),
    );
  }
}

class _CircleGlassBtn extends StatelessWidget {
  final IconData icon;
  const _CircleGlassBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.07),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _MessageBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      constraints: const BoxConstraints(minWidth: 160),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF5B6CF6), Color(0xFF8B4FE8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B6CF6).withOpacity(0.55),
            blurRadius: 22,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF8B4FE8).withOpacity(0.4),
            blurRadius: 35,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () {},
          child: const Center(
            child: Text(
              'Message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SOCIAL SECTION
// ══════════════════════════════════════════════
class _SocialSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _SocialCard(
              label: 'Friends Flow',
              count: '+123',
              avatarColors: const [
                Color(0xFF7B2FBE),
                Color(0xFF2979FF),
                Color(0xFFE91E8C),
                Color(0xFF4CAF50),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _SocialCard(
              label: 'Mutual Groups',
              count: '+12',
              avatarColors: const [
                Color(0xFFFF5722),
                Color(0xFF9C27B0),
                Color(0xFF2196F3),
                Color(0xFFFF9800),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  final String label;
  final String count;
  final List<Color> avatarColors;

  const _SocialCard({
    required this.label,
    required this.count,
    required this.avatarColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.socialCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // stacked avatars + count
          _StackedAvatars(colors: avatarColors, count: count),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    const double size = 34;
    const double overlap = 22;
    final totalWidth = size + (colors.length - 1) * overlap + 46;

    return SizedBox(
      height: size,
      width: totalWidth,
      child: Stack(
        children: [
          // avatar circles
          for (int i = 0; i < colors.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[i],
                  border: Border.all(color: C.socialCard, width: 2.5),
                ),
              ),
            ),
          // count pill
          Positioned(
            left: colors.length * overlap,
            child: Container(
              width: 44,
              height: size,
              decoration: BoxDecoration(
                color: C.blue.withOpacity(0.25),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: C.blue.withOpacity(0.5),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
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

// ══════════════════════════════════════════════
// GALLERY GRID
// ══════════════════════════════════════════════
class _GalleryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Row 1: small square  +  wide rectangle
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 130,
                  child: _GalleryTile(
                    colors: [const Color(0xFFFF6B8A), const Color(0xFF8B2FC9)],
                    radius: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 130,
                    child: _GalleryTile(
                      colors: [const Color(0xFFAEF0E4), const Color(0xFFFED6E3)],
                      radius: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Row 2: 3 portrait tiles
          SizedBox(
            height: 155,
            child: Row(
              children: [
                Expanded(
                  child: _GalleryTile(
                    colors: [const Color(0xFFFFD89B), const Color(0xFF19547B)],
                    radius: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GalleryTile(
                    colors: [const Color(0xFF6A3093), const Color(0xFFA044FF)],
                    radius: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GalleryTile(
                    colors: [const Color(0xFFF8CDDA), const Color(0xFF1D2B64)],
                    radius: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final List<Color> colors;
  final double radius;
  const _GalleryTile({required this.colors, required this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
          // bottom darkening overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          // decorative circle accent
          Positioned(
            top: -16, right: -16,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
