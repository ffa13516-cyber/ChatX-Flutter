// ============================================================
//  Neon Glassmorphism Chat UI  –  Flutter (Null-safe) v2
//  Fixed: BackdropFilter layering, Android compatibility,
//         gradient backgrounds, neon glow effects
//  No external packages needed (Flutter SDK >=3.0.0)
// ============================================================

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const NeonChatApp());

// ──────────────────────────────────────────────────────────────
// THEME CONSTANTS
// ──────────────────────────────────────────────────────────────
class AppColors {
  static const background    = Color(0xFF0D0F14);
  static const surface       = Color(0xFF13151E);
  static const neonPurple    = Color(0xFF7B61FF);
  static const neonBlue      = Color(0xFF00C2FF);
  static const neonPink      = Color(0xFFE040FB);
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8A8FA8);
  static const online        = Color(0xFF00E676);
  static const glassBorder   = Color(0x33FFFFFF);
  static const glassFill     = Color(0x18FFFFFF);

  static const outgoingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B61FF), Color(0xFF00C2FF)],
  );
}

// ──────────────────────────────────────────────────────────────
// DATA MODEL
// ──────────────────────────────────────────────────────────────
enum MsgType { text, image, audio }

class Msg {
  final String id, time;
  final String? text;
  final MsgType type;
  final bool out, delivered;
  const Msg({
    required this.id,
    required this.time,
    this.text,
    required this.type,
    required this.out,
    this.delivered = false,
  });
}

const _msgs = [
  Msg(id:'1', text:'👋 Hey! How are you?',                                         type:MsgType.text,  out:false, time:'9:30 AM'),
  Msg(id:'2', text:'I\'m good. You?',                                               type:MsgType.text,  out:true,  time:'9:31 AM', delivered:true),
  Msg(id:'3', text:'It seems we have a lot in common and have a lot interest in each other 😊', type:MsgType.text, out:false, time:'9:32 AM'),
  Msg(id:'4', text:'By the way, check out this artwork',                             type:MsgType.image, out:false, time:'9:33 AM'),
  Msg(id:'5',                                                                        type:MsgType.audio, out:false, time:'9:34 AM'),
  Msg(id:'6', text:'Good concepts! 🔥',                                              type:MsgType.text,  out:true,  time:'9:35 AM', delivered:true),
];

// ──────────────────────────────────────────────────────────────
// APP ROOT
// ──────────────────────────────────────────────────────────────
class NeonChatApp extends StatelessWidget {
  const NeonChatApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Neon Chat',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
    ),
    home: const ChatScreen(),
  );
}

