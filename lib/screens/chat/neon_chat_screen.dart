// ============================================================
//  Chat UI matching the provided screenshot
//  Flutter (Null-safe) – Single file
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const MyChatApp());

class MyChatApp extends StatelessWidget {
  const MyChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0F14),
        fontFamily: 'SF Pro Display', // falls back to system sans-serif
      ),
      home: const ChatScreen(),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Data Models
// ──────────────────────────────────────────────────────────────
enum MessageType { text, audio }

class ChatMessage {
  final String id;
  final String? text;
  final MessageType type;
  final bool isOutgoing;
  final String time;
  final String? audioDuration; // e.g., "2:45"

  const ChatMessage({
    required this.id,
    this.text,
    required this.type,
    required this.isOutgoing,
    required this.time,
    this.audioDuration,
  });
}

// ──────────────────────────────────────────────────────────────
//  Sample data – exactly as in your screenshot
// ──────────────────────────────────────────────────────────────
const _messages = [
  ChatMessage(
    id: '1',
    text: 'He ❤️ It\'s god. Yours',
    type: MessageType.text,
    isOutgoing: false,
    time: '9:30 AM',
  ),
  ChatMessage(
    id: '2',
    text: 'It seem we have a lot common and have a lot interest in each other 😍',
    type: MessageType.text,
    isOutgoing: false,
    time: '9:32 AM',
  ),
  ChatMessage(
    id: '3',
    type: MessageType.audio,
    isOutgoing: false,
    time: '9:34 AM',
    audioDuration: '2:45',
  ),
  ChatMessage(
    id: '4',
    text: 'Good Concepts!',
    type: MessageType.text,
    isOutgoing: true,
    time: '9:35 AM',
  ),
];

// ──────────────────────────────────────────────────────────────
//  Theme Constants
// ──────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF0D0F14);
  static const surfaceDark = Color(0xFF1A1D25);
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
}

// ──────────────────────────────────────────────────────────────
//  Chat Screen
// ──────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  late final AnimationController _typingController;
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

  // Per-message slide animations (optional, kept simple)
  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _typingController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildMessageList()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  App Bar
  // ────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0x14FFFFFF),
        border: Border(bottom: BorderSide(color: Color(0x33FFFFFF), width: 0.5)),
      ),
      child: Row(
        children: [
          _IconBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () {}),
          const SizedBox(width: 8),

          // Avatar with online dot
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
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
                child: const Icon(Icons.person_rounded, color: Colors.white70, size: 22),
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
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Name and status
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

          // Action buttons
          _IconBtn(icon: Icons.call_rounded, onTap: () {}),
          const SizedBox(width: 4),
          _IconBtn(icon: Icons.videocam_rounded, onTap: () {}),
          const SizedBox(width: 4),
          _IconBtn(icon: Icons.more_vert_rounded, onTap: () {}),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  Message List
  // ────────────────────────────────────────────────────────────
  Widget _buildMessageList() {
    // Determine which messages need avatar (first of consecutive incoming from same sender)
    bool? previousIncoming = null;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      children: [
        // Date pill
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
            ),
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

        // Messages with avatar logic
        ..._messages.asMap().entries.map((e) {
          final i = e.key;
          final msg = e.value;

          // Determine if this message should show the avatar
          bool showAvatar = false;
          if (!msg.isOutgoing) {
            // Show avatar only if:
            // - It's the first incoming message
            // - OR the previous message was outgoing (different sender)
            if (i == 0 || _messages[i - 1].isOutgoing) {
              showAvatar = true;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildBubble(msg, showAvatar: showAvatar),
          );
        }),

        // Typing indicator
        _buildTypingIndicator(),
      ],
    );
  }

  Widget _buildBubble(ChatMessage msg, {required bool showAvatar}) {
    Widget content;

    switch (msg.type) {
      case MessageType.audio:
        content = _AudioBubble(time: msg.time, duration: msg.audioDuration ?? '');
        break;
      case MessageType.text:
        content = _TextBubble(
          text: msg.text ?? '',
          isOutgoing: msg.isOutgoing,
          time: msg.time,
        );
        break;
    }

    return Align(
      alignment: msg.isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isOutgoing) ...[
            // Only display avatar if showAvatar is true; otherwise keep padding for alignment
            if (showAvatar) ...[
              const CircleAvatar(
                radius: 16, // 32px total
                backgroundColor: Color(0xFF2A1F6E),
                child: Icon(Icons.person_rounded, color: Colors.white54, size: 18),
              ),
              const SizedBox(width: 8),
            ] else ...[
              // reserve same space so that text stays aligned
              const SizedBox(width: 40), // 32 (avatar) + 8 (gap)
            ],
          ],
          Flexible(child: content),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                  topLeft: Radius.circular(4),
                ),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
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
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  Input Bar
  // ────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: AppColors.neonPurple.withOpacity(0.25),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            // Add button
            _GradientIconBtn(icon: Icons.add_rounded, onTap: () {}),
            const SizedBox(width: 4),
            // Emoji
            _GradientIconBtn(icon: Icons.sentiment_satisfied_alt_rounded, onTap: () {}),
            const SizedBox(width: 6),

            // Text field
            const Expanded(
              child: TextField(
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
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
            // Mic button – solid gradient
            _MicButton(onTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  Bubble Widgets (Text & Audio)
// ──────────────────────────────────────────────────────────────

class _TextBubble extends StatelessWidget {
  final String text;
  final bool isOutgoing;
  final String time;

  const _TextBubble({
    required this.text,
    required this.isOutgoing,
    required this.time,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      );
    }

    // Incoming bubble – glass style
    return Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72),
      decoration: BoxDecoration(
        borderRadius: radius,
        color: const Color(0x1AFFFFFF),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              time,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioBubble extends StatefulWidget {
  final String time;
  final String duration; // e.g., "2:45"

  const _AudioBubble({required this.time, required this.duration});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  late AnimationController _playCtrl;
  double _progress = 0.0;

  // Simple waveform bars
  final List<double> _bars = List.generate(32, (i) {
    final t = i / 32.0;
    return 0.2 + 0.7 * math.sin(t * math.pi * 4 + 0.5).abs() * (0.6 + 0.4 * math.cos(t * math.pi * 7).abs());
  });

  @override
  void initState() {
    super.initState();
    _playCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // short for demo
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
    return Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
          topLeft: Radius.circular(4),
        ),
        color: const Color(0x1AFFFFFF),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play/Pause button
              GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonPurple.withOpacity(0.3),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
                    painter: _WaveformPainter(progress: _progress, bars: _bars),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.duration, // e.g., "2:45"
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.time,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final List<double> bars;

  _WaveformPainter({required this.progress, required this.bars});

  @override
  void paint(Canvas canvas, Size size) {
    final barW = (size.width - bars.length) / bars.length;
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

      final Paint paint = Paint();
      if (isPlayed) {
        paint.shader = const LinearGradient(
          colors: [AppColors.neonPurple, AppColors.neonBlue],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      } else {
        paint.color = Colors.white.withOpacity(0.25);
      }
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress || old.bars != bars;
}

// ──────────────────────────────────────────────────────────────
//  Reusable Icon Buttons
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
