import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_model.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  bool isPressed = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;

    return Row(
      mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTapDown: (_) {
            setState(() => isPressed = true);
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          child: AnimatedScale(
            scale: isPressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 100),
            child: _bubble(isMe),
          ),
        ),
      ],
    );
  }

  Widget _bubble(bool isMe) {
    final message = widget.message;
    final time =
        "${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}";

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(26),
      topRight: const Radius.circular(26),
      bottomLeft: Radius.circular(isMe ? 26 : 10),
      bottomRight: Radius.circular(isMe ? 10 : 26),
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          /// shadow عادي
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),

          /// ✅ glow للرسالة بتاعتك
          if (isMe)
            BoxShadow(
              color: const Color(0xFF00E6FF).withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: -2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: message.type == MessageType.image
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: isMe
                  ? const Color(0xFF0E2230)
                  : const Color(0xFF0A0A0A),

              /// ✅ border المعدل
              border: Border.all(
                color: isMe
                    ? const Color(0xFF00E6FF).withOpacity(0.25)
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            child: message.type == MessageType.image
                ? _imageWithTime(time, radius)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (message.type == MessageType.voice)
                        _voice()
                      else
                        _text(),
                      const SizedBox(height: 4),
                      _timeRow(time, isMe),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _text() {
    return Text(
      widget.message.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.4,
      ),
    );
  }

  Widget _imageWithTime(String time, BorderRadius radius) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: radius,
          child: Image.network(
            widget.message.imageUrl!,
            height: 160,
            width: 240,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 8,
          right: 10,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _voice() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => isPlaying = !isPlaying),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          height: 28,
          width: 100,
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (_, __) {
              return Row(
                children: List.generate(20, (i) {
                  final phase =
                      (_waveController.value + i * 0.06) % 1.0;

                  final h = isPlaying
                      ? 4 + (phase < 0.5 ? phase : 1 - phase) * 20
                      : _staticHeight(i);

                  final t = i / 19;

                  final color = Color.lerp(
                    const Color(0xFF00E6FF),
                    const Color(0xFF3B82F6),
                    t,
                  )!.withOpacity(isPlaying ? 1.0 : 0.7);

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 1),
                    width: 2.3,
                    height: h,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
        ),

        const SizedBox(width: 8),

        const Text(
          "2:45",
          style: TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  double _staticHeight(int i) {
    final h = [
      6, 12, 18, 8, 22,
      14, 20, 6, 16, 24,
      10, 20, 8, 18, 6,
      22, 12, 8, 18, 10
    ];
    return h[i % h.length].toDouble();
  }

  Widget _timeRow(String time, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 10,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          _statusIcon(),
        ],
      ],
    );
  }

  Widget _statusIcon() {
    IconData icon;
    Color color;

    switch (widget.message.status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.white24;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white24;
        break;
      case MessageStatus.seen:
        icon = Icons.done_all;
        color = const Color(0xFF00E6FF);
        break;
    }

    return Icon(icon, size: 13, color: color);
  }
}
