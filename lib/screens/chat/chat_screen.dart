import 'dart:ui';
import 'package:flutter/material.dart';

class Message {
  final String text;
  final bool isMe;

  Message(this.text, this.isMe);
}

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final List<Message> messages = [
    Message("Hey! 👋", false),
    Message("How are you?", false),
    Message("I'm good. You?", true),
    Message("It seems we have a lot in common", false),
    Message("Good concepts! 🔥", true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(child: _ChatList(messages: messages)),
            const _InputField(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          CircleAvatar(radius: 20),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Daniel Garcia",
                  style: TextStyle(color: Colors.white)),
              Text("Online",
                  style: TextStyle(color: Colors.green, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final List<Message> messages;

  const _ChatList({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];

        final isFirst =
            index == 0 || messages[index - 1].isMe != msg.isMe;

        final isLast = index == messages.length - 1 ||
            messages[index + 1].isMe != msg.isMe;

        return _MessageBubble(
          message: msg,
          isFirst: isFirst,
          isLast: isLast,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isFirst;
  final bool isLast;

  const _MessageBubble({
    required this.message,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!message.isMe && isFirst)
          const CircleAvatar(radius: 14),

        if (!message.isMe && isFirst)
          const SizedBox(width: 6),

        Flexible(
          child: Container(
            margin: EdgeInsets.only(
              top: isFirst ? 10 : 2,
              bottom: isLast ? 10 : 2,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ✨ Gradient للرسائل بتاعتك
              gradient: message.isMe
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF6A5AE0),
                        Color(0xFFB44CFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,

              // 🧊 Glass effect بسيط للرسائل التانية
              color: message.isMe
                  ? null
                  : Colors.white.withOpacity(0.06),

              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(
                    message.isMe ? 20 : (isLast ? 20 : 6)),
                bottomRight: Radius.circular(
                    message.isMe ? (isLast ? 20 : 6) : 20),
              ),

              // 🔥 Glow
              boxShadow: message.isMe
                  ? [
                      BoxShadow(
                        color:
                            const Color(0xFF7F00FF).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              message.text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_emotions_outlined,
                    color: Colors.white54),
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
                const Icon(Icons.attach_file,
                    color: Colors.white54),
                const SizedBox(width: 8),
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
