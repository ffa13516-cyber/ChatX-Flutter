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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080C1A),
      ),
      home: const ProfileScreen(),
    );
  }
}

// ── Unsplash URLs — atmospheric, editorial, portrait ─────────────────────────
// Stories: moody purple left | dark figure center | rose pink right
const _storyLeft   = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80';
const _storyCenter = 'https://images.unsplash.com/photo-1541516160071-4bb0c5af65ba?w=400&q=80';
const _storyRight  = 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=400&q=80';

// Avatar: warm dramatic portrait
const _avatarUrl   = 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=400&q=80';

// Friends avatars
const _friendAvatars = [
  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=80&q=80',
  'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=80&q=80',
  'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=80&q=80',
];
const _groupAvatars = [
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&q=80',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&q=80',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=80&q=80',
];

// Gallery: warm smoke | mint fabric | amber | dark portrait | pink profile | wide moody | two small
const _galImgs = [
  'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=300&q=80', // warm orange smoke — tall left
  'https://images.unsplash.com/photo-1558591710-4b4a1ae0f700?w=600&q=80', // mint/teal fabric — wide right
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&q=80', // golden amber landscape
  'https://images.unsplash.com/photo-1542038374952-4a7135bd7219?w=400&q=80', // dark editorial portrait
  'https://images.unsplash.com/photo-1524638431109-93d95c968f03?w=400&q=80', // pink side-profile
  'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=500&q=80', // wide moody
  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80', // small top
  'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&q=80', // small bottom
];

// ── Design tokens ─────────────────────────────────────────────────────────────
class C {
  static const bg         = Color(0xFF07091A);
  static const teal       = Color(0xFF00C9C8);
  static const purple     = Color(0xFF7B2FFF);
  static const violet     = Color(0xFFBF00FF);
  static const blue       = Color(0xFF5B8DEF);
  static const online     = Color(0xFF00E676);
  static const textPri    = Colors.white;
  static const textSub    = Color(0xFF7A859E);
  static const glassDark  = Color(0xCC111828);
  static const glassBdr   = Color(0x28FFFFFF);
}

// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq   = MediaQuery.of(context);
    final w    = mq.size.width;
    final top  = mq.padding.top;

    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: [
          // ── layered background ──────────────────────────────────────────────
          _Background(w: w),

          // ── scrollable content ──────────────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // status-bar space
              SliverToBoxAdapter(child: SizedBox(height: top)),

              // app bar row
              SliverToBoxAdapter(child: _AppBarRow(w: w)),

              // stories
              SliverToBoxAdapter(child: _StoriesSection(w: w)),

              // avatar + info (overlapping stories)
              SliverToBoxAdapter(child: _HeaderSection(w: w)),

              // actions
              SliverToBoxAdapter(child: _ActionsSection(w: w)),
              SliverToBoxAdapter(child: const SizedBox(height: 28)),

              // friends row
              SliverToBoxAdapter(child: _FriendsSection(w: w)),
              SliverToBoxAdapter(child: const SizedBox(height: 28)),

              // gallery
              SliverToBoxAdapter(child: _GallerySection(w: w)),
              SliverToBoxAdapter(child: const SizedBox(height: 40)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Background ────────────────────────────────────────────────────────────────
class _Background extends StatelessWidget {
  final double w;
  const _Background({required this.w});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Stack(children: [
      // base: very dark navy
      Container(color: C.bg),

      // top gradient overlay (teal → transparent) — the key look
      Container(
        height: h * 0.42,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E3040), // dark teal top
              Color(0xFF07091A), // bg color
            ],
          ),
        ),
      ),

      // cyan orb top-center
      _Orb(dx: w * 0.1,  dy: -80, color: const Color(0xFF009999), size: w * 0.85, sigma: 70),
      // purple orb top-right
      _Orb(dx: w * 0.55, dy: -30, color: const Color(0xFF6600BB), size: w * 0.65, sigma: 65),
      // violet mid-left
      _Orb(dx: -w * 0.2, dy: h * 0.25, color: const Color(0xFF440088), size: w * 0.6, sigma: 60),
      // rose bottom-right
      _Orb(dx: w * 0.5,  dy: h * 0.6,  color: const Color(0xFF880044), size: w * 0.5, sigma: 70),
    ]);
  }
}

