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
          /// 💣 BACKGROUND (احترافي)
          Stack(
            children: [
              /// Base gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF01030A),
                      Color(0xFF020617),
                      Color(0xFF030A1A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              /// Glow كبير (يمين فوق)
              Positioned(
                top: -250,
                right: -150,
                child: _glow(450),
              ),

              /// Glow تحت
              Positioned(
                bottom: -200,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.04),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 180,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),

              /// الموجة
              Positioned.fill(
                child: ClipPath(
                  clipper: BackgroundWaveClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.15),
                          Colors.transparent,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

  /// 💣 HEADER
  Widget _header() {
    return SizedBox(
      height: 130,
      child: Stack(
        children: [
          /// Glass layer
          Positioned.fill(
            child: ClipPath(
              clipper: HeaderClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
          ),

          /// Light layer (يمين)
          Positioned.fill(
            child: ClipPath(
              clipper: HeaderClipper(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B82F6).withOpacity(0.25),
                      Colors.transparent,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          ),

          /// Glow
          Positioned(
            top: -60,
            right: -60,
            child: _glow(250),
          ),

          /// Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.6),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        NetworkImage("https://i.pravatar.cc/100"),
                  ),
                ),

                const SizedBox(width: 12),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
                        color: Color(0xFF22C55E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                const Icon(Icons.call, color: Colors.white),
                SizedBox(width: 12),
                const Icon(Icons.videocam, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Glow
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

/// Header curve
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Background wave
class BackgroundWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, size.height * 0.25);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.35,
      size.width,
      size.height * 0.25,
    );

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
