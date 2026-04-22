// ============================================================
//  PIXEL-PERFECT PROFILE SCREEN  ·  Flutter
//  Senior-level rewrite — Stack-based depth architecture
// ============================================================
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF020B18),
  ));
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppTheme.bg,
        ),
        home: const ProfilePage(),
      );
}

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
abstract class AppTheme {
  static const bg           = Color(0xFF020B18);
  static const cardDark     = Color(0xFF0D1526);
  static const blue         = Color(0xFF4D7CFF);
  static const purple       = Color(0xFF9B51E0);
  static const pink         = Color(0xFFFF2E63);
  static const green        = Color(0xFF27AE60);
  static const textSub      = Color(0xFF8E8E93);
  static const glassWhite05 = Color(0x0DFFFFFF);
  static const glassWhite10 = Color(0x1AFFFFFF);
  static const glassWhite15 = Color(0x26FFFFFF);

  static const sweepColors = [blue, purple, pink, blue];

  static const btnGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, purple],
  );

  static List<BoxShadow> neonGlow({
    required Color color,
    double blur = 24,
    double spread = 2,
  }) =>
      [
        BoxShadow(color: color.withOpacity(0.55), blurRadius: blur, spreadRadius: spread),
        BoxShadow(color: color.withOpacity(0.25), blurRadius: blur * 2, spreadRadius: spread + 4),
      ];
}

// ─────────────────────────────────────────────
//  PAGE  (Stack-based: bg → content → avatar)
// ─────────────────────────────────────────────
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // story-cards height (visible above the scroll area)
  static const double _storyHeight = 210.0;
  // how much the avatar overlaps below the cards
  static const double _avatarRadius = 52.0;
  static const double _avatarOverlap = 36.0; // px that sit BELOW card bottom

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // ── LAYER 1 · atmospheric background glows ──────────────
          _AtmosphericBg(screenW: screenW),

          // ── LAYER 2 · scrollable content ────────────────────────
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // story cards + space for avatar overlap
                  _StoriesSection(
                    storyHeight: _storyHeight,
                    avatarRadius: _avatarRadius,
                    avatarOverlap: _avatarOverlap,
                  ),

                  // ── content below avatar ──
                  const SizedBox(height: 16),
                  const _ProfileInfo(),
                  const SizedBox(height: 28),
                  const _ActionRow(),
                  const SizedBox(height: 32),
                  const _SocialPiles(),
                  const SizedBox(height: 28),
                  const _GalleryGrid(),
                  SizedBox(height: mq.padding.bottom + 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LAYER 1 · ATMOSPHERIC BACKGROUND
// ─────────────────────────────────────────────
class _AtmosphericBg extends StatelessWidget {
  final double screenW;
  const _AtmosphericBg({required this.screenW});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // primary top-center blue glow
      Positioned(
        top: -100,
        left: screenW / 2 - 200,
        child: _Glow(size: 400, color: AppTheme.blue.withOpacity(0.22)),
      ),
      // secondary top-right teal accent
      Positioned(
        top: 0,
        right: -80,
        child: _Glow(size: 260, color: const Color(0xFF00C6FF).withOpacity(0.12)),
      ),
      // deep purple lower glow
      Positioned(
        top: 120,
        left: -60,
        child: _Glow(size: 220, color: AppTheme.purple.withOpacity(0.10)),
      ),
    ]);
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );
}

// ─────────────────────────────────────────────
//  STORY CARDS + OVERLAPPING AVATAR
// ─────────────────────────────────────────────
class _StoriesSection extends StatelessWidget {
  final double storyHeight;
  final double avatarRadius;
  final double avatarOverlap;

  const _StoriesSection({
    required this.storyHeight,
    required this.avatarRadius,
    required this.avatarOverlap,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = storyHeight + avatarRadius + avatarOverlap;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── story cards row ──────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: storyHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _StoryCard(
                  label: 'Now',
                  gradientA: Color(0xFF6B1FA0),
                  gradientB: Color(0xFF1A0535),
                  dimmed: true,
                ),
                SizedBox(width: 5),
                _StoryCard(
                  label: 'Then',
                  gradientA: Color(0xFF1E4FBF),
                  gradientB: Color(0xFF061030),
                  dimmed: false,
                ),
                SizedBox(width: 5),
                _StoryCard(
                  label: '1h ago',
                  gradientA: Color(0xFFC42060),
                  gradientB: Color(0xFF1A0010),
                  dimmed: true,
                ),
              ],
            ),
          ),

          // ── avatar overlapping cards bottom ──────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _GlowAvatar(radius: avatarRadius),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STORY CARD
