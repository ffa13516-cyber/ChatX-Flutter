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
      backgroundColor: const Color(0xFF060818),
      body: Stack(
        children: [
          /// ── BACKGROUND BASE ──
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.6, -0.8),
                radius: 1.4,
                colors: [
                  Color(0xFF0D1233),
                  Color(0xFF060818),
                  Color(0xFF03040E),
                ],
              ),
            ),
          ),

          /// ── GLOW فوق يمين - أزرق ──
          Positioned(
            top: -100,
            right: -100,
            child: _ellipseGlow(360, 300, const Color(0xFF2563EB), 0.22),
          ),

          /// ── GLOW فوق شمال - بنفسجي ──
          Positioned(
            top: 80,
            left: -80,
            child: _ellipseGlow(260, 200, const Color(0xFF7C3AED), 0.18),
          ),

          /// ── GLOW وسط خفيف - indigo ──
          Positioned(
            top: size.height * 0.38,
            left: size.width * 0.2,
            child: _ellipseGlow(180, 180, const Color(0xFF4F46E5), 0.10),
          ),

          /// ── GLOW تحت شمال - وردي ──
          Positioned(
            bottom: -120,
            left: -80,
            child: _ellipseGlow(340, 280, const Color(0xFF9333EA), 0.20),
          ),

          /// ── GLOW تحت يمين - أزرق خفيف ──
          Positioned(
            bottom: 60,
            right: -60,
            child: _ellipseGlow(200, 200, const Color(0xFF1D4ED8), 0.12),
          ),

          /// ── NOISE OVERLAY ──
          Opacity(
            opacity: 0.03,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://www.transparenttextures.com/patterns/asfalt-dark.png",
                  ),
                  repeat: ImageRepeat.repeat,
                ),
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
                  padding: const EdgeInsets.only(left: 16, bottom: 6),
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

  Widget _typingBubble() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.07),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: const TypingIndicator(),
        ),
      ),
    );
  }

  Widget _header() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.06),
                Colors.white.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.07)),
            ),
          ),
          child: Row(
            children: [
              /// Avatar مع gradient ring
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF060818),
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=8"),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.07),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }

  /// Ellipse glow مش دايرة كاملة
  Widget _ellipseGlow(double w, double h, Color color, double opacity) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w),
        color: color.withOpacity(opacity),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: const SizedBox(),
      ),
    );
  }
}
