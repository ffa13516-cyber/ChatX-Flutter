import 'dart:ui';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final messages = [
    {"text": "Hey! 👋", "isMe": false},
    {"text": "How are you?", "isMe": false},
    {"text": "I'm good. You?", "isMe": true},
    {"text": "It seems we have a lot in common", "isMe": false},
    {"text": "Good concepts! 🔥", "isMe": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF060A13), Color(0xFF0D1B2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const _Header(),
              Expanded(child: _ChatList(messages: messages)),
              const _InputField(),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔝 HEADER
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(radius: 20),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Daniel Garcia",
                  style: TextStyle(color: Colors.white)),
              Text("Online",
                  style: TextStyle(color: Colors.green, fontSize: 12)),
            ],
          ),
          const Spacer(),
          _icon(Icons.call),
          const SizedBox(width: 10),
          _icon(Icons.videocam),
        ],
      ),
    );
  }

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

// 💬 CHAT LIST
class _ChatList extends StatelessWidget {
  final List messages;

  const _ChatList({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];

        final isFirst =
            index == 0 || messages[index - 1]["isMe"] != msg["isMe"];

        return Row(
          mainAxisAlignment:
              msg["isMe"] ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!msg["isMe"] && isFirst)
              const CircleAvatar(radius: 14),

            if (!msg["isMe"] && isFirst)
              const SizedBox(width: 6),

            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: msg["isMe"]
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF6A5AE0),
                            Color(0xFFB44CFF),
                          ],
                        )
                      : null,
                  color: msg["isMe"]
                      ? null
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: msg["isMe"]
                      ? [
                          BoxShadow(
                            color:
                                Colors.purple.withOpacity(0.4),
                            blurRadius: 10,
                          )
                        ]
                      : [],
                ),
                child: Text(
                  msg["text"],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ✍️ INPUT
class _InputField extends StatelessWidget {
  const _InputField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(Icons.add, color: Colors.white54),
                const SizedBox(width: 8),
                const Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Message...",
                      hintStyle:
                          TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF7F00FF),
                        Color(0xFFE100FF),
                      ],
                    ),
                  ),
                  child: const Icon(Icons.mic,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
