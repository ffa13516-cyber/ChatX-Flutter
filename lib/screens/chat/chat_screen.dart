import 'dart:ui';
import 'package:flutter/material.dart';
import 'models/message_model.dart';
import 'widgets/chat_input.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> messages = [
    Message(text: "Hi 👋 It's good, yours?", isMe: false),
    Message(text: "Good Concept!", isMe: true),
  ];

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔥 Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF020617),
                  Color(0xFF020617),
                ],
              ),
            ),
          ),

          /// 🔵 Glow كبير
          Positioned(
            top: -200,
            left: -150,
            child: _glow(400),
          ),

          SafeArea(
            child: Column(
              children: [
                _header(),

                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(message: messages[index]);
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 8),
                  child: TypingIndicator(),
                ),

                ChatInput(onSend: (_) {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 💣 الهيدر الجديد (المهم)
  Widget _header() {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          /// 🔵 الخلفية المنحنية
          Positioned.fill(
            child: ClipPath(
              clipper: HeaderClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.25),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ),
          ),

          /// 🔵 Glow فوق
          Positioned(
            top: -40,
            left: -40,
            child: _glow(200),
          ),

          /// 👤 المحتوى
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      NetworkImage("https://i.pravatar.cc/100"),
                ),
                SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daniel Garcia",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Online",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(Icons.call, color: Colors.white),
                SizedBox(width: 10),
                Icon(Icons.videocam, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔵 Glow
  Widget _glow(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity(0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 200,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}

/// 🔥 الشكل المنحني
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 30);

    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 30,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
