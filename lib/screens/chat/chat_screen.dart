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
    Message(
      text: "Hi 👋 It's good, yours?",
      isMe: false,
      status: MessageStatus.seen,
    ),
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
    Message(
      text: "",
      isMe: false,
      type: MessageType.voice,
    ),
    Message(
      text: "Good Concept!",
      isMe: true,
      status: MessageStatus.seen,
    ),
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF050D1A),
                  Color(0xFF020617),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// Glow فوق يمين
          Positioned(
            top: -100,
            right: -60,
            child: _glow(300, Colors.blue),
          ),

          /// Glow تحت شمال
          Positioned(
            bottom: -120,
            left: -60,
            child: _glow(340, Colors.purple),
          ),

          /// Glow وسط خفيف
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.3,
            child: _glow(200, Colors.indigo),
          ),

          SafeArea(
            child: Column(
              children: [
                _header(),

                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(message: messages[index]);
                    },
                  ),
                ),

                /// Typing indicator
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, bottom: 4),
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

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Typing bubble زي الصورة
  Widget _typingBubble() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: const TypingIndicator(),
        ),
      ),
    );
  }

  Widget _header() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          child: Row(
            children: [
              /// Avatar مع glow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ),
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
                      letterSpacing: 0.2,
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

              /// أيقونة call
              _headerIcon(Icons.call),
              const SizedBox(width: 10),
              /// أيقونة video
              _headerIcon(Icons.videocam),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Icon(icon, color: Colors.white70, size: 19),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.07),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: const SizedBox(),
      ),
    );
  }
}
