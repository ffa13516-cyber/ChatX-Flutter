import 'dart:ui';
import 'package:flutter/material.dart';
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

  Message? replyingTo;

  // 🔥 NEW: حفظ index عشان نعمل scroll للرسالة
  final Map<String, GlobalKey> _messageKeys = {};

  void setReply(Message message) {
    setState(() {
      replyingTo = message;
    });
  }

  // 🔥 NEW: scroll للرسالة الأصلية
  void scrollToMessage(String id) {
    final key = _messageKeys[id];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.jpg",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.30),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: StreamBuilder<List<Message>>(
                stream: FirebaseRepo.observeMessages(widget.chatId, widget.myUid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;

                  if (_controller.hasClients) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _controller.jumpTo(
                        _controller.position.maxScrollExtent,
                      );
                    });
                  }

                  return ListView.builder(
                    controller: _controller,
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 140),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      // 🔥 NEW: assign key لكل رسالة
                      final key = GlobalKey();
                      _messageKeys[msg.id ?? index.toString()] = key;

                      return Column(
                        key: key, // 🔥 مهم
                        children: [
                          ChatBubble(
                            message: msg,
                            onReply: setReply,

                            // 🔥 NEW: لما تضغط على reply
                            onTapReply: (replyId) {
                              scrollToMessage(replyId);
                            },
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
                  await FirebaseRepo.sendMessage(
                    widget.chatId,
                    Message(
                      text: text,
                      isMe: true,
                      senderId: widget.myUid,
                      senderName: 'Me',

                      // 🔥 NEW: ربط الريپلای
                      replyTo: reply,
                    ),
                  );

                  setState(() {
                    replyingTo = null;
                  });
                },
              ),
            ),
          ),

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
