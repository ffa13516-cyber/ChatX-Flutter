// ============================================================
// chat_screen.dart â€” ChatX Main Chat UI
// âœ… msg.id? null-safe | âœ… myName parameter
// âœ… Dynamic header height | âœ… Safe scroll-to-message
// âœ… BlocConsumer Ù„Ù„Ù€ error snackbar | âœ… Clean dispose
// ============================================================

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
  final String myName; // âœ… NEW: Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ø§Ù„Ø­Ù‚ÙŠÙ‚ÙŠ
  final String receiverName;
  final String? receiverImage;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.myUid,
    required this.myName,
    this.receiverName = 'Unknown',
    this.receiverImage,
    this.isOnline = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _headerKey = GlobalKey();

  late final ChatCubit _cubit; // âœ… FIX: Ù†Ù†Ø´Ø¦ Ø§Ù„Ù€ Cubit Ù…Ø±Ø© ÙˆØ§Ø­Ø¯Ø© ÙÙŠ initState
  String? _highlightedMessageId;
  double _headerHeight = 115.0;

  @override
  void initState() {
    super.initState();
    // âœ… FIX: Ù†Ù†Ø´Ø¦ Ø§Ù„Ù€ Cubit Ù…Ø±Ø© ÙˆØ§Ø­Ø¯Ø© Ù…Ø´ ÙƒÙ„ build
    _cubit = ChatCubit(
      chatId: widget.chatId,
      myUid: widget.myUid,
      myName: widget.myName,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeader());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // âœ… FIX: Ø¥Ø¹Ø§Ø¯Ø© Ù‚ÙŠØ§Ø³ Ø§Ù„Ù€ header Ù„Ùˆ ØªØºÙŠØ±Øª Ø§Ù„Ù€ orientation Ø£Ùˆ Ø§Ù„Ù€ text scale
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeader());
  }

  @override
  void dispose() {
    _cubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _measureHeader() {
    final ctx = _headerKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box != null && mounted) {
      final newHeight = box.size.height;
      // 🟢 Performance Fix #9: setState بس لو الـ height فعلاً اتغيرت.
      // didChangeDependencies بتتنادى كتير — بدون الـ guard ده كل InheritedWidget
      // فوقيه بيتغير كان بيعمل rebuild للـ screen كلها حتى لو الـ height هي هي.
      if (newHeight != _headerHeight) {
        setState(() => _headerHeight = newHeight);
      }
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Scroll to replied message â€” âœ… Safe with estimated heights
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _scrollToMessage(String id, List<Message> messages) {
    final index = messages.indexWhere((m) => m.id == id);
    if (index == -1) return;

    if (mounted) setState(() => _highlightedMessageId = id);

    // Estimate offset (Ø§Ù„Ø±Ø³Ø§Ø¦Ù„ Ù…Ø´ uniformØŒ Ù‡Ù†Ø§ Ù†Ù‚Ø¯Ù‘Ø±)
    // Ø§Ù„Ù€ reverse ListView â†’ index 0 = Ø£Ø­Ø¯Ø« Ø±Ø³Ø§Ù„Ø©
    const double estimatedItemHeight = 85.0;
    final offset = index * estimatedItemHeight;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlightedMessageId = null);
    });
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Delete Dialog â€” âœ… null-safe messageId
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showDeleteDialog(BuildContext ctx, String? messageId) {
    // âœ… FIX: Ù„Ùˆ id Ø¨Ù€ null â€” Ù…Ø´ Ø¨Ù†ÙØªØ­ Ø§Ù„Ù€ dialog Ø®Ø§Ù„Øµ
    if (messageId == null || messageId.isEmpty) return;

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ø­Ø°Ù Ø§Ù„Ø±Ø³Ø§Ù„Ø©',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† Ø±ØºØ¨ØªÙƒ ÙÙŠ Ø­Ø°Ù Ù‡Ø°Ù‡ Ø§Ù„Ø±Ø³Ø§Ù„Ø©ØŸ',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Ø¥Ù„ØºØ§Ø¡', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              // Ù†Ø³ØªØ®Ø¯Ù… context Ø£ØµÙ„ÙŠ Ù…Ø´ dialogCtx
              ctx.read<ChatCubit>().deleteMessage(messageId);
            },
            child: const Text(
              'Ø­Ø°Ù',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Edit Dialog
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showEditDialog(BuildContext ctx, Message message) {
    if (!message.isEditable) return; // âœ… Ù†Øµ ÙÙ‚Ø·

    final textController = TextEditingController(text: message.text);

    showDialog(
      context: ctx,
      builder: (dialogCtx) => _EditDialog(
        message: message,
        textController: textController,
        onSave: (newText) => ctx.read<ChatCubit>().editMessage(message.id, newText),
      ),
    ).whenComplete(textController.dispose);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Build
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    // âœ… FIX: BlocProvider.value ÙŠØ³ØªØ®Ø¯Ù… cubit Ù…ÙˆØ¬ÙˆØ¯ Ø¨Ø¯Ù„ create Ø¬Ø¯ÙŠØ¯ ÙƒÙ„ rebuild
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // â”€â”€ Background â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            // 🟢 Performance Fix #5: RepaintBoundary يعزل الخلفية تماماً.
            // القديم: كل state change في BlocConsumer كان يعيد رسم الـ bg image.
            // الجديد: الـ bg layer مستقل — لا يُعاد رسمه أبداً إلا لو هو نفسه تغير.
            Positioned.fill(
              child: RepaintBoundary(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
                    ColoredBox(color: Colors.black.withOpacity(0.30)),
                  ],
                ),
              ),
            ),

            // â”€â”€ Main Content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            BlocConsumer<ChatCubit, ChatState>(
              // âœ… FIX: Ù†Ø¹Ø±Ø¶ Ø§Ù„Ù€ snackbar Ø¨Ø³ Ù„Ùˆ ÙÙŠ error Ø­Ù‚ÙŠÙ‚ÙŠ (Ù…Ø´ reaction failure)
              listenWhen: (prev, curr) =>
                  curr is ChatError && prev is! ChatError,
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          state.errorMessage,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFF2B2C31),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'Ø­Ø³Ù†Ø§Ù‹',
                          textColor: const Color(0xFF4186F6),
                          onPressed: () {},
                        ),
                      ),
                    );
                }
              },
              builder: (context, state) {
                final messages = state is ChatLoaded
                    ? state.messages
                    : (state is ChatError ? state.lastKnownMessages ?? [] : <Message>[]);
                final replyingTo = state is ChatLoaded ? state.replyingTo : null;
                final cubit = context.read<ChatCubit>();
                final isLoading = state is ChatLoading || state is ChatInitial;

                return Stack(
                  children: [
                    // â”€â”€ Messages List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Positioned(
                      top: _headerHeight,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SafeArea(
                        top: false,
                        child: ClipRect(
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF4186F6),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : messages.isEmpty
                                  ? _emptyState()
                                  : ListView.builder(
                                      controller: _scrollController,
                                      reverse: true,
                                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 130),
                                      itemCount: messages.length,
                                      itemBuilder: (context, index) {
                                        final msg = messages[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 14),
                                          child: ChatBubble(
                                            key: ValueKey(msg.id ?? index),
                                            message: msg,
                                            onReply: cubit.setReply,
                                            onTapReply: (replyId) =>
                                                _scrollToMessage(replyId, messages),
                                            isHighlighted:
                                                msg.id != null &&
                                                msg.id == _highlightedMessageId,
                                            onEdit: () =>
                                                _showEditDialog(context, msg),
                                            // âœ… FIX: Ø¨Ù†Ù…Ø±Ø± id? Ù…Ø´ id! ÙÙ…ÙÙŠØ´ crash
                                            onDelete: () =>
                                                _showDeleteDialog(context, msg.id),
                                            onReact: (emoji) =>
                                                cubit.addReaction(msg.id, emoji),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),
                    ),

                    // â”€â”€ Bottom Gradient Fade â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

                    // â”€â”€ Chat Input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: ChatInput(
                          replyMessage: replyingTo,
                          onCancelReply: () => cubit.setReply(null),
                          // âœ… FIX: onSend signature Ù…ØªØ²Ø§Ù…Ù† Ù…Ø¹ ChatInput
                          onSend: (text, _) => cubit.sendMessage(text),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: _Header(
                  key: _headerKey,
                  receiverName: widget.receiverName,
                  receiverImage: widget.receiverImage,
                  isOnline: widget.isOnline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, color: Colors.white12, size: 56),
          SizedBox(height: 12),
          Text(
            'Ø§Ø¨Ø¯Ø£ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø© Ø§Ù„Ø¢Ù† ðŸ‘‹',
            style: TextStyle(color: Colors.white24, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Header Widget â€” Ù…Ù†ÙØµÙ„ Ø¹Ø´Ø§Ù† Ø§Ù„Ù€ GlobalKey ÙŠØ´ØªØºÙ„
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Header extends StatelessWidget {
  final String receiverName;
  final String? receiverImage;
  final bool isOnline;

  const _Header({
    super.key,
    required this.receiverName,
    this.receiverImage,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    // 🟢 Performance Fix #4a: RepaintBoundary على الـ Header يمنع الـ blur
    // من إعادة رسم الـ messages list في كل scroll event.
    return RepaintBoundary(
      child: Container(
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
                // Avatar with online indicator
                Stack(
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
                    Positioned(
                      left: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white12,
                        backgroundImage: receiverImage != null
                            ? NetworkImage(receiverImage!)
                            : const NetworkImage('https://i.pravatar.cc/150?img=8'),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receiverName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOnline ? 'Online' : 'Last seen recently',
                        style: TextStyle(
                          color: isOnline
                              ? const Color(0xFF22C55E)
                              : Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _HeaderIcon(icon: Icons.videocam_outlined),
                const SizedBox(width: 10),
                _HeaderIcon(icon: Icons.call_outlined),
              ],
            ),
          ),
        ),
      ),
    ), // RepaintBoundary
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    // 🟢 Performance Fix #4b: RepaintBoundary على كل icon يمنع الـ blur
    // من invalidate الـ parent layer عند أي تغيير.
    return RepaintBoundary(
      child: ClipOval(
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
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Edit Dialog
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø±Ø³Ø§Ù„Ø©',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: widget.textController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        maxLines: null,
        textInputAction: TextInputAction.newline,
        decoration: const InputDecoration(
          hintText: 'ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ù†Øµ...',
          hintStyle: TextStyle(color: Colors.white38),
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
          child: const Text('Ø¥Ù„ØºØ§Ø¡', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () {
            final newText = widget.textController.text.trim();
            if (newText.isNotEmpty && newText != widget.message.text) {
              widget.onSave(newText);
            }
            Navigator.pop(context);
          },
          child: const Text(
            'Ø­ÙØ¸',
            style: TextStyle(
              color: Color(0xFF4186F6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
