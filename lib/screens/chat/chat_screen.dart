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
  final String receiverName; 
  final String? receiverImage; 

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.myUid,
    this.receiverName = "Daniel Garcia", 
    this.receiverImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _controller = ScrollController();
  String? highlightedMessageId;
  
  // 🚀 متغير للتحكم في ارتفاع الهيدر عشان نقص الرسايل من بعده بالضبط
  // هنفترض إن الهيدر بياخد مساحة حوالي 115 بكسل (بما فيهم المارجن والـ SafeArea)
  final double headerHeight = 115.0; 

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
    _controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. الطبقة الأولى (الخلفية اللي تحت خالص) - دي هتفضل ثابتة والهيدر هيعمل عليها Blur
          Positioned.fill(
            child: Image.asset("assets/images/bg.jpg", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.30)),
          ),
          
          // 2. الطبقة التانية (منطقة الرسائل) - 🚀 هنا السحر كله
          Positioned(
            top: headerHeight, // بتبدأ من تحت الهيدر
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false, // شيلنا التوب عشان إحنا ظابطين الـ top بـ headerHeight
              child: ClipRect( // 🔥 ده اللي بيقص الرسايل وبيخليها تختفي أول ما تلمس الهيدر
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is! ChatLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      controller: _controller,
                      reverse: true, 
                      // قللنا البادنج من فوق لأننا أصلاً بدأنا الـ ListView من تحت الهيدر
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120), 
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state.messages[index];

                        return Column(
                          children: [
                            const SizedBox(height: 18),
                            ChatBubble(
                              message: msg,
                              onReply: chatCubit.setReply,
                              onTapReply: (replyId) => scrollToMessage(replyId),
                              isHighlighted: msg.id == highlightedMessageId,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // 3. التدرج (Gradient) السفلي للرسايل
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

          // (تم إزالة التدرج العلوي لأننا قصينا الرسايل خلاص ومبقاش ليه لازمة وهيبوظ شكل الهيدر)

          // 4. الطبقة التالتة (الهيدر فوق خالص)
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: _header(),
            ),
          ),

          // 5. الطبقة الرابعة (مربع الإدخال)
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
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      // ضفت Margin بسيط عشان الهيدر مايكونش لازق في الأطراف قوي (نفس الكود بتاعك)
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
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                        widget.receiverImage ?? "https://i.pravatar.cc/150?img=8",
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.receiverName, 
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
