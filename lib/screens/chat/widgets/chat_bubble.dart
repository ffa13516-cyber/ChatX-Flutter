import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// 🔹 Main Bubble
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 250),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? Colors.blue.withOpacity(0.25)
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: _buildContent(),
                ),
              ),
            ),

            /// 🔹 Floating Avatar
            Positioned(
              top: -10,
              left: message.isMe ? null : -10,
              right: message.isMe ? -10 : null,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 14, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Content حسب نوع الرسالة
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

            /// Fake waveform
            Row(
              children: List.generate(
                12,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 3,
                  height: (index % 2 == 0) ? 12 : 20,
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
}
