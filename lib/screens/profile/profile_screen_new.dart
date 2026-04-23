import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ChatXApp());
}

class ChatXApp extends StatelessWidget {
  const ChatXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: const ProfileScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXACT colors from the Dribbble screenshot (eyedropped)
// ─────────────────────────────────────────────────────────────────────────────
const kBg         = Color(0xFF0A0E21); // almost black-navy
const kBgTop      = Color(0xFF0D1F2D); // very subtle dark teal at top only
const kCard       = Color(0xFF111827); // slightly lighter for cards
const kOnline     = Color(0xFF22C55E); // green
const kTeal       = Color(0xFF06B6D4); // ring accent
const kBlue       = Color(0xFF3B82F6); // message btn left
const kPurple     = Color(0xFF8B5CF6); // message btn right
const kOrbCyan    = Color(0xFF0E7490); // very dark muted teal orb
const kOrbPurple  = Color(0xFF4C1D95); // very dark muted purple orb
const kTextSub    = Color(0xFF6B7280);
const kTextMuted  = Color(0xFF9CA3AF);

// ─────────────────────────────────────────────────────────────────────────────
// Image URLs — reliable Unsplash, portrait/atmospheric style
// ─────────────────────────────────────────────────────────────────────────────
// Stories: purple-lit female | dark-bg female | warm pink female
const _storyL = 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=300&h=500&fit=crop&q=80';
const _storyC = 'https://images.unsplash.com/photo-1541516160071-4bb0c5af65ba?w=300&h=520&fit=crop&q=80';
const _storyR = 'https://images.unsplash.com/photo-1524638431109-93d95c968f03?w=300&h=500&fit=crop&q=80';

// Avatar: warm-lit female portrait
const _avatar = 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=300&h=300&fit=crop&q=80';

// Friend avatars
const _fav1 = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=80&h=80&fit=crop&q=80';
const _fav2 = 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=80&h=80&fit=crop&q=80';
const _fav3 = 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=80&h=80&fit=crop&q=80';
const _gav1 = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop&q=80';
const _gav2 = 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&h=80&fit=crop&q=80';
const _gav3 = 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=80&h=80&fit=crop&q=80';

// Gallery images — atmospheric, editorial
// Row1: [narrow tall warm smoke] [wide mint/teal fabric]
// Row2: [amber mountain] [dark portrait] [pink profile]
// Row3: [wide moody] [small beach] [small mountain]
const _g0 = 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=300&h=500&fit=crop&q=80';
const _g1 = 'https://images.unsplash.com/photo-1557682250-33bd709cbe85?w=600&h=400&fit=crop&q=80';
const _g2 = 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop&q=80';
const _g3 = 'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=400&h=400&fit=crop&q=80';
const _g4 = 'https://images.unsplash.com/photo-1524638431109-93d95c968f03?w=400&h=400&fit=crop&q=80';
const _g5 = 'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=500&h=340&fit=crop&q=80';
const _g6 = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=300&h=200&fit=crop&q=80';
const _g7 = 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=300&h=200&fit=crop&q=80';

// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w  = MediaQuery.of(context).size.width;
    final pt = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        _buildBackground(w),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // status bar space
            SizedBox(height: pt),
            // top nav
            _buildNav(),
            // stories (edge-to-edge, no side padding)
            _buildStories(w),
            // avatar overlapping stories
            _buildAvatar(w),
            // name / online / bio
            _buildInfo(w),
            const SizedBox(height: 24),
            // action buttons
            _buildActions(w),
            const SizedBox(height: 28),
            // friends + groups
            _buildFriends(w),
            const SizedBox(height: 20),
            // gallery
            _buildGallery(w),
            const SizedBox(height: 40),
          ]),
        ),
      ]),
    );
  }

  // ── Background ──────────────────────────────────────────────────────────────
  Widget _buildBackground(double w) {
    return Stack(children: [
      // solid almost-black base
      Container(color: kBg),

      // very subtle dark teal gradient at very top only (like the screenshot)
      Container(
        height: 220,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D2333), kBg],
          ),
        ),
      ),

      // muted dark cyan orb — top left
      Positioned(
        top: -120, left: -80,
        child: _blurOrb(w * 0.7, kOrbCyan.withOpacity(0.6)),
      ),

      // muted dark purple orb — top right
      Positioned(
        top: -80, right: -100,
        child: _blurOrb(w * 0.65, kOrbPurple.withOpacity(0.55)),
      ),

      // tiny rose hint bottom right
      Positioned(
        bottom: 200, right: -60,
        child: _blurOrb(w * 0.45, const Color(0xFF7F1D1D).withOpacity(0.35)),
      ),
    ]);
  }

  Widget _blurOrb(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  // ── Nav ─────────────────────────────────────────────────────────────────────
  Widget _buildNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navBtn(Icons.arrow_back_ios_new_rounded),
          _navBtn(Icons.more_horiz_rounded),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.07),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: Icon(icon, color: Colors.white70, size: 17),
        ),
      ),
    );
  }

  // ── Stories — edge to edge, no horizontal padding ───────────────────────────
  Widget _buildStories(double w) {
    // In the original: stories go full width, left & right bleed to edges
    // center card is taller and slightly elevated
    const h    = 195.0;
    const hC   = 215.0;
    final wSide = w * 0.285;
    final wCtr  = w * 0.37;

    return SizedBox(
      height: hC,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // left — flush to left edge
          Positioned(
            left: 0, bottom: 0,
            child: _StoryCard(
              url: _storyL, label: 'Now',
              w: wSide, h: h,
              radius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              isCenter: false,
            ),
          ),
          // right — flush to right edge
          Positioned(
            right: 0, bottom: 0,
            child: _StoryCard(
              url: _storyR, label: '1h ago',
              w: wSide, h: h,
              radius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              isCenter: false,
            ),
          ),
          // center — tallest
          _StoryCard(
            url: _storyC, label: 'Now',
            w: wCtr, h: hC,
            radius: BorderRadius.circular(22),
            isCenter: true,
          ),
        ],
      ),
    );
  }

  // ── Avatar overlapping stories ───────────────────────────────────────────────
  Widget _buildAvatar(double w) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Center(
        child: Stack(alignment: Alignment.center, children: [
          // glow
          Container(
            width: 116, height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.7),
                  blurRadius: 28, spreadRadius: 3,
                ),
                BoxShadow(
                  color: kTeal.withOpacity(0.3),
                  blurRadius: 48, spreadRadius: 0,
                ),
              ],
              // thin cyan-blue gradient ring (like the original)
              gradient: const SweepGradient(
                colors: [
                  Color(0xFF06B6D4),
                  Color(0xFF818CF8),
                  Color(0xFFEC4899),
                  Color(0xFF06B6D4),
                ],
              ),
            ),
          ),
          // dark gap ring
          Container(
            width: 108, height: 108,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kBg,
            ),
          ),
          // photo
          ClipOval(
            child: SizedBox(
              width: 102, height: 102,
              child: _Img(url: _avatar),
            ),
          ),
          // verified badge
          Positioned(
            bottom: 3, right: 3,
            child: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBlue,
                border: Border.all(color: kBg, width: 2.5),
                boxShadow: [
                  BoxShadow(color: kBlue.withOpacity(0.6), blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Info ─────────────────────────────────────────────────────────────────────
  Widget _buildInfo(double w) {
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Column(children: [
        // name
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            'Kristin Watson',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 7),
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBlue,
              boxShadow: [BoxShadow(color: kBlue.withOpacity(0.55), blurRadius: 10)],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
          ),
        ]),

        const SizedBox(height: 8),

        // online
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: kOnline,
              boxShadow: [BoxShadow(color: kOnline.withOpacity(0.8), blurRadius: 7, spreadRadius: 1)],
            ),
          ),
          const SizedBox(width: 6),
          Text('Online',
            style: TextStyle(color: kOnline, fontSize: 13, fontWeight: FontWeight.w500)),
        ]),

        const SizedBox(height: 14),

        // bio
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: kTextMuted, fontSize: 14,
                height: 1.65, fontStyle: FontStyle.italic,
              ),
              children: [
                const TextSpan(
                  text: "I'm a generous and girl, hope my enthusiasm\nadd more color to your life... ",
                ),
                const TextSpan(
                  text: 'More',
                  style: TextStyle(
                    color: kTeal,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  Widget _buildActions(double w) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // share
          _GlassCircleBtn(icon: Icons.ios_share_rounded),
          const SizedBox(width: 14),
          // message — gradient pill
          Container(
            width: w * 0.38, height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [kBlue, kPurple],
              ),
              boxShadow: [
                BoxShadow(
                  color: kPurple.withOpacity(0.55),
                  blurRadius: 20, offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text('Message',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // add person
          _GlassCircleBtn(icon: Icons.person_add_alt_1_rounded),
        ],
      ),
    );
  }

  // ── Friends ──────────────────────────────────────────────────────────────────
  Widget _buildFriends(double w) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Expanded(child: _FriendCard(
          avatars: const [_fav1, _fav2, _fav3],
          count: '+123', label: 'Friends Flow',
        )),
        const SizedBox(width: 12),
        Expanded(child: _FriendCard(
          avatars: const [_gav1, _gav2, _gav3],
          count: '+12', label: 'Mutual Groups',
        )),
      ]),
    );
  }

  // ── Gallery ──────────────────────────────────────────────────────────────────
  Widget _buildGallery(double w) {
    const pad = 16.0;
    const gap = 6.0;
    final inner = w - pad * 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: pad),
      child: Column(children: [

        // Row 1: narrow-tall (warm smoke) | wide (mint fabric)
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _GalleryTile(url: _g0, w: inner * 0.29, h: 175),
          const SizedBox(width: gap),
          _GalleryTile(url: _g1, w: inner * 0.71 - gap, h: 175),
        ]),
        const SizedBox(height: gap),

        // Row 2: three equal tiles
        Row(children: [
          _GalleryTile(url: _g2, w: (inner - gap * 2) / 3, h: 148),
          const SizedBox(width: gap),
          _GalleryTile(url: _g3, w: (inner - gap * 2) / 3, h: 148),
          const SizedBox(width: gap),
          _GalleryTile(url: _g4, w: (inner - gap * 2) / 3, h: 148),
        ]),
        const SizedBox(height: gap),

        // Row 3: wide | two stacked small
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _GalleryTile(url: _g5, w: inner * 0.57, h: 138),
          const SizedBox(width: gap),
          Column(children: [
            _GalleryTile(url: _g6, w: inner * 0.43 - gap, h: 66),
            const SizedBox(height: gap),
            _GalleryTile(url: _g7, w: inner * 0.43 - gap, h: 66),
          ]),
        ]),

      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  final String url, label;
  final double w, h;
  final BorderRadius radius;
  final bool isCenter;

  const _StoryCard({
    required this.url, required this.label,
    required this.w,   required this.h,
    required this.radius, required this.isCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w, height: h,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: isCenter
            ? [BoxShadow(
                color: kTeal.withOpacity(0.18),
                blurRadius: 20, spreadRadius: 1,
              )]
            : [],
        border: Border.all(
          color: Colors.white.withOpacity(isCenter ? 0.18 : 0.06),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(fit: StackFit.expand, children: [
          _Img(url: url),
          // bottom gradient scrim
          Positioned(
            bottom: 0, left: 0, right: 0, height: 55,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 9, left: 0, right: 0,
            child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11, fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 6, color: Colors.black)],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _GlassCircleBtn extends StatelessWidget {
  final IconData icon;
  const _GlassCircleBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1C2340),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final List<String> avatars;
  final String count, label;
  const _FriendCard({required this.avatars, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // very dark, barely visible card — matching the original
        color: const Color(0xFF0F1525),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // stacked avatars
          SizedBox(
            width: 72, height: 30,
            child: Stack(
              children: List.generate(3, (i) => Positioned(
                left: i * 19.0,
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F1525), width: 2),
                  ),
                  child: ClipOval(child: _Img(url: avatars[i])),
                ),
              )),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(count,
              style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(label,
          style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final String url;
  final double w, h;
  const _GalleryTile({required this.url, required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: w, height: h,
        child: _Img(url: url),
      ),
    );
  }
}

// ── Shared network image with loading & error states ──────────────────────────
class _Img extends StatelessWidget {
  final String url;
  const _Img({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, prog) {
        if (prog == null) return child;
        return Container(
          color: const Color(0xFF111827),
          child: Center(
            child: SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Colors.white24,
                value: prog.expectedTotalBytes != null
                    ? prog.cumulativeBytesLoaded / prog.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF111827),
        child: const Icon(Icons.image_outlined, color: Colors.white12, size: 22),
      ),
    );
  }
}