// ──────────────────────────────────────────────────────────────
// BACKGROUND PAINTER  (mesh blobs + wave lines)
// ──────────────────────────────────────────────────────────────
class _BgPainter extends CustomPainter {
  final double t;
  const _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size s) {
    // ── Ambient colour blobs ──────────────────────────────────
    void blob(double fx, double fy, double r, Color c) {
      final center = Offset(s.width * fx, s.height * fy);
      canvas.drawCircle(
        center, r,
        Paint()
          ..shader = RadialGradient(colors: [c, c.withOpacity(0)])
              .createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }

    blob(0.15 + math.sin(t) * 0.04,      0.12 + math.cos(t * 0.7) * 0.03,
         s.width * 0.55, const Color(0x2A4A1FB8));
    blob(0.85 + math.cos(t * 0.8) * 0.03, 0.08 + math.sin(t * 1.1) * 0.02,
         s.width * 0.45, const Color(0x20003D8F));
    blob(0.55 + math.sin(t * 1.3) * 0.04, 0.35 + math.cos(t * 0.9) * 0.04,
         s.width * 0.50, const Color(0x186B3AC7));
    blob(0.20 + math.cos(t * 0.6) * 0.03, 0.70 + math.sin(t * 1.2) * 0.03,
         s.width * 0.42, const Color(0x1200C2FF));

    // ── Fluid wave lines ─────────────────────────────────────
    void wave(double yFactor, double phase, Color c, double amp) {
      final path = Path();
      final baseY = s.height * yFactor;
      path.moveTo(0, baseY);
      for (double x = 0; x <= s.width; x += 1.5) {
        final y = baseY
            + math.sin(x / s.width * math.pi * 3 + phase) * amp * 20
            + math.cos(x / s.width * math.pi * 2 + phase * 0.7) * amp * 10;
        path.lineTo(x, y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = c
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    wave(0.11, t,           const Color(0x336B3AC7), 1.2);
    wave(0.17, t + 0.8,     const Color(0x2800C2FF), 0.9);
    wave(0.23, t + 1.6,     const Color(0x22A78BFF), 1.0);
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

// ──────────────────────────────────────────────────────────────
// GLASS BOX  (real BackdropFilter blur)
// ──────────────────────────────────────────────────────────────
class GlassBox extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color fillColor;
  final double blur;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;

  const GlassBox({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.fillColor = AppColors.glassFill,
    this.blur = 16,
    this.borderColor = AppColors.glassBorder,
    this.borderWidth = 0.5,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(22);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: br,
            color: fillColor,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// WAVEFORM PAINTER
// ──────────────────────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  final List<double> bars;
  final double progress;
  const _WavePainter({required this.bars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final barW = (size.width - bars.length * 1.5) / bars.length;
    final midY = size.height / 2;

    for (int i = 0; i < bars.length; i++) {
      final x = i * (barW + 1.5);
      final h = (bars[i] * size.height * 0.85).clamp(3.0, size.height);
      final played = i / bars.length < progress;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x + barW / 2, midY), width: barW.clamp(2, 4), height: h),
        const Radius.circular(2),
      );

      canvas.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = played
              ? const LinearGradient(colors: [AppColors.neonPurple, AppColors.neonBlue])
                  .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
              : null
          ..color = played ? Colors.white : Colors.white24,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter o) => o.progress != progress;
}

// ──────────────────────────────────────────────────────────────
// CHAT SCREEN
// ──────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _dotCtrl;
  final _scroll = ScrollController();
  final _txt = TextEditingController();

  final List<AnimationController> _msgCtrl = [];
  final List<Animation<double>> _msgFade = [];
  final List<Animation<Offset>> _msgSlide = [];

  @override
  void initState() {
    super.initState();

    _bgCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
    _dotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

    for (int i = 0; i < _msgs.length; i++) {
      final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
      _msgCtrl.add(c);
      _msgFade.add(CurvedAnimation(parent: c, curve: Curves.easeOut));
      _msgSlide.add(Tween<Offset>(
        begin: Offset(_msgs[i].out ? 0.2 : -0.2, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)));

      Future.delayed(Duration(milliseconds: 100 + i * 110), () {
        if (mounted) c.forward();
      });
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _dotCtrl.dispose();
    for (final c in _msgCtrl) c.dispose();
    _scroll.dispose();
    _txt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // KEY FIX: extendBodyBehindAppBar ensures the background painter
      // covers the full screen so BackdropFilter has real content to blur
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Layer 1: Animated background (always behind everything) ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                painter: _BgPainter(_bgCtrl.value * math.pi * 2),
              ),
            ),
          ),

          // ── Layer 2: UI on top of background ──────────────────────
          SafeArea(
            child: Column(
              children: [
                _appBar(),
                Expanded(child: _messageList()),
                _inputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────
  Widget _appBar() => GlassBox(
    borderRadius: BorderRadius.zero,
    blur: 20,
    fillColor: const Color(0x22FFFFFF),
    borderColor: Colors.white.withOpacity(0.1),
    borderWidth: 0,
    shadows: [
      BoxShadow(
        color: AppColors.neonPurple.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
    padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
    child: Row(children: [
      _iconBtn(Icons.arrow_back_ios_new_rounded, () {}),
      const SizedBox(width: 6),

      // Avatar with gradient ring
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(colors: [
            AppColors.neonPurple, AppColors.neonBlue,
            AppColors.neonPink,   AppColors.neonPurple,
          ]),
          boxShadow: [BoxShadow(color: AppColors.neonPurple.withOpacity(0.5), blurRadius: 14, spreadRadius: 1)],
        ),
        padding: const EdgeInsets.all(2),
        child: const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFF1E1845),
          child: Icon(Icons.person_rounded, color: Colors.white60, size: 22),
        ),
      ),
      const SizedBox(width: 10),

      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Daniel Garcia',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16,
                fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Row(children: [
            Container(width: 7, height: 7, margin: const EdgeInsets.only(right: 5),
              decoration: const BoxDecoration(color: AppColors.online, shape: BoxShape.circle)),
            const Text('Online', style: TextStyle(color: AppColors.online, fontSize: 12)),
          ]),
        ],
      )),

      _iconBtn(Icons.call_rounded, () {}),
      const SizedBox(width: 2),
      _iconBtn(Icons.videocam_rounded, () {}),
      const SizedBox(width: 2),
      _iconBtn(Icons.more_vert_rounded, () {}),
    ]),
  );

  // ── MESSAGE LIST ───────────────────────────────────────────
  Widget _messageList() => ListView(
    controller: _scroll,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    children: [
      // Date pill
      Center(child: GlassBox(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        blur: 12,
        child: const Text('Today',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 0.5)),
      )),
      const SizedBox(height: 16),

      // Messages with staggered animations
      ..._msgs.asMap().entries.map((e) {
        final i = e.key; final m = e.value;
        return FadeTransition(
          opacity: _msgFade[i],
          child: SlideTransition(
            position: _msgSlide[i],
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _bubble(m),
            ),
          ),
        );
      }),

      // Typing indicator
      _typingIndicator(),
    ],
  );

  Widget _bubble(Msg m) {
    Widget content = switch (m.type) {
      MsgType.audio => _AudioBubble(time: m.time),
      MsgType.image => _ImageBubble(text: m.text, time: m.time),
      MsgType.text  => _TextBubble(text: m.text ?? '', out: m.out,
          time: m.time, delivered: m.delivered),
    };

    return Align(
      alignment: m.out ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!m.out) ...[
            // Sender avatar (small)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(colors: [AppColors.neonPurple, AppColors.neonBlue, AppColors.neonPurple]),
                boxShadow: [BoxShadow(color: AppColors.neonPurple.withOpacity(0.3), blurRadius: 8)],
              ),
              padding: const EdgeInsets.all(1.5),
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFF1E1845),
                child: Icon(Icons.person_rounded, color: Colors.white54, size: 16),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: content),
        ],
      ),
    );
  }

  // ── TYPING DOTS ────────────────────────────────────────────
  Widget _typingIndicator() => Align(
    alignment: Alignment.centerLeft,
    child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(colors: [AppColors.neonPurple, AppColors.neonBlue, AppColors.neonPurple]),
          boxShadow: [BoxShadow(color: AppColors.neonPurple.withOpacity(0.3), blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(1.5),
        child: const CircleAvatar(radius: 14, backgroundColor: Color(0xFF1E1845),
          child: Icon(Icons.person_rounded, color: Colors.white54, size: 16)),
      ),
      const SizedBox(width: 8),
      GlassBox(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(22), bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22), topLeft: Radius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: AnimatedBuilder(
          animation: _dotCtrl,
          builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
            final phase = (i * 0.3);
            final v = _dotCtrl.value;
            final bounce = math.sin(((v - phase).clamp(0.0, 1.0)) * math.pi);
            return Padding(
              padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
              child: Transform.translate(
                offset: Offset(0, -6 * bounce),
                child: Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      AppColors.neonPurple.withOpacity(0.5 + 0.5 * bounce),
                      AppColors.neonBlue.withOpacity(0.5 + 0.5 * bounce),
                    ]),
                    boxShadow: [BoxShadow(color: AppColors.neonPurple.withOpacity(0.4 * bounce), blurRadius: 6)],
                  ),
                ),
              ),
            );
          })),
        ),
      ),
    ]),
  );

  // ── INPUT BAR ──────────────────────────────────────────────
  Widget _inputBar() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
    child: GlassBox(
      borderRadius: BorderRadius.circular(36),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      fillColor: const Color(0x1AFFFFFF),
      blur: 20,
      borderColor: AppColors.neonPurple.withOpacity(0.30),
      borderWidth: 0.8,
      shadows: [
        BoxShadow(color: AppColors.neonPurple.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 4)),
      ],
      child: Row(children: [
        _flatIconBtn(Icons.add_rounded),
        const SizedBox(width: 2),
        _flatIconBtn(Icons.sentiment_satisfied_alt_rounded),
        const SizedBox(width: 4),
        Expanded(child: TextField(
          controller: _txt,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: const InputDecoration(
            hintText: 'Type a message...',
            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        )),
        const SizedBox(width: 4),
        _flatIconBtn(Icons.attach_file_rounded),
        const SizedBox(width: 4),
        // Mic button – gradient circle with glow
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppColors.neonPurple, AppColors.neonBlue],
              ),
              boxShadow: [
                BoxShadow(color: AppColors.neonPurple.withOpacity(0.55), blurRadius: 12, offset: const Offset(0, 4)),
                BoxShadow(color: AppColors.neonBlue.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
          ),
        ),
      ]),
    ),
  );

  // ── HELPERS ────────────────────────────────────────────────
  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.10), width: 0.5),
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 18),
    ),
  );

  Widget _flatIconBtn(IconData icon) => GestureDetector(
    onTap: () {},
    child: SizedBox(width: 36, height: 36,
      child: Icon(icon, color: AppColors.textSecondary, size: 21)),
  );
}

