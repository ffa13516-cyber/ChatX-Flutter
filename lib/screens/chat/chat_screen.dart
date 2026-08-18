// ============================================================
// chat_screen.dart — ChatX Main Chat UI
// ✨ Enterprise Level Optimization & Clean UI Layout
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
  final String myName; 
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

  late final ChatCubit _cubit;
  String? _highlightedMessageId;
  double _headerHeight = 115.0;

  @override
  void initState() {
    super.initState();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureHeader());
  }

  @override
  void dispose() {
    _cubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _measureHeader() {
    final ctx = _headerKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box != null && mounted) {
      final newHeight = box.size.height;
      if (newHeight != _headerHeight) {
        setState(() => _headerHeight = newHeight);
      }
    }
  }

  void _scrollToMessage(String id, List<Message> messages) {
    final index = messages.indexWhere((m) => m.id == id);
    if (index == -1) return;

    if (mounted) setState(() => _highlightedMessageId = id);

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

  void _showDeleteDialog(BuildContext ctx, String? messageId) {
    if (messageId == null || messageId.isEmpty) return;

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'حذف الرسالة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف هذه الرسالة؟',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _cubit.deleteMessage(messageId);
            },
            child: const Text(
              'حذف',
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

  void _showEditDialog(BuildContext ctx, Message message) {
    if (!message.isEditable) return;

    final textController = TextEditingController(text: message.text);
    showDialog(
      context: ctx,
      builder: (dialogCtx) => _EditDialog(
        message: message,
        textController: textController,
        onSave: (newText) => _cubit.editMessage(message.id, newText),
      ),
    ).whenComplete(textController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── Background ──────────────────────────
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

            // ── Main Content ────────────────────────
            BlocConsumer<ChatCubit, ChatState>(
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
                          label: 'حسناً',
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

                if (state is ChatLoaded && messages.isNotEmpty) {
                  final atBottom = !_scrollController.hasClients ||
                      _scrollController.offset <= 80.0;
                  final lastIsMine = messages.first.isMe;
                  if (lastIsMine || atBottom) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  }
                }

                // استخدمنا Column لفصل الرسائل عن منطقة الإدخال لضمان عدم التداخل
                return Column(
                  children: [
                    // مساحة شفافة تعادل حجم الـ Header لضمان نزول الرسائل خلفه بشكل صحيح
                    SizedBox(height: _headerHeight),
                    
                    // ── Messages List ─────────────────
                    Expanded(
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
                                    // قللنا المسافة السفلية لأن حقل الإدخال أصبح مفصولاً أسفل القائمة
                                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
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

                    // ── Chat Input ────────────────────
                    // غلفنا حقل الإدخال بحاوية صلبة لتجنب أي تداخل بصري
                    Container(
                      color: Colors.transparent, // يمكن تعديلها لـ Colors.black.withOpacity(0.8) إذا أردت خلفية صلبة
                      child: SafeArea(
                        top: false,
                        child: ChatInput(
                          replyMessage: replyingTo,
                          onCancelReply: () => cubit.setReply(null),
                          onSend: (text, _) => cubit.sendMessage(text),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // ── Header ──────────────────────────────
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
            'ابدأ المحادثة الآن 👋',
            style: TextStyle(color: Colors.white24, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header Widget 
// ─────────────────────────────────────────────

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
                const _HeaderIcon(icon: Icons.videocam_outlined),
                const SizedBox(width: 10),
                const _HeaderIcon(icon: Icons.call_outlined),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
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

// ─────────────────────────────────────────────
// Edit Dialog
// ─────────────────────────────────────────────

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
        'تعديل الرسالة',
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
          hintText: 'تعديل النص...',
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
          child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
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
            'حفظ',
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

