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
    Message(text: "Hi 👋 It's god. Yours", isMe: false, status: MessageStatus.seen),
    Message(
      text: "It seem we have a lot common and have a lot interest in each other 😊",
      isMe: false,
      status: MessageStatus.seen,
    ),
    Message(
      text: "",
      isMe: false,
      type: MessageType.image,
      imageUrl: "https://picsum.photos/seed/chat/400/300",
    ),
    Message(text: "", isMe: false, type: MessageType.voice),
    Message(text: "Good Concepts!", isMe: true, status: MessageStatus.seen),
  ];

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// ── 1. Pure Black Base ──
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),

          /// ── 1. ONE Glow - Top Center فقط ──
          Positioned(
            top: -150,
            left: size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E6FF).withOpacity(0.50),
                    const Color(0xFF0099BB).withOpacity(0.25),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E6FF).withOpacity(0.25),
                    blurRadius: 180,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          /// ── CONTENT ──
          SafeArea(
            child: Column(
              children: [
                _header(),

                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    /// ✅ 3. horizontal padding 20
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ChatBubble(message: messages[index]),
                          /// ✅ 3. spacing 18
                          const SizedBox(height: 18),
                        ],
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _typingBubble(),
                  ),
                ),

                ChatInput(onSend: (text) {
                  setState(() {
                    messages.add(Message(
                      text: text,
                      isMe: true,
                      status: MessageStatus.sent,
                    ));
                  });
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_controller.hasClients) {
                      _controller.animateTo(
                        _controller.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typingBubble() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.06),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
          ),
          child: const TypingIndicator(),
        ),
      ),
    );
  }

  Widget _header() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          decoration: BoxDecoration(
            /// ✅ هيدر شفاف بدون teal/green
            color: Colors.white.withOpacity(0.04),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
          ),
          child: Row(
            children: [
              /// ✅ 6. Avatar مع radial glow بدل الـ ring
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00E6FF).withOpacity(0.35),
                          const Color(0xFF8B5CF6).withOpacity(0.20),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        NetworkImage("https://i.pravatar.cc/150?img=8"),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Daniel Garcia",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Online",
                    style: TextStyle(
                      color: Color(0xFF22C55E),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              _headerIcon(Icons.videocam_outlined),
              const SizedBox(width: 10),
              _headerIcon(Icons.call_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }
}