// ─────────────────────────────────────────────
class _StoryCard extends StatelessWidget {
  final String label;
  final Color gradientA;
  final Color gradientB;
  final bool dimmed;

  const _StoryCard({
    required this.label,
    required this.gradientA,
    required this.gradientB,
    required this.dimmed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // base gradient (simulates photo)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [gradientA, gradientB],
                ),
              ),
            ),

            // person silhouette
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // head
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(dimmed ? 0.08 : 0.12),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // body
                  Container(
                    width: 52, height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: Colors.white.withOpacity(dimmed ? 0.07 : 0.10),
                    ),
                  ),
                ],
              ),
            ),

            // glassmorphism layer for dimmed cards
            if (dimmed)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                child: Container(color: Colors.black.withOpacity(0.15)),
              ),

            // bottom fade overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),
            ),

            // label badge
            Positioned(
              top: 13,
              left: 0, right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.glassWhite15,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.glassWhite10, width: 1),
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

// ─────────────────────────────────────────────
//  GLOW AVATAR  (SweepGradient border + glow)
// ─────────────────────────────────────────────
class _GlowAvatar extends StatelessWidget {
  final double radius;
  const _GlowAvatar({required this.radius});

  @override
  Widget build(BuildContext context) {
    const border = 3.5;
    final total = radius * 2;

    return Container(
      width: total,
      height: total,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // pink core glow
          BoxShadow(
            color: AppTheme.pink.withOpacity(0.50),
            blurRadius: 22,
            spreadRadius: 2,
          ),
          // blue mid glow
          BoxShadow(
            color: AppTheme.blue.withOpacity(0.40),
            blurRadius: 40,
            spreadRadius: 6,
          ),
          // purple far glow
          BoxShadow(
            color: AppTheme.purple.withOpacity(0.28),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SweepRingPainter(strokeWidth: border),
        child: Padding(
          padding: EdgeInsets.all(border),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE84C7A),
                  Color(0xFF9840CC),
                  Color(0xFF3D6FFF),
                ],
              ),
            ),
            child: ClipOval(
              child: Center(
                child: Icon(
                  Icons.person,
                  size: radius * 0.95,
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SweepRingPainter extends CustomPainter {
  final double strokeWidth;
  const _SweepRingPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: AppTheme.sweepColors,
        startAngle: 0,
        endAngle: math.pi * 2,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2 - strokeWidth / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────
//  PROFILE INFO  (name · status · bio)
// ─────────────────────────────────────────────
class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // ── name + badge ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Kristin Watson',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              // verified badge — solid blue circle
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.blue,
                  boxShadow: AppTheme.neonGlow(
                    color: AppTheme.blue, blur: 14, spread: 0),
                ),
                child: const Icon(Icons.check,
                    color: Colors.white, size: 14),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── online status ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.green,
                  boxShadow: AppTheme.neonGlow(
                    color: AppTheme.green, blur: 8, spread: 0),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Online',
                style: TextStyle(
                  color: AppTheme.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── bio ─────────────────────────────────────────────────
          const Text(
            "I'm a generous and girl, hope my enthusiasm\nadd more color to your life... More",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSub,
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTION ROW  (share · message · add)
// ─────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GlassBtn(icon: Icons.reply_outlined),          // share (reply icon mirrored)
          const SizedBox(width: 16),
          const _MessageBtn(),
          const SizedBox(width: 16),
          _GlassBtn(icon: Icons.person_add_outlined),
        ],
      ),
    );
  }
}

// glass icon button
class _GlassBtn extends StatelessWidget {
  final IconData icon;
  const _GlassBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 54, height: 46,
          decoration: BoxDecoration(
            color: AppTheme.glassWhite05,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppTheme.glassWhite10, width: 1.2),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.85), size: 22),
        ),
      ),
    );
  }
}

