// ============================================================
//  Neon Glassmorphism Chat UI  –  Flutter (Null-safe)
//  Single-file, production-ready, no external packages needed
//  except: flutter SDK (>=3.0.0)
// ============================================================

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const NeonChatApp());

// ──────────────────────────────────────────────────────────────
// 1. APP ROOT
// ──────────────────────────────────────────────────────────────
class NeonChatApp extends StatelessWidget {
  const NeonChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0F14),
        fontFamily: 'SF Pro Display', // Falls back to system sans-serif
      ),
      home: const ChatScreen(),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 2. DATA MODELS
// ──────────────────────────────────────────────────────────────
enum MessageType { text, image, audio }

class ChatMessage {
  final String id;
  final String? text;
  final MessageType type;
  final bool isOutgoing;
  final String time;
  final bool isDelivered;

  const ChatMessage({
    required this.id,
    this.text,
    required this.type,
    required this.isOutgoing,
    required this.time,
    this.isDelivered = false,
  });
}

// ──────────────────────────────────────────────────────────────
// 3. SAMPLE DATA
// ──────────────────────────────────────────────────────────────
const _messages = [
  ChatMessage(
    id: '1',
    text: '👋 Hey! How are you?',
    type: MessageType.text,
    isOutgoing: false,
    time: '9:30 AM',
  ),
  ChatMessage(
    id: '2',
    text: 'I\'m good. You?',
    type: MessageType.text,
    isOutgoing: true,
    time: '9:31 AM',
    isDelivered: true,
  ),
  ChatMessage(
    id: '3',
    text: 'It seems we have a lot in common and have a lot interest in each other 😊',
    type: MessageType.text,
    isOutgoing: false,
    time: '9:32 AM',
  ),
  ChatMessage(
    id: '4',
    text: 'By the way, check out this artwork',
    type: MessageType.image,
    isOutgoing: false,
    time: '9:33 AM',
  ),
  ChatMessage(
    id: '5',
    type: MessageType.audio,
    isOutgoing: false,
    time: '9:34 AM',
  ),
  ChatMessage(
    id: '6',
    text: 'Good concepts! 🔥',
    type: MessageType.text,
    isOutgoing: true,
    time: '9:35 AM',
    isDelivered: true,
  ),
];

// ──────────────────────────────────────────────────────────────
// 4. THEME CONSTANTS
// ──────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF0D0F14);
  static const surfaceDark = Color(0xFF1A1D25);
  static const glassDark = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
  static const neonPurple = Color(0xFF7B61FF);
  static const neonBlue = Color(0xFF00C2FF);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8A8FA8);
  static const online = Color(0xFF00E676);

  static const outgoingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B61FF), Color(0xFF00C2FF)],
  );

  static const waveGradient = LinearGradient(
    colors: [Color(0xFF7B61FF), Color(0xFF00C2FF)],
  );
}

// ──────────────────────────────────────────────────────────────
// 5. MESH GRADIENT PAINTER (background waves)
// ──────────────────────────────────────────────────────────────
class MeshGradientPainter extends CustomPainter {
  final double animValue;

  const MeshGradientPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Ambient mesh blobs
    final blobs = [
      _Blob(
        center: Offset(size.width * 0.2 + math.sin(animValue) * 20,
            size.height * 0.15 + math.cos(animValue * 0.7) * 15),
        radius: size.width * 0.55,
        color: const Color(0x1A4A1FB8),
      ),
      _Blob(
        center: Offset(size.width * 0.85 + math.cos(animValue * 0.8) * 18,
            size.height * 0.08 + math.sin(animValue * 1.1) * 12),
        radius: size.width * 0.45,
        color: const Color(0x15003D8F),
      ),
      _Blob(
        center: Offset(size.width * 0.6 + math.sin(animValue * 1.3) * 15,
            size.height * 0.4 + math.cos(animValue * 0.9) * 20),
        radius: size.width * 0.5,
        color: const Color(0x0E6B3AC7),
      ),
    ];