class _Orb extends StatelessWidget {
  final double dx, dy, size, sigma;
  final Color color;
  const _Orb({required this.dx, required this.dy, required this.color,
               required this.size, required this.sigma});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: dx, top: dy,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.45)),
        ),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────
class _AppBarRow extends StatelessWidget {
  final double w;
  const _AppBarRow({required this.w});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleBtn(icon: Icons.arrow_back_ios_new_rounded),
          _CircleBtn(icon: Icons.more_horiz_rounded),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  const _CircleBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
      ),
    );
  }
}

// ── Stories ───────────────────────────────────────────────────────────────────
class _StoriesSection extends StatelessWidget {
  final double w;
  const _StoriesSection({required this.w});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // left
          Positioned(
            left: 0, bottom: 0,
            child: _StoryCard(
              url: _storyLeft,
              label: 'Now',
              w: w * 0.295,
              h: 162,
              radius: const BorderRadius.only(
                topRight: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              isCenter: false,
            ),
          ),
          // right
          Positioned(
            right: 0, bottom: 0,
            child: _StoryCard(
              url: _storyRight,
              label: '1h ago',
              w: w * 0.295,
              h: 162,
              radius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomLeft: Radius.circular(22),
              ),
              isCenter: false,
            ),
          ),
          // center — tallest, has glow border
          Positioned(
            bottom: 0,
            child: _StoryCard(
              url: _storyCenter,
              label: 'Now',
              w: w * 0.37,
              h: 196,
              radius: BorderRadius.circular(24),
              isCenter: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final String url, label;
  final double w, h;
  final BorderRadius radius;
  final bool isCenter;
  const _StoryCard({
    required this.url, required this.label,
    required this.w, required this.h,
    required this.radius, required this.isCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w, height: h,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: isCenter ? [
          BoxShadow(color: C.teal.withOpacity(0.3), blurRadius: 28, spreadRadius: 2),
        ] : [],
        border: Border.all(
          color: Colors.white.withOpacity(isCenter ? 0.22 : 0.08),
          width: isCenter ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(fit: StackFit.expand, children: [
          _NetImg(url: url),
          // bottom scrim
          Positioned(
            bottom: 0, left: 0, right: 0, height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                ),
              ),
            ),
          ),
          // label
          Positioned(
            bottom: 10, left: 0, right: 0,
            child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 8, color: Colors.black)],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  final double w;
  const _HeaderSection({required this.w});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Column(children: [
        // Avatar
        Stack(alignment: Alignment.center, children: [
          // glow halo
          Container(
            width: 118, height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: C.violet.withOpacity(0.75), blurRadius: 35, spreadRadius: 5),
                BoxShadow(color: C.teal.withOpacity(0.45),   blurRadius: 55, spreadRadius: 0),
              ],
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF7B2FFF), Color(0xFFFF006E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // dark gap
          Container(
            width: 109, height: 109,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF07091A),
            ),
          ),
          // photo
          ClipOval(
            child: SizedBox(
              width: 102, height: 102,
              child: _NetImg(url: _avatarUrl),
            ),
          ),
          // verified dot
          Positioned(
            bottom: 5, right: 5,
            child: Container(
              width: 27, height: 27,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A90E2),
                border: Border.all(color: C.bg, width: 2.5),
                boxShadow: [BoxShadow(color: const Color(0xFF4A90E2).withOpacity(0.75), blurRadius: 12)],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 15),
            ),
          ),
        ]),

        const SizedBox(height: 14),

        // Name + badge
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Kristin Watson',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4A90E2),
              boxShadow: [BoxShadow(color: const Color(0xFF4A90E2).withOpacity(0.65), blurRadius: 12)],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
          ),
        ]),

        const SizedBox(height: 9),

        // Online
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: C.online,
              boxShadow: [BoxShadow(color: C.online, blurRadius: 8, spreadRadius: 1)],
            ),
          ),
          const SizedBox(width: 6),
          const Text('Online',
            style: TextStyle(color: C.online, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ]),

        const SizedBox(height: 16),

        // Bio
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: C.textSub, fontSize: 14,
                height: 1.7, fontStyle: FontStyle.italic,
              ),
              children: [
                const TextSpan(
                  text: "I'm a generous and girl, hope my enthusiasm\nadd more color to your life... ",
                ),
                TextSpan(
                  text: 'More',
                  style: TextStyle(
                    color: C.teal,
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
}

// ── Actions ───────────────────────────────────────────────────────────────────
class _ActionsSection extends StatelessWidget {
  final double w;
  const _ActionsSection({required this.w});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconBtn(icon: Icons.ios_share_rounded),
            const SizedBox(width: 14),
            _MsgBtn(width: w * 0.40),
            const SizedBox(width: 14),
            _IconBtn(icon: Icons.person_add_alt_1_rounded),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF151E34),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
      ),
    );
  }
}

