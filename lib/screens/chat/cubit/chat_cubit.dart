import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:chatx/screens/chat/models/message_model.dart';
import 'package:chatx/screens/chat/widgets/chat_input.dart';
import 'package:chatx/screens/chat/widgets/chat_bubble.dart';
import 'package:chatx/screens/chat/cubit/chat_cubit.dart';

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
  String? highlightedMessageId;

  void scrollToMessage(String id) {
    setState(() {
      highlightedMessageId = id;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => highlightedMessageId = null);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // حماية الذاكرة من التسريب
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/bg.jpg", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.30)),
          ),
          Positioned.fill(
            child: SafeArea(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state is! ChatLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    controller: _controller,
                    reverse: true, // أداء فائق ومثالي للتمرير للأسفل
                    padding: const EdgeInsets.fromLTRB(20, 140, 20, 120),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];

                      return Column(
                        children: [
                          ChatBubble(
                            message: msg,
                            onReply: chatCubit.setReply,
                            onTapReply: (replyId) => scrollToMessage(replyId),
                            isHighlighted: msg.id == highlightedMessageId,
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
                replyMessage: chatCubit.replyingTo,
                onCancelReply: () => chatCubit.setReply(null),
                onSend: (text, replyId) => chatCubit.sendMessage(text),
              ),
            ),
          ),

          // الحفاظ على تأثير التدرجات والـ Header الأصلي 100% دون تغيير
          Positioned(
            bottom: 0, left: 0, right: 0, height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.45), Colors.black.withOpacity(0.20), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0, height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.35), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(child: _header()),
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
                colors: [Colors.white.withOpacity(0.10), Colors.white.withOpacity(0.03)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 25, offset: const Offset(0, 12)),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [const Color(0xFF00E6FF).withOpacity(0.20), Colors.transparent]),
                      ),
                    ),
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=8"),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Daniel Garcia", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text("Online", style: TextStyle(color: Color(0xFF22C55E), fontSize: 11)),
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
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
      ),
    );
  }
}