    for (final blob in blobs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.color, blob.color.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: blob.center, radius: blob.radius));
      canvas.drawCircle(blob.center, blob.radius, paint);
    }

    // Fluid wave lines in header
    _drawWaveLine(canvas, size, 0.12, animValue, const Color(0x226B3AC7), 1.8);
    _drawWaveLine(canvas, size, 0.18, animValue + 0.5, const Color(0x1800C2FF), 1.2);
    _drawWaveLine(canvas, size, 0.24, animValue + 1.0, const Color(0x14A78BFF), 1.5);
  }

  void _drawWaveLine(Canvas canvas, Size size, double yFactor, double t,
      Color color, double amplitude) {
    final path = Path();
    final baseY = size.height * yFactor;
    path.moveTo(0, baseY);

    for (double x = 0; x <= size.width; x += 2) {
      final y = baseY +
          math.sin((x / size.width * math.pi * 3) + t) * amplitude * 18 +
          math.cos((x / size.width * math.pi * 2) + t * 0.7) * amplitude * 10;
      path.lineTo(x, y);
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MeshGradientPainter old) => old.animValue != animValue;
}

class _Blob {
  final Offset center;
  final double radius;
  final Color color;
  const _Blob({required this.center, required this.radius, required this.color});
}

// ──────────────────────────────────────────────────────────────
// 6. WAVEFORM PAINTER
// ──────────────────────────────────────────────────────────────
class WaveformPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final List<double> bars;

  const WaveformPainter({required this.progress, required this.bars});

  @override
  void paint(Canvas canvas, Size size) {
    final barW = (size.width - bars.length.toDouble()) / bars.length;
    final midY = size.height / 2;

    for (int i = 0; i < bars.length; i++) {
      final x = i * (barW + 1.0);
      final barH = bars[i] * size.height * 0.85;
      final isPlayed = i / bars.length < progress;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barW / 2, midY),
          width: barW.clamp(2, 4),
          height: barH.clamp(3, size.height),
        ),
        const Radius.circular(2),
      );

      final Paint paint = Paint()..style = PaintingStyle.fill;

      if (isPlayed) {
        paint.shader = AppColors.waveGradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        );
      } else {
        paint.color = Colors.white.withOpacity(0.25);
      }

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter old) =>
      old.progress != progress || old.bars != bars;
}

