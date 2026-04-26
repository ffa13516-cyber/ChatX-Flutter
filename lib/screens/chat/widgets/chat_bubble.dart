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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _avatar(isMe),
            const SizedBox(width: 8),
          ],

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

          if (isMe) ...[
            const SizedBox(width: 8),
            _avatar(isMe),
          ],
        ],
      ),
    );
  }

  Widget _bubble(bool isMe) {
    final message = widget.message;
    final time =
        "${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}";

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(30),
      topRight: const Radius.circular(30),
      bottomLeft: Radius.circular(isMe ? 30 : 8),
      bottomRight: Radius.circular(isMe ? 8 : 30),
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: 265),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: isMe
                ? const Color(0xFF0EA5E9).withOpacity(0.20)
                : Colors.black.withOpacity(0.20),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          /// ✅ High blur للـ frosted glass الحقيقي
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            padding: message.type == MessageType.image
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: isMe
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF1E40AF).withOpacity(0.50),
                        const Color(0xFF1E3A8A).withOpacity(0.35),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.09),
                        Colors.white.withOpacity(0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              /// ✅ White border 0.05 opacity
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1.0,
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
                      const SizedBox(height: 5),
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
        fontSize: 14.5,
        height: 1.45,
        letterSpacing: 0.1,
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
            height: 170,
            width: 240,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 8,
          right: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Text(
                  time,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 10),
                ),
              ),
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
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          height: 32,
          width: 110,
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (_, __) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(20, (i) {
                  final phase = (_waveController.value + i * 0.06) % 1.0;
                  final h = isPlaying
                      ? 4 + (phase < 0.5 ? phase : 1 - phase) * 24
                      : _staticHeight(i);
                  final t = i / 19;
                  final color = Color.lerp(
                    const Color(0xFF38BDF8),
                    const Color(0xFF818CF8),
                    t,
                  )!.withOpacity(isPlaying ? 0.95 : 0.60);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 2.5,
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
          style: TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  double _staticHeight(int i) {
    final h = [6, 12, 18, 8, 22, 14, 20, 6, 16, 24,
                10, 20, 8, 18, 6, 22, 12, 8, 18, 10];
    return h[i % h.length].toDouble();
  }

  Widget _timeRow(String time, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            color: Colors.white.withOpacity(0.30),
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
        color = const Color(0xFF38BDF8);
        break;
    }
    return Icon(icon, size: 13, color: color);
  }

  Widget _avatar(bool isMe) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isMe
              ? [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)]
              : [const Color(0xFFEC4899), const Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isMe
                ? const Color(0xFF3B82F6).withOpacity(0.45)
                : const Color(0xFF8B5CF6).withOpacity(0.45),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF050505),
        ),
        child: CircleAvatar(
          radius: 17,
          backgroundImage: NetworkImage(
            isMe
                ? "https://i.pravatar.cc/150?img=12"
                : "https://i.pravatar.cc/150?img=8",
          ),
        ),
      ),
    );
  }
}