// ──────────────────────────────────────────────────────────────
// TEXT BUBBLE
// ──────────────────────────────────────────────────────────────
class _TextBubble extends StatelessWidget {
  final String text, time;
  final bool out, delivered;
  const _TextBubble({required this.text, required this.time, required this.out, required this.delivered});

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width * 0.74;

    final incomingRadius = const BorderRadius.only(
      topRight: Radius.circular(22), bottomLeft: Radius.circular(22),
      bottomRight: Radius.circular(22), topLeft: Radius.circular(4),
    );
    final outgoingRadius = const BorderRadius.only(
      topLeft: Radius.circular(22), bottomLeft: Radius.circular(22),
      topRight: Radius.circular(22), bottomRight: Radius.circular(4),
    );

    if (out) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          decoration: BoxDecoration(
            borderRadius: outgoingRadius,
            gradient: AppColors.outgoingGradient,
            boxShadow: [
              BoxShadow(color: AppColors.neonPurple.withOpacity(0.45), blurRadius: 12, offset: const Offset(0, 4)),
              BoxShadow(color: AppColors.neonBlue.withOpacity(0.20), blurRadius: 20, offset: const Offset(0, 2)),
            ],
          ),
          child: _content(Colors.white.withOpacity(0.75)),
        ),
      );
    }

    return GlassBox(
      borderRadius: incomingRadius,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      fillColor: const Color(0x1AFFFFFF),
      blur: 16,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: _content(AppColors.textSecondary),
      ),
    );
  }

  Widget _content(Color timeColor) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.45)),
      const SizedBox(height: 4),
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(time, style: TextStyle(color: timeColor, fontSize: 11)),
        if (delivered) ...[
          const SizedBox(width: 4),
          const Icon(Icons.done_all_rounded, size: 14, color: Colors.white70),
        ],
      ]),
    ],
  );
}

