import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../widgets/chat_input.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String? otherUserId;
  final String? otherUserName;
  final String? myUid;
  final String? myName;

  const ChatScreen({
    super.key,
    this.chatId,
    this.otherUserId,
    this.otherUserName,
    this.myUid,
    this.myName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _controller = ScrollController();

  MessageModel? replyingTo;

  void setReply(MessageModel message) {
    setState(() {
      replyingTo = message;
    });
  }

  void _sendMessage(String text, MessageModel? reply) async {
    if (widget.chatId == null || widget.myUid == null) return;

    final msg = MessageModel(
      messageId: '',
      senderId: widget.myUid!,
      senderName: widget.myName ?? '',
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await FirebaseRepo.sendMessage(widget.chatId!, msg);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_controller.hasClients) {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    setState(() {
      replyingTo = null;
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

          /// 🔥 🔥 MESSAGES (REAL DATA)
          Positioned.fill(
            child: SafeArea(
              child: StreamBuilder<List<MessageModel>>(
                stream: widget.chatId != null
                    ? FirebaseRepo.observeMessages(widget.chatId!)
                    : null,
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? [];

                  return ListView.builder(
                    controller: _controller,
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 140),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      return Column(
                        children: [
                          ChatBubble(
                            message: Message(
                              text: msg.text,
                              isMe: msg.senderId == widget.myUid,
                              time: DateTime.fromMillisecondsSinceEpoch(msg.timestamp),
                              senderName: msg.senderName,
                            ),
                            onReply: (m) {},
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

          /// 🔥 INPUT
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: SafeArea(
              child: ChatInput(
                replyMessage: null,
                onCancelReply: () {},
                onSend: (text, reply) => _sendMessage(text, null),
              ),
            ),
          ),

          /// 🔥 BOTTOM FADE
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

          /// 🔥 HEADER (خد الاسم الحقيقي)
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
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      NetworkImage("https://i.pravatar.cc/150?img=8"),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName ?? "Chat",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
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
