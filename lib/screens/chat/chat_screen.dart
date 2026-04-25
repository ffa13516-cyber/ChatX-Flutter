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

    Message(
      text: "",
      isMe: true,
      type: MessageType.image,
      imageUrl: "https://picsum.photos/300",
    ),

    Message(
      text: "",
      isMe: false,
      type: MessageType.voice,
    ),

    Message(text: "Good Concept!", isMe: true),
  ];

  final ScrollController _controller = ScrollController();

  bool isTyping = true;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(Message(text: text, isMe: true));
      isTyping = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        messages.add(Message(text: "Nice 🔥", isMe: false));
        isTyping = false;
      });
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
          /// Background
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

          /// Glow
          Positioned(
            top: -120,
            left: -120,
            child: _glow(260),
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
                      final msg = messages[index];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(
                                msg.isMe
                                    ? (1 - value) * 50
                                    : -(1 - value) * 50,
                                0,
                              ),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: ChatBubble(message: msg),
                        ),
                      );
                    },
                  ),
                ),

                /// typing
                if (isTyping)
                  const Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 8),
                    child: TypingIndicator(),
                  ),

                ChatInput(onSend: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white.withOpacity(0.05),
          child: Row(
            children: const [
              CircleAvatar(
                radius: 22,
                backgroundImage:
                    NetworkImage("https://i.pravatar.cc/100"),
              ),
              SizedBox(width: 12),
              Text(
                "Daniel Garcia",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Icon(Icons.call, color: Colors.white),
              SizedBox(width: 10),
              Icon(Icons.videocam, color: Colors.white),
            ],
          ),
        ),
      ),
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
