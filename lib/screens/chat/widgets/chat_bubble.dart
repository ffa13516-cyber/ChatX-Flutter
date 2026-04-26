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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _avatar(),
            const SizedBox(width: 8),
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
                  scale: isPressed ? 0.97 : 1,
                  duration: const Duration(milliseconds: 100),
                  child: _bubble(isMe),
                ),
              ),

              Positioned(
                bottom: 8,
                left: isMe ? null : -10,
                right: isMe ? -10 : null,
                child: _tail(isMe),
              ),
            ],
          ),

          if (isMe) ...[
            const SizedBox(width: 8),
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
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              /// 🎯 Glass gradient مضبوط
              gradient: isMe
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.25),
                        const Color(0xFF1E40AF).withOpacity(0.18),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.015),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

              border: Border.all(
                color: Colors.white.withOpacity(0.05),
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

                const SizedBox(height: 4),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.25),
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
    return Text(
      widget.message.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.35,
      ),
    );
  }

  Widget _image() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        widget.message.imageUrl!,
        height: 130,
        width: 190,
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
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 8),

        Expanded(
          child: SizedBox(
            height: 26,
            child: Row(
              children: List.generate(
                18,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 2.5,
                  height: (index % 5 + 1) * 4.0,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
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
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// ✨ dots شبه Dribbble بالظبط
  Widget _tail(bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(5, isMe),
        const SizedBox(width: 2),
        _dot(3.5, isMe),
        const SizedBox(width: 2),
        _dot(2.5, isMe),
      ],
    );
  }

  Widget _dot(double size, bool isMe) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isMe
            ? Colors.blue.withOpacity(0.5)
            : Colors.white.withOpacity(0.4),
      ),
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

  Widget _avatar() {
    return const CircleAvatar(
      radius: 16,
      backgroundImage: NetworkImage("https://i.pravatar.cc/100"),
    );
  }
}