// ──────────────────────────────────────────────────────────────
// 7. GLASSMORPHIC HELPER WIDGET
// ──────────────────────────────────────────────────────────────
class GlassBox extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double blur;
  final Border? border;

  const GlassBox({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.color,
    this.blur = 15,
    this.border,
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
            color: color ?? AppColors.glassDark,
            borderRadius: br,
            border: border ??
                Border.all(
                  color: AppColors.glassBorder,
                  width: 0.5,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 8. CHAT SCREEN
// ──────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _typingController;
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  // Per-message animation controllers
  final List<AnimationController> _msgControllers = [];
  final List<Animation<double>> _msgFadeAnims = [];
  final List<Animation<Offset>> _msgSlideAnims = [];

  @override
  void initState() {
    super.initState();

    // Background animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Typing indicator bounce
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Stagger message animations
    for (int i = 0; i < _messages.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      );
      final fade = CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: Offset(_messages[i].isOutgoing ? 0.18 : -0.18, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic));

      _msgControllers.add(ctrl);
      _msgFadeAnims.add(fade);
      _msgSlideAnims.add(slide);

      Future.delayed(Duration(milliseconds: 80 + i * 90), () {
        if (mounted) ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _typingController.dispose();
    for (final c in _msgControllers) {
      c.dispose();
    }
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Animated mesh background ──────────────────────────
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => CustomPaint(
              painter: MeshGradientPainter(_bgController.value * math.pi * 2),
              child: const SizedBox.expand(),
            ),
          ),

          // ── Main column ───────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: _buildMessageList()),
                _buildInputBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return GlassBox(
      blur: 20,
      color: const Color(0x14FFFFFF),
      borderRadius: BorderRadius.zero,
      border: const Border(
        bottom: BorderSide(color: AppColors.glassBorder, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Back
          _IconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 8),

          // Avatar
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [AppColors.neonPurple, AppColors.neonBlue, AppColors.neonPurple],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonPurple.withOpacity(0.45),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF2A1F6E),
                  child: Icon(Icons.person_rounded,
                      color: Colors.white70, size: 22),
                ),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.online.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Daniel Garcia',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: AppColors.online,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action icons
          _IconBtn(icon: Icons.call_rounded, onTap: () {}),
          const SizedBox(width: 4),
          _IconBtn(icon: Icons.videocam_rounded, onTap: () {}),
          const SizedBox(width: 4),
          _IconBtn(icon: Icons.more_vert_rounded, onTap: () {}),
        ],
      ),
    );
  }

  // ── MESSAGE LIST ─────────────────────────────────────────────
  Widget _buildMessageList() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      children: [
        // Date pill
        Center(
          child: GlassBox(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            blur: 12,
            child: const Text(
              'Today',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Messages
        ..._messages.asMap().entries.map((e) {
          final i = e.key;
          final msg = e.value;
          return FadeTransition(
            opacity: _msgFadeAnims[i],
            child: SlideTransition(
              position: _msgSlideAnims[i],
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildBubble(msg),
              ),
            ),
          );
        }),

        // Typing indicator
        FadeTransition(
          opacity: _msgFadeAnims.isNotEmpty ? _msgFadeAnims.last : const AlwaysStoppedAnimation(1),
          child: _buildTypingIndicator(),
        ),
      ],
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    Widget content;

    if (msg.type == MessageType.audio) {
      content = _AudioBubble(isOutgoing: msg.isOutgoing, time: msg.time);
    } else if (msg.type == MessageType.image) {
      content = _ImageBubble(text: msg.text, time: msg.time);
    } else {
      content = _TextBubble(
          text: msg.text ?? '', isOutgoing: msg.isOutgoing, time: msg.time, isDelivered: msg.isDelivered);
    }

    return Align(
      alignment: msg.isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isOutgoing) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF2A1F6E),
              child: Icon(Icons.person_rounded, color: Colors.white54, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: content),
        ],
      ),
    );
  }

  // ── TYPING INDICATOR ─────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF2A1F6E),
            child: Icon(Icons.person_rounded, color: Colors.white54, size: 18),
          ),
          const SizedBox(width: 8),
          GlassBox(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(22),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
              topLeft: Radius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: AnimatedBuilder(
              animation: _typingController,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.25;
                  final t = (_typingController.value - delay).clamp(0.0, 1.0);
                  return Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    child: Transform.translate(
                      offset: Offset(0, -5 * math.sin(t * math.pi)),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.neonPurple.withOpacity(0.6 + 0.4 * t),
                              AppColors.neonBlue.withOpacity(0.6 + 0.4 * t),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── INPUT BAR ────────────────────────────────────────────────
  Widget _buildInputBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: GlassBox(
        borderRadius: BorderRadius.circular(36),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        color: const Color(0x1AFFFFFF),
        blur: 20,
        border: Border.all(
          color: AppColors.neonPurple.withOpacity(0.25),
          width: 0.8,
        ),
        child: Row(
          children: [
            // Add
            _GradientIconBtn(icon: Icons.add_rounded, onTap: () {}),
            const SizedBox(width: 4),
            // Emoji
            _GradientIconBtn(icon: Icons.sentiment_satisfied_alt_rounded, onTap: () {}),
            const SizedBox(width: 6),

            // Text field
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),

            const SizedBox(width: 6),
            // Attachment
            _GradientIconBtn(icon: Icons.attach_file_rounded, onTap: () {}),
            const SizedBox(width: 4),
            // Mic – filled gradient circle
            _MicButton(onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 9. BUBBLE WIDGETS
// ──────────────────────────────────────────────────────────────

// ── TEXT BUBBLE ───────────────────────────────────────────────
class _TextBubble extends StatelessWidget {
  final String text;
  final bool isOutgoing;
  final String time;
  final bool isDelivered;

  const _TextBubble({
    required this.text,
    required this.isOutgoing,
    required this.time,
    required this.isDelivered,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isOutgoing
        ? const BorderRadius.only(
            topLeft: Radius.circular(22),
            bottomLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
            topLeft: Radius.circular(4),
          );

    if (isOutgoing) {
      return Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: AppColors.outgoingGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPurple.withOpacity(0.40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: _bubbleContent(text, time, isDelivered, Colors.white),
      );
    }

    return GlassBox(
      borderRadius: radius,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      color: const Color(0x1AFFFFFF),
      blur: 15,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: _bubbleContent(text, time, false, AppColors.textSecondary),
      ),
    );
  }

  Widget _bubbleContent(
      String text, String time, bool delivered, Color timeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(
                color: timeColor,
                fontSize: 11,
              ),
            ),
            if (delivered) ...[
              const SizedBox(width: 4),
              const Icon(Icons.done_all_rounded,
                  size: 14, color: Colors.white70),
            ],
          ],
        ),
      ],
    );
  }
}

// ── IMAGE BUBBLE ─────────────────────────────────────────────
class _ImageBubble extends StatelessWidget {
  final String? text;
  final String time;

  const _ImageBubble({this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width * 0.72;
    return GlassBox(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(22),
        bottomLeft: Radius.circular(22),
        bottomRight: Radius.circular(22),
        topLeft: Radius.circular(4),
      ),
      padding: const EdgeInsets.all(10),
      color: const Color(0x1AFFFFFF),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (text != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  text!,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 15),
                ),
              ),
            // Artwork placeholder with gradient shimmer
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2A1060),
                      Color(0xFF7B61FF),
                      Color(0xFFE040FB),
                      Color(0xFF00C2FF),
                    ],
                    stops: [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative swirls
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ArtworkSwirls(),
                      ),
                    ),
                    // Silhouette icon
                    const Center(
                      child: Icon(
                        Icons.face_retouching_natural_rounded,
                        size: 72,
                        color: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                time,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkSwirls extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final cx = size.width * 0.5;
      final cy = size.height * 0.5;
      final r = 20.0 + i * 22.0;
      path.addOval(Rect.fromCenter(
          center: Offset(cx - 10, cy + 5), width: r * 2.2, height: r));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── AUDIO BUBBLE ─────────────────────────────────────────────
class _AudioBubble extends StatefulWidget {
  final bool isOutgoing;
  final String time;

  const _AudioBubble({required this.isOutgoing, required this.time});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  late AnimationController _playCtrl;
  double _progress = 0.0;

  // Deterministic "random" waveform
  final List<double> _bars = List.generate(32, (i) {
    final t = i / 32.0;
    return 0.2 + 0.7 * math.sin(t * math.pi * 4 + 0.5).abs() * (0.6 + 0.4 * math.cos(t * math.pi * 7).abs());
  });

  @override
  void initState() {
    super.initState();
    _playCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..addListener(() {
        setState(() => _progress = _playCtrl.value);
        if (_playCtrl.isCompleted) setState(() => _isPlaying = false);
      });
  }

  @override
  void dispose() {
    _playCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isPlaying = !_isPlaying);
    _isPlaying ? _playCtrl.forward() : _playCtrl.stop();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(22),
        bottomLeft: Radius.circular(22),
        bottomRight: Radius.circular(22),
        topLeft: Radius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: const Color(0x1AFFFFFF),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play button with glass
                GestureDetector(
                  onTap: _toggle,
                  child: GlassBox(
                    borderRadius: BorderRadius.circular(24),
                    color: AppColors.neonPurple.withOpacity(0.3),
                    blur: 8,
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Waveform
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: CustomPaint(
                      painter: WaveformPainter(
                        progress: _progress,
                        bars: _bars,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '0:45',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.time,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 10. REUSABLE ICON WIDGETS
// ──────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
    );
  }
}

class _GradientIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GradientIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.07),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MicButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.neonPurple, AppColors.neonBlue],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPurple.withOpacity(0.45),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}
