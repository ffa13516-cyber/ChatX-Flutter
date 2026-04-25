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

          Stack(
            clipBehavior: Clip.none,
            children: [
              _bubble(isMe),

              Positioned(
                bottom: 6,
                left: isMe ? null : -14,
                right: isMe ? -14 : null,
                child: _tail(),
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

  Widget _bubble(bool isMe) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 260),
          decoration: BoxDecoration(
            gradient: isMe
                ? LinearGradient(
                    colors: [
                      const Color(0xFF3B82F6).withOpacity(0.35),
                      const Color(0xFF1E40AF).withOpacity(0.25),
                    ],
                  )
                : null,
            color: isMe ? null : Colors.white.withOpacity(0.05),
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

            /// 🔥 Waveform Gradient
            Row(
              children: List.generate(
                18,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 3,
                  height: (i % 4 + 1) * 5,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF60A5FA),
                        Color(0xFF3B82F6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
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

  Widget _avatar() {
    return const CircleAvatar(
      radius: 18,
      backgroundImage: NetworkImage("https://i.pravatar.cc/100"),
    );
  }

  Widget _tail() {
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
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
    );
  }
}
