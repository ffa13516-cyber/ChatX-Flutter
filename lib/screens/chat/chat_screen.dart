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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔥 Background غامقة جدًا
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

          /// 🔥 الأزرق من فوق الجنب (زي التصميم)
          Positioned(
            top: -120,
            left: -120,
            child: _glow(260),
          ),

          /// Glow خفيف جدًا تحت (تقريبًا مش باين)
          Positioned(
            bottom: -150,
            right: -100,
            child: _glowSmall(220),
          ),

          SafeArea(
            child: Column(
              children: [
                /// Header
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(30)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white.withOpacity(0.04),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundImage:
                                NetworkImage("https://i.pravatar.cc/100"),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Daniel Garcia",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Text("Online",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 12)),
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
                ),

                /// Messages
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      return TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween<double>(
                            begin: msg.isMe ? 50 : -50, end: 0),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(value, 0),
                            child: child,
                          );
                        },
                        child: ChatBubble(message: msg),
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

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  /// 🔥 Glow الرئيسي (فوق)
  Widget _glow(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF3B82F6).withOpacity(0.06),
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

  /// Glow ضعيف جدًا تحت
  Widget _glowSmall(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF3B82F6).withOpacity(0.02),
      ),
    );
  }
}