// ──────────────────────────────────────────────────────────────
// IMAGE BUBBLE
// ──────────────────────────────────────────────────────────────
class _ImageBubble extends StatelessWidget {
  final String? text;
  final String time;
  const _ImageBubble({this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width * 0.74;
    return GlassBox(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(22), bottomLeft: Radius.circular(22),
        bottomRight: Radius.circular(22), topLeft: Radius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      fillColor: const Color(0x1AFFFFFF),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (text != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(text!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
            ),

          // Artwork card
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 180,
              child: Stack(children: [
                // Gradient base
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1A0840), Color(0xFF5B2DB0), Color(0xFFB44FE8), Color(0xFF00C2FF)],
                      stops: [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
                // Swirl overlay
                Positioned.fill(child: CustomPaint(painter: _SwirlPainter())),
                // Shimmer glow
                Positioned(
                  left: -20, top: -20, right: -20, bottom: -20,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.3, -0.2),
                        radius: 0.7,
                        colors: [Colors.white.withOpacity(0.18), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                // Icon silhouette
                const Center(child: Icon(Icons.face_retouching_natural_rounded, size: 80, color: Colors.white15)),
              ]),
            ),
          ),

          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ),
        ]),
      ),
    );
  }
}

class _SwirlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2;
    for (int i = 0; i < 6; i++) {
      p.color = Colors.white.withOpacity(0.06 + i * 0.01);
      final r = 18.0 + i * 24.0;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(s.width * 0.48, s.height * 0.52), width: r * 2.4, height: r),
        p,
      );
    }
    // diagonal light streak
    final streak = Paint()
      ..shader = LinearGradient(
          colors: [Colors.transparent, Colors.white.withOpacity(0.12), Colors.transparent],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, s.width, s.height))
      ..strokeWidth = 40
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, s.height * 0.3), Offset(s.width, s.height * 0.6), streak);
  }
  @override
  bool shouldRepaint(_) => false;
}