// gradient message button
class _MessageBtn extends StatelessWidget {
  const _MessageBtn();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      constraints: const BoxConstraints(minWidth: 148),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: AppTheme.btnGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.blue.withOpacity(0.55),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppTheme.purple.withOpacity(0.40),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {},
          child: const Center(
            child: Text(
              'Message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
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

// ─────────────────────────────────────────────
//  SOCIAL PILES  (Friends Flow · Mutual Groups)
// ─────────────────────────────────────────────
class _SocialPiles extends StatelessWidget {
  const _SocialPiles();

  static const _friendColors = [
    Color(0xFFAF52DE), Color(0xFF5856D6),
    Color(0xFFFF2D55), Color(0xFF34C759),
  ];
  static const _groupColors = [
    Color(0xFFFF6B35), Color(0xFFBF5AF2),
    Color(0xFF32ADE6), Color(0xFFFFCC00),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PileGroup(
            label: 'Friends Flow',
            count: '+123',
            colors: _friendColors,
          ),
          _PileGroup(
            label: 'Mutual Groups',
            count: '+12',
            colors: _groupColors,
          ),
        ],
      ),
    );
  }
}

class _PileGroup extends StatelessWidget {
  final String label;
  final String count;
  final List<Color> colors;

  const _PileGroup({
    required this.label,
    required this.count,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OverlapAvatars(colors: colors, count: count),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OverlapAvatars extends StatelessWidget {
  final List<Color> colors;
  final String count;
  const _OverlapAvatars({required this.colors, required this.count});

  static const double _size    = 36.0;
  static const double _overlap = 14.0;

  @override
  Widget build(BuildContext context) {
    final pileWidth = _size + (colors.length - 1) * (_size - _overlap);
    final totalW    = pileWidth + 48;

    return SizedBox(
      width: totalW,
      height: _size,
      child: Stack(
        children: [
          // avatar circles
          for (int i = 0; i < colors.length; i++)
            Positioned(
              left: i * (_size - _overlap),
              child: Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[i],
                  border: Border.all(color: AppTheme.bg, width: 2.5),
                ),
              ),
            ),
          // count bubble
          Positioned(
            left: pileWidth + 6,
            child: Container(
              width: 40,
              height: _size,
              decoration: BoxDecoration(
                color: AppTheme.blue.withOpacity(0.22),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppTheme.blue.withOpacity(0.45), width: 1),
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

// ─────────────────────────────────────────────
//  GALLERY GRID
//  Row 1 : 1:1 square   |  2:1 wide rectangle
//  Row 2 : 3 × portrait (3:4)
// ─────────────────────────────────────────────
class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid();

  static const _items = [
    _GalleryData([Color(0xFFFF6B8A), Color(0xFF7B2FBE)]),  // 0 square
    _GalleryData([Color(0xFFAEF0E4), Color(0xFFFED6E3)]),  // 1 wide
    _GalleryData([Color(0xFFFFD89B), Color(0xFF19547B)]),  // 2 portrait
    _GalleryData([Color(0xFF5C258D), Color(0xFF4389A2)]),  // 3 portrait
    _GalleryData([Color(0xFFF8CDDA), Color(0xFF1D2B64)]),  // 4 portrait
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // ── Row 1 ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // square (1:1)
              SizedBox(
                width: 130, height: 130,
                child: _GalleryTile(data: _items[0], radius: 20),
              ),
              const SizedBox(width: 8),
              // wide rectangle (fills remaining width at half the height)
              Expanded(
                child: SizedBox(
                  height: 130,
                  child: _GalleryTile(data: _items[1], radius: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Row 2 ───────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: SizedBox(
                  height: 160,
                  child: _GalleryTile(data: _items[2], radius: 20))),
                const SizedBox(width: 8),
                Expanded(child: SizedBox(
                  height: 160,
                  child: _GalleryTile(data: _items[3], radius: 20))),
                const SizedBox(width: 8),
                Expanded(child: SizedBox(
                  height: 160,
                  child: _GalleryTile(data: _items[4], radius: 20))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryData {
  final List<Color> colors;
  const _GalleryData(this.colors);
}

class _GalleryTile extends StatelessWidget {
  final _GalleryData data;
  final double radius;
  const _GalleryTile({required this.data, required this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // base gradient (photo substitute)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: data.colors,
              ),
            ),
          ),
          // top-right decorative circle
          Positioned(
            top: -18, right: -18,
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          // bottom-left small accent
          Positioned(
            bottom: -10, left: -10,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.12),
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
                  stops: const [0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.38),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
