import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _avatar(),
            const SizedBox(width: 8),
          ],

          _bubble(isMe),

          if (isMe) ...[
            const SizedBox(width: 8),
            _avatar(),
          ],
        ],
      ),
    );
  }

  Widget _bubble(bool isMe) {
    final time =
        "${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}";

    return Container(
      constraints: const BoxConstraints(maxWidth: 270),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: isMe
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.45),
                        const Color(0xFF1E40AF).withOpacity(0.35),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ],
                    ),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                /// 💬 النص
                Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 6),

                /// ⏱️ الوقت + ✓✓
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white38,
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

  Widget _statusIcon() {
    IconData icon;
    Color color;

    switch (message.status) {
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
