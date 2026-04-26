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

class _ChatBubbleState extends State<ChatBubble> {
  bool isPlaying = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _avatar(),
            const SizedBox(width: 10),
          ],

          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTapDown: (_) {
                  setState(() => isPressed = true);
                  HapticFeedback.lightImpact();
                },
                onTapUp: (_) => setState(() => isPressed = false),
                onTapCancel: () => setState(() => isPressed = false),
                child: AnimatedScale(
                  scale: isPressed ? 0.96 : 1,
                  duration: const Duration(milliseconds: 120),
                  child: _bubble(isMe),
                ),
              ),

              /// 💣 tail متظبط وناعم
              Positioned(
                bottom: 10,
                left: isMe ? null : -14,
                right: isMe ? -14 : null,
                child: _tail(isMe),
              ),
            ],
          ),

          if (isMe) ...[
            const SizedBox(width: 10),
            _avatar(),
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
        borderRadius: BorderRadius.circular(26),

        /// 🔥 shadow أنعم
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),

              /// 💣 gradient أنعم (أقرب للتصميم)
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
                        Colors.white.withOpacity(0.07),
                        Colors.white.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

              /// 🔥 border أخف
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                /// content
                if (message.type == MessageType.image)
                  _image()
                else if (message.type == MessageType.voice)
                  _voice()
                else
                  _text(),

                const SizedBox(height: 6),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (message.isMe) _statusIcon(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        widget.message.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _image() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
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
      children: [
        GestureDetector(
          onTap: () {
            setState(() => isPlaying = !isPlaying);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),

        /// 💣 wave أنعم
        Expanded(
          child: SizedBox(
            height: 30,
            child: Row(
              children: List.generate(
                22,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 3,
                  height: (index % 6 + 1) * 4.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),
        const Text(
          "0:12",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// 💣 tail احترافي (gradient + شفافية)
  Widget _tail(bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(6, isMe),
        const SizedBox(width: 3),
        _dot(4.5, isMe),
        const SizedBox(width: 3),
        _dot(3, isMe),
      ],
    );
  }

  Widget _dot(double size, bool isMe) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isMe
              ? [
                  Colors.blue.withOpacity(0.7),
                  Colors.blue.withOpacity(0.2),
                ]
              : [
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.2),
                ],
        ),
      ),
    );
  }

  Widget _statusIcon() {
    IconData icon;
    Color color;

    switch (widget.message.status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.white38;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white38;
        break;
      case MessageStatus.seen:
        icon = Icons.done_all;
        color = const Color(0xFF60A5FA);
        break;
    }

    return Icon(icon, size: 14, color: color);
  }

  Widget _avatar() {
    return const CircleAvatar(
      radius: 20,
      backgroundImage: NetworkImage("https://i.pravatar.cc/100"),
    );
  }
}
