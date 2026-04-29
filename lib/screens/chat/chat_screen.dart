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
    Message(text: "Hi 👋 It's god. Yours", isMe: false, status: MessageStatus.seen),
    Message(
      text: "It seem we have a lot common and have a lot interest in each other 😊",
      isMe: false,
      status: MessageStatus.seen,
    ),
    Message(text: "", isMe: false, type: MessageType.image, imageUrl: "https://picsum.photos/seed/chat/400/300"),
    Message(text: "", isMe: false, type: MessageType.voice),
    Message(text: "Good Concepts!", isMe: true, status: MessageStatus.seen),
  ];

  final ScrollController _controller = ScrollController();

  Message? replyingTo;

  void setReply(Message message) {
    setState(() {
      replyingTo = message;
    });
  }

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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [

          /// 🔥 BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.jpg",
              fit: BoxFit.cover,
            ),
          ),

          /// 🔥 OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.30),
            ),
          ),

          /// 🔥 CONTENT (الشات بس)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),

                Expanded(
                  child: ListView.builder(
                    controller: _controller,

                    /// ✅ مهم: نزود padding تحت عشان الرسائل متستخباش
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),

                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ChatBubble(
                            message: messages[index],
                            onReply: setReply,
                          ),
                          const SizedBox(height: 18),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          /// 🔥 INPUT FLOATING (زي الهيدر)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: SafeArea(
              child: ChatInput(
                replyMessage: replyingTo,
                onCancelReply: () {
                  setState(() => replyingTo = null);
                },
                onSend: (text, reply) {
                  setState(() {
                    messages.add(
                      Message(
                        text: text,
                        isMe: true,
                        status: MessageStatus.sent,
                        replyTo: reply,
                      ),
                    );
                    replyingTo = null;
                  });

                  /// 🔥 scroll لتحت بعد الإرسال
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_controller.hasClients) {
                      _controller.animateTo(
                        _controller.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                },
              ),
            ),
          ),

          /// 🔥 BOTTOM FADE (ناعم فوق الـ input)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.45),
                      Colors.black.withOpacity(0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// 🔥 TOP FADE
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// 🔥 HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _header(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF00E6FF).withOpacity(0.20),
                            Colors.transparent,
                          ],
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
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
      ),
    );
  }
}
