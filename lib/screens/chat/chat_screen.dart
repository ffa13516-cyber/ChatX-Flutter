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

  final double headerHeight = 115.0;

  void scrollToMessage(String id, List<Message> messages) {
    final index = messages.indexWhere((m) => m.id == id);
    if (index == -1) return;

    setState(() => highlightedMessageId = id);

    const estimatedItemHeight = 80.0 + 18.0;
    final totalItems = messages.length;
    final reversedIndex = totalItems - 1 - index;
    final offset = reversedIndex * estimatedItemHeight;

    _controller.animateTo(
      offset.clamp(0.0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => highlightedMessageId = null);
    });
  }

  void _showDeleteDialog(BuildContext ctx, String messageId) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Ø­Ø°Ù Ø§Ù„Ø±Ø³Ø§Ù„Ø©",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† Ø±ØºØ¨ØªÙƒ ÙÙŠ Ø­Ø°Ù Ù‡Ø°Ù‡ Ø§Ù„Ø±Ø³Ø§Ù„Ø©ØŸ",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child:
                const Text("Ø¥Ù„ØºØ§Ø¡", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              ctx.read<ChatCubit>().deleteMessage(messageId);
              Navigator.pop(dialogCtx);
            },
            child: const Text(
              "Ø­Ø°Ù",
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext ctx, Message message) {
    final textController = TextEditingController(text: message.text);

    showDialog(
      context: ctx,
      builder: (dialogCtx) => _EditDialog(
        message: message,
        textController: textController,
        onSave: (newText) {
          ctx.read<ChatCubit>().editMessage(message.id!, newText);
        },
      ),
    ).then((_) {
      textController.dispose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Ø§Ù„Ø®Ù„ÙÙŠØ©
          Positioned.fill(
            child: Image.asset("assets/images/bg.jpg", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.30)),
          ),

          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              final messages =
                  state is ChatLoaded ? state.messages : <Message>[];
              final replyingTo =
                  state is ChatLoaded ? state.replyingTo : null;
              final cubit = context.read<ChatCubit>();

              return Stack(
                children: [
                  // Ù‚Ø§Ø¦Ù…Ø© Ø§Ù„Ø±Ø³Ø§ÙŠÙ„
                  Positioned(
                    top: headerHeight,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: ClipRect(
                        child: state is! ChatLoaded
                            ? const Center(
                                child: CircularProgressIndicator())
                            : ListView.builder(
                                controller: _controller,
                                reverse: true,
                                padding: const EdgeInsets.fromLTRB(
                                    20, 10, 20, 120),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final msg = messages[index];
                                  return Column(
                                    children: [
                                      const SizedBox(height: 18),
                                      ChatBubble(
                                        message: msg,
                                        onReply: cubit.setReply,
                                        onTapReply: (replyId) =>
                                            scrollToMessage(
                                                replyId, messages),
                                        isHighlighted:
                                            msg.id == highlightedMessageId,
                                        onEdit: () =>
                                            _showEditDialog(context, msg),
                                        onDelete: () => _showDeleteDialog(
                                            context, msg.id!),
                                        // âœ… Ø±Ø¨Ø· Ø§Ù„Ù€ reaction Ø¨Ø§Ù„Ù€ cubit
                                        onReact: (emoji) {
                                          if (msg.id != null) {
                                            cubit.addReaction(msg.id, emoji);
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ),
                    ),
                  ),

                  // Gradient ÙÙˆÙ‚ Ø§Ù„Ù€ input
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
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: ChatInput(
                        replyMessage: replyingTo,
                        onCancelReply: () => cubit.setReply(null),
                        onSend: (text, replyId) => cubit.sendMessage(text),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Ø§Ù„Ù‡ÙŠØ¯Ø±
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
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
              border:
                  Border.all(color: Colors.white.withOpacity(0.08)),
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
                        widget.receiverImage ??
                            "https://i.pravatar.cc/150?img=8",
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
                          color: Color(0xFF22C55E), fontSize: 11),
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
            border:
                Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
      ),
    );
  }
}

// âœ… Edit Dialog
class _EditDialog extends StatefulWidget {
  final Message message;
  final TextEditingController textController;
  final Function(String) onSave;

  const _EditDialog({
    required this.message,
    required this.textController,
    required this.onSave,
  });

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø±Ø³Ø§Ù„Ø©",
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: widget.textController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        maxLines: null,
        // âœ… SECURITY: Ø­Ø¯ Ø£Ù‚ØµÙ‰ Ù„Ù„Ù†Øµ
        maxLength: 4000,
        decoration: const InputDecoration(
          hintText: "ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ù†Øµ...",
          hintStyle: TextStyle(color: Colors.white38),
          counterStyle: TextStyle(color: Colors.white24),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4186F6)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text("Ø¥Ù„ØºØ§Ø¡", style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () {
            final newText = widget.textController.text.trim();
            // âœ… SECURITY: Ù…Ø´ Ø¨Ù†Ø­ÙØ¸ Ù„Ùˆ Ø§Ù„Ù†Øµ ÙØ§Ø¶ÙŠ Ø£Ùˆ Ù…Ø´ Ø§ØªØºÙŠØ±
            if (newText.isNotEmpty && newText != widget.message.text) {
              widget.onSave(newText);
            }
            Navigator.pop(context);
          },
          child: const Text(
            "Ø­ÙØ¸",
            style: TextStyle(
                color: Color(0xFF4186F6), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
