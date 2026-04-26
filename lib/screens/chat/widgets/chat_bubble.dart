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
      duration: const Duration(milliseconds: 900),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _avatar(isMe),
            const SizedBox(width: 10),
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
            const SizedBox(width: 10),
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

    return Container(
      constraints: const BoxConstraints(maxWidth: 270),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(22),
          topRight: const Radius.circular(22),
          bottomLeft: Radius.circular(isMe ? 22 : 6),
          bottomRight: Radius.circular(isMe ? 6 : 22),
        ),
        boxShadow: [
          BoxShadow(
            color: isMe
                ? const Color(0xFF3B82F6).withOpacity(0.25)
                : Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(22),
          topRight: const Radius.circular(22),
          bottomLeft: Radius.circular(isMe ? 22 : 6),
          bottomRight: Radius.circular(isMe ? 6 : 22),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isMe
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.35),
                        const Color(0xFF1E40AF).withOpacity(0.25),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: Border.all(
                color: isMe
                    ? Colors.blue.withOpacity(0.15)
                    : Colors.white.withOpacity(0.07),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.type == MessageType.image)
                  _image()
                else if (message.type == MessageType.voice)
                  _voice()
                else
                  _text(),

                const SizedBox(height: 5),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 10,
                      ),
                    ),
                    if (message.isMe) ...[
                      const SizedBox(width: 4),
                      _statusIcon(),
                    ],
                  ],
                ),
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
        height: 1.4,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _image() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        widget.message.imageUrl!,
        height: 140,
        width: 200,
        fit: BoxFit.cover,
      ),
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
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),

        /// Animated Waveform
        SizedBox(
          height: 28,
          width: 100,
          child: AnimatedBuilder(
            animation: _waveController,
            builder: (_, __) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(16, (i) {
                  final phase = (_waveController.value + i * 0.07) % 1.0;
                  final height = isPlaying
                      ? 4 + (phase < 0.5 ? phase : 1 - phase) * 20
                      : (i % 4 + 1) * 4.0;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.2),
                    width: 2.5,
                    height: height,
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? Colors.white.withOpacity(0.85)
                          : Colors.white.withOpacity(0.4),
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
          style: TextStyle(color: Colors.white60, fontSize: 10),
        ),
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
        color = const Color(0xFF60A5FA);
        break;
    }

    return Icon(icon, size: 13, color: color);
  }

  Widget _avatar(bool isMe) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isMe
                ? Colors.blue.withOpacity(0.5)
                : Colors.purpleAccent.withOpacity(0.4),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isMe
                    ? [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)]
                    : [const Color(0xFFEC4899), const Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
