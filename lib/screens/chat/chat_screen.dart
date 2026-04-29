import 'dart:ui';
import 'package:flutter/material.dart';

// استيراد الموديل والويجيتس والريبوزيتوري بناءً على هيكل مشروعك
import 'models/message_model.dart';
import 'widgets/chat_input.dart';
import 'widgets/chat_bubble.dart';
import '../../repositories/firebase_repo.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String myUid;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.myUid,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _controller = ScrollController();

  // تغيير النوع ليتوافق مع الموديل المستخدم في الربلّاي
  MessageModel? replyingTo;

  void setReply(MessageModel message) {
    setState(() {
      replyingTo = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// 🔥 BACKGROUND (يبقى كما هو لضمان الجمالية)
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

          /// 🔥 🆕 LIST (المحرك الحقيقي المربوط بـ Firebase)[cite: 1]
          Positioned.fill(
            child: SafeArea(
              child: StreamBuilder<List<MessageModel>>(
                // مراقبة الرسايل لحظياً من الباك إند[cite: 1]
                stream: FirebaseRepo.observeMessages(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "ابدأ المحادثة الآن...",
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  final messages = snapshot.data!;

                  /// 🔥 Auto Scroll Logic لجعل الشات طلقة[cite: 1]
                  if (_controller.hasClients) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _controller.animateTo(
                        _controller.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  }

                  return ListView.builder(
                    controller: _controller,
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 140),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      return Column(
                        children: [
                          ChatBubble(
                            // تمرير الموديل مباشرة للـ Bubble[cite: 1]
                            message: m,
                            myUid: widget.myUid,
                            onReply: setReply,
                          ),
                          const SizedBox(height: 18),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),

          /// 🔥 INPUT FLOATING (منطق الإرسال)[cite: 1]
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
                onSend: (text, reply) async {
                  // إرسال البيانات للباك إند[cite: 1]
                  await FirebaseRepo.sendMessage(
                    widget.chatId,
                    MessageModel(
                      messageId: '', // الـ Firebase سيقوم بتوليده أو استخدم UUID
                      senderId: widget.myUid,
                      senderName: 'Me',
                      text: text,
                      timestamp: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );

                  setState(() {
                    replyingTo = null;
                  });
                },
              ),
            ),
          ),

          /// 🔥 BOTTOM FADE (تأثير الشفافية الذي طلبته)[cite: 1]
          Positioned(
            bottom: 0, left: 0, right: 0, height: 120,
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

          /// 🔥 TOP FADE[cite: 1]
          Positioned(
            top: 0, left: 0, right: 0, height: 120,
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

          /// 🔥 HEADER (القطعة الفنية)[cite: 1]
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: _header(),
            ),
          ),
        ],
      ),
    );
  }

  // ميثود الـ Header كما هي في تصميمك الأصلي لضمان عدم التغيير[cite: 1]
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
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                _avatarWithGlow(),
                const SizedBox(width: 12),
                _userInfo(),
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

  Widget _avatarWithGlow() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [const Color(0xFF00E6FF).withOpacity(0.20), Colors.transparent],
            ),
          ),
        ),
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=8"),
        ),
      ],
    );
  }

  Widget _userInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Daniel Garcia",
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 2),
        Text("Online", style: TextStyle(color: Color(0xFF22C55E), fontSize: 11)),
      ],
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
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
      ),
    );
  }
}
