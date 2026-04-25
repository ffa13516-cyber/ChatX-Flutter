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

          Stack(
            clipBehavior: Clip.none,
            children: [
              _bubble(isMe),

              /// Tail (احترافي)
              Positioned(
                bottom: 10,
                left: isMe ? null : -18,
                right: isMe ? -18 : null,
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

  /// 💎 البابل الاحترافي
  Widget _bubble(bool isMe) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 270),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),

        /// 🔥 shadow (depth)
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

              /// 🔵 gradient (الفرق الحقيقي)
              gradient: isMe
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.45),
                        const Color(0xFF1E40AF).withOpacity(0.35),
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

              /// 🧊 border خفيف
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: _content(),
          ),
        ),
      ),
    );
  }

  /// 🧠 المحتوى
  Widget _content() {
    switch (message.type) {
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(
            message.imageUrl ?? '',
            height: 130,
            width: 190,
            fit: BoxFit.cover,
          ),
        );

      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white),
            const SizedBox(width: 10),

            /// waveform احترافي
            Row(
              children: List.generate(
                20,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 3,
                  height: (i % 5 + 1) * 5,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF60A5FA),
                        Color(0xFF3B82F6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),
            const Text(
              "2:45",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        );

      default:
        return Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4, // 👈 spacing احترافي
          ),
        );
    }
  }

  /// 👤 avatar
  Widget _avatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
          ),
        ],
      ),
      child: const CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage("https://i.pravatar.cc/100"),
      ),
    );
  }

  /// 🔥 Tail احترافي (نقط + fade)
  Widget _tail(bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(7),
        const SizedBox(width: 3),
        _dot(5),
        const SizedBox(width: 3),
        _dot(3),
      ],
    );
  }

  Widget _dot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        shape: BoxShape.circle,
      ),
    );
  }
}
