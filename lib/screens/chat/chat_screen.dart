import 'dart:ui';
import 'package:flutter/material.dart';
import 'models/message_model.dart';
import 'widgets/chat_input.dart';
import 'widgets/chat_bubble.dart';

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

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(Message(text: text, isMe: true));
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

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
                  Color(0xFF01030A),
                  Color(0xFF020617),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🔵 Glow
          Positioned(
            top: -120,
            left: -120,
            child: _glow(260),
          ),

          SafeArea(
            child: Column(
              children: [
                /// 💎 HEADER PREMIUM
                _header(),

                /// 💬 Messages
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      return AnimatedSlide(
                        offset: Offset(msg.isMe ? 0.3 : -0.3, 0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          opacity: 1,
                          duration: const Duration(milliseconds: 300),
                          child: ChatBubble(message: msg),
                        ),
                      );
                    },
                  ),
                ),

                /// Input
                ChatInput(onSend: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 💎 HEADER
  Widget _header() {
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          child: Row(
            children: [
              /// avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      NetworkImage("https://i.pravatar.cc/100"),
                ),
              ),

              const SizedBox(width: 12),

              /// name + status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Daniel Garcia",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Online",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              _icon(Icons.call),
              const SizedBox(width: 10),
              _icon(Icons.videocam),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _glow(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF3B82F6).withOpacity(0.05),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.25),
            blurRadius: 160,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}