class _MsgBtn extends StatelessWidget {
  final double width;
  const _MsgBtn({required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B8DEF), Color(0xFF9B51E0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF7B2FFF).withOpacity(0.65),
              blurRadius: 28, spreadRadius: 0, offset: const Offset(0, 8)),
          BoxShadow(color: const Color(0xFF5B8DEF).withOpacity(0.40),
              blurRadius: 18, offset: const Offset(0, 2)),
        ],
      ),
      child: const Center(
        child: Text('Message',
          style: TextStyle(
            color: Colors.white, fontSize: 16,
            fontWeight: FontWeight.w600, letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ── Friends ───────────────────────────────────────────────────────────────────
class _FriendsSection extends StatelessWidget {
  final double w;
  const _FriendsSection({required this.w});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Expanded(child: _FriendCard(urls: _friendAvatars, count: '+123', label: 'Friends Flow')),
        const SizedBox(width: 14),
        Expanded(child: _FriendCard(urls: _groupAvatars,  count: '+12',  label: 'Mutual Groups')),
      ]),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final List<String> urls;
  final String count, label;
  const _FriendCard({required this.urls, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF0F1628),
            border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // stacked avatars + count
              Row(children: [
                SizedBox(
                  width: 72, height: 32,
                  child: Stack(
                    children: List.generate(3, (i) => Positioned(
                      left: i * 20.0,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0F1628), width: 2),
                        ),
                        child: ClipOval(child: _NetImg(url: urls[i])),
                      ),
                    )),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(count,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Text(label,
                style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Gallery ───────────────────────────────────────────────────────────────────
class _GallerySection extends StatelessWidget {
  final double w;
  const _GallerySection({required this.w});

  @override
  Widget build(BuildContext context) {
    const pad = 20.0;
    const gap = 8.0;
    final inner = w - pad * 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: pad),
      child: Column(children: [

        // Row 1 — narrow tall | wide
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _GImg(url: _galImgs[0], w: inner * 0.295, h: 178),
          const SizedBox(width: gap),
          _GImg(url: _galImgs[1], w: inner * 0.705 - gap, h: 178),
        ]),
        const SizedBox(height: gap),

        // Row 2 — three equal
        Row(children: [
          _GImg(url: _galImgs[2], w: (inner - gap * 2) / 3, h: 148),
          const SizedBox(width: gap),
          _GImg(url: _galImgs[3], w: (inner - gap * 2) / 3, h: 148),
          const SizedBox(width: gap),
          _GImg(url: _galImgs[4], w: (inner - gap * 2) / 3, h: 148),
        ]),
        const SizedBox(height: gap),

        // Row 3 — wide | two stacked
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _GImg(url: _galImgs[5], w: inner * 0.56, h: 140),
          const SizedBox(width: gap),
          Column(children: [
            _GImg(url: _galImgs[6], w: inner * 0.44 - gap, h: 66),
            const SizedBox(height: gap),
            _GImg(url: _galImgs[7], w: inner * 0.44 - gap, h: 66),
          ]),
        ]),

      ]),
    );
  }
}

class _GImg extends StatelessWidget {
  final String url;
  final double w, h;
  const _GImg({required this.url, required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w, height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _NetImg(url: url),
      ),
    );
  }
}

// ── Shared network image widget ───────────────────────────────────────────────
class _NetImg extends StatelessWidget {
  final String url;
  const _NetImg({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFF111828),
          child: Center(
            child: SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: C.teal.withOpacity(0.5),
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF111828),
        child: const Icon(Icons.image_outlined, color: Colors.white12, size: 24),
      ),
    );
  }
}