// ──────────────────────────────────────────────────────────────
// AUDIO BUBBLE
// ──────────────────────────────────────────────────────────────
class _AudioBubble extends StatefulWidget {
  final String time;
  const _AudioBubble({required this.time});
  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> with SingleTickerProviderStateMixin {
  bool _playing = false;
  late final AnimationController _playCtrl;
  double _progress = 0.0;

  // Pseudo-random waveform (deterministic)
  final List<double> _bars = List.generate(34, (i) {
    final t = i / 34.0;
    return (0.18 + 0.75 * math.sin(t * math.pi * 5 + 0.4).abs()
        * (0.55 + 0.45 * math.cos(t * math.pi * 9).abs())).clamp(0.08, 1.0);
  });

  @override
  void initState() {
    super.initState();
    _playCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 45))
      ..addListener(() {
        setState(() => _progress = _playCtrl.value);
        if (_playCtrl.isCompleted) setState(() => _playing = false);
      });
  }

  @override
  void dispose() { _playCtrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _playing = !_playing);
    _playing ? _playCtrl.forward() : _playCtrl.stop();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(22), bottomLeft: Radius.circular(22),
        bottomRight: Radius.circular(22), topLeft: Radius.circular(4),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 10),
      fillColor: const Color(0x1AFFFFFF),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [
            // Play/Pause button
            GestureDetector(
              onTap: _toggle,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.neonPurple, Color(0xFF5A44CC)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: AppColors.neonPurple.withOpacity(0.50), blurRadius: 12, offset: const Offset(0, 3)),
                  ],
                ),
                child: Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white, size: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Waveform
            Expanded(child: SizedBox(
              height: 38,
              child: CustomPaint(painter: _WavePainter(bars: _bars, progress: _progress)),
            )),
            const SizedBox(width: 10),
            Text('0:45',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12,
                  fontFeatures: [FontFeature.tabularFigures()])),
          ]),
          const SizedBox(height: 5),
          Text(widget.time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ]),
      ),
    );
  }
}
