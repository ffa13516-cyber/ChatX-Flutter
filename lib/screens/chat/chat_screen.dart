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
    Message(text: "Hi 👋", isMe: false),
    Message(text: "Welcome to the new chat", isMe: true),
  ];

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(Message(text: text, isMe: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF020617),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🔹 Glow
          Positioned(
            top: -80,
            left: -60,
            child: _buildGlow(200, Colors.blue),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: _buildGlow(250, Colors.purple),
          ),

          /// 🔹 Content
          SafeArea(
            child: Column(
              children: [
                /// 🔥 Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Daniel Garcia",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Online",
                            style: TextStyle(
                                color: Colors.green, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.call, color: Colors.white),
                      const SizedBox(width: 12),
                      const Icon(Icons.videocam, color: Colors.white),
                    ],
                  ),
                ),

                /// 🔹 Messages
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(message: messages[index]);
                    },
                  ),
                ),

                /// 🔹 Input
                ChatInput(onSend: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}
