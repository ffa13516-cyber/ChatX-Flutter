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
    Message("عامل ايه؟", false),
    Message("تمام الحمدلله 😎", true),
    Message("الدنيا تمام", true),
    Message("حلو 🔥", false),
    Message("عايزين نشتغل على التصميم", false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
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
              gradient: message.isMe
                  ? const LinearGradient(
                      colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                    )
                  : null,
              color: message.isMe
                  ? null
                  : Colors.grey.shade800,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(
                    message.isMe ? 18 : (isLast ? 18 : 6)),
                bottomRight: Radius.circular(
                    message.isMe ? (isLast ? 18 : 6) : 18),
              ),
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
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          const Icon(Icons.add, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.mic, color: Colors.purple.shade300),
        ],
      ),
    );
  }
}
