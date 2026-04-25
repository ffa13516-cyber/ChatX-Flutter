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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _avatar(),
            const SizedBox(width: 6),
          ],

          /// 🔥 Bubble + Tail
          Stack(
            clipBehavior: Clip.none,
            children: [
              _bubble(isMe),

              /// 🔹 Tail (3 نقط)
              Positioned(
                bottom: 6,
                left: isMe ? null : -14,
                right: isMe ? -14 : null,
                child: _tail(isMe),
              ),
            ],
          ),

          if (isMe) ...[
            const SizedBox(width: 6),
            _avatar(),
          ],
        ],
      ),
    );
  }

  /// 🧊 Bubble
  Widget _bubble(bool isMe) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 260),
          decoration: BoxDecoration(
            color: isMe
                ? const Color(0xFF3B82F6).withOpacity(0.25)
                : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  /// 🧠 محتوى الرسالة
  Widget _buildContent() {
    switch (message.type) {
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            message.imageUrl ?? '',
            height: 120,
            width: 180,
            fit: BoxFit.cover,
          ),
        );

      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white),
            const SizedBox(width: 8),

            /// 🔥 waveform أحسن
            Row(
              children: List.generate(
                16,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 3,
                  height: (i % 3 + 1) * 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),
            const Text(
              "2:45",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        );

      case MessageType.text:
      default:
        return Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        );
    }
  }

  /// 👤 Avatar (صورة حقيقية بدل أيقونة)
  Widget _avatar() {
    return const CircleAvatar(
      radius: 18,
      backgroundImage:
          NetworkImage("https://i.pravatar.cc/100"), // صورة عشوائية
    );
  }

  /// 🔥 Tail (النقط)
  Widget _tail(bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(6),
        const SizedBox(width: 2),
        _dot(4),
        const SizedBox(width: 2),
        _dot(3),
      ],
    );
  }

  Widget _dot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
