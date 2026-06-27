// ============================================================
// group_chat_screen_ui.dart â€” ChatX Group Chat UI
// âœ… ÙŠØ³ØªØ®Ø¯Ù… GroupChatCubit Ù…Ø´ ChatCubit
// âœ… senderImage Ø§ØªØ´Ø§Ù„ â€” Avatar Ø¨Ø§Ù„Ø­Ø±Ù Ø§Ù„Ø£ÙˆÙ„
// âœ… Glassmorphism Header
// âœ… Dynamic sender info (Ø£ÙˆÙ„ Ø±Ø³Ø§Ù„Ø© ÙÙŠ Ø§Ù„Ø³Ù„Ø³Ù„Ø© Ø¨Ø³)
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatx/screens/chat/models/message_model.dart';
import 'package:chatx/screens/chat/widgets/chat_input.dart';
import 'package:chatx/screens/chat/widgets/chat_bubble.dart';
import 'group_chat_cubit.dart';

class GroupChatScreenUI extends StatefulWidget {
  final String groupId;
  final String myUid;
  final String myName;
  final String groupName;
  final String? groupImage;
  final int memberCount;
  final int onlineCount;

  const GroupChatScreenUI({
    super.key,
    required this.groupId,
    required this.myUid,
    required this.myName,
    required this.groupName,
    this.groupImage,
    this.memberCount = 0,
    this.onlineCount = 0,
  });

  @override
  State<GroupChatScreenUI> createState() => _GroupChatScreenUIState();
}

class _GroupChatScreenUIState extends State<GroupChatScreenUI> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _headerKey = GlobalKey();

  late final GroupChatCubit _cubit;
  String? _highlightedMessageId;
  double _headerHeight = 115.0;

  @override
  void initState() {
    super.initState();
    _cubit = GroupChatCubit(
      groupId: widget.groupId,
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
          'Ø­Ø°Ù Ø§Ù„Ø±Ø³Ø§Ù„Ø©',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† Ø±ØºØ¨ØªÙƒ ÙÙŠ Ø­Ø°Ù Ù‡Ø°Ù‡ Ø§Ù„Ø±Ø³Ø§Ù„Ø©ØŸ',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child:
                const Text('Ø¥Ù„ØºØ§Ø¡', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _cubit.deleteMessage(messageId);
            },
            child: const Text('Ø­Ø°Ù',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
            // â”€â”€ Background â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

            // â”€â”€ Main Content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            BlocConsumer<GroupChatCubit, ChatState>(
              listenWhen: (prev, curr) =>
                  curr is ChatError && prev is! ChatError,
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: const Color(0xFF2B2C31),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin:
                            const EdgeInsets.fromLTRB(16, 0, 16, 90),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                }
              },
              builder: (context, state) {
                final messages = state is ChatLoaded
                    ? state.messages
                    : (state is ChatError
                        ? state.lastKnownMessages ?? []
                        : <Message>[]);
                final replyingTo =
                    state is ChatLoaded ? state.replyingTo : null;
                final cubit = context.read<GroupChatCubit>();
                final isLoading =
                    state is ChatLoading || state is ChatInitial;

                if (state is ChatLoaded && messages.isNotEmpty) {
                  final atBottom = !_scrollController.hasClients ||
                      _scrollController.offset <= 80.0;
                  final lastIsMine = messages.first.isMe;
                  if (lastIsMine || atBottom) {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom());
                  }
                }

                return Stack(
                  children: [
                    // â”€â”€ Messages List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 10, 16, 130),
                                      itemCount: messages.length,
                                      itemBuilder: (context, index) {
                                        final msg = messages[index];

                                        // Ø¥Ø¸Ù‡Ø§Ø± Ø§Ù„Ø§Ø³Ù… ÙˆØ§Ù„Ù€ avatar ÙÙ‚Ø· Ù„Ø£ÙˆÙ„ Ø±Ø³Ø§Ù„Ø© ÙÙŠ Ø§Ù„Ø³Ù„Ø³Ù„Ø©
                                        bool showSenderInfo = false;
                                        if (!msg.isMe) {
                                          if (index ==
                                              messages.length - 1) {
                                            showSenderInfo = true;
                                          } else {
                                            final prevMsg =
                                                messages[index + 1];
                                            showSenderInfo =
                                                msg.senderId !=
                                                    prevMsg.senderId;
                                          }
                                        }

                                        return _GroupMessageWrapper(
                                          message: msg,
                                          showSenderInfo: showSenderInfo,
                                          child: ChatBubble(
                                            key: ValueKey(
                                                msg.id ?? index),
                                            message: msg,
                                            onReply: cubit.setReply,
                                            onTapReply: (replyId) =>
                                                _scrollToMessage(
                                                    replyId, messages),
                                            isHighlighted: msg.id !=
                                                    null &&
                                                msg.id ==
                                                    _highlightedMessageId,
                                            onEdit: () =>
                                                _showEditDialog(
                                                    context, msg),
                                            onDelete: () =>
                                                _showDeleteDialog(
                                                    context, msg.id),
                                            onReact: (emoji) =>
                                                cubit.addReaction(
                                                    msg.id, emoji),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),
                    ),

                    // â”€â”€ Bottom Gradient Fade â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

                    // â”€â”€ Chat Input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
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

            // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: _GroupHeader(
                  key: _headerKey,
                  groupName: widget.groupName,
                  groupImage: widget.groupImage,
                  memberCount: widget.memberCount,
                  onlineCount: widget.onlineCount,
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
          Icon(Icons.groups_outlined, color: Colors.white12, size: 64),
          SizedBox(height: 16),
          Text(
            'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø±Ø³Ø§Ø¦Ù„ Ø¨Ø¹Ø¯',
            style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Ø§Ø¨Ø¯Ø£ Ø§Ù„Ù…Ø­Ø§Ø¯Ø«Ø© Ù…Ø¹ Ø£Ø¹Ø¶Ø§Ø¡ Ø§Ù„Ø¬Ø±ÙˆØ¨ ðŸ‘‹',
            style: TextStyle(color: Colors.white24, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Group Message Wrapper â€” Avatar Ø¨Ø§Ù„Ø­Ø±Ù Ø§Ù„Ø£ÙˆÙ„ (Ø¨Ø¯Ù„ senderImage)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GroupMessageWrapper extends StatelessWidget {
  final Message message;
  final bool showSenderInfo;
  final Widget child;

  const _GroupMessageWrapper({
    required this.message,
    required this.showSenderInfo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isMe) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: child,
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: showSenderInfo ? 16 : 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Ø£Ùˆ Ù…Ø³Ø§ÙØ© ÙØ§Ø¶ÙŠØ©
          if (showSenderInfo)
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: _SenderAvatar(name: message.senderName ?? '?'),
            )
          else
            const SizedBox(width: 42),

          // Name + Bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSenderInfo)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      message.senderName ?? 'Ø¹Ø¶Ùˆ',
                      style: const TextStyle(
                        color: Color(0xFF4186F6),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Sender Avatar â€” Ø§Ù„Ø­Ø±Ù Ø§Ù„Ø£ÙˆÙ„ Ù…Ù† Ø§Ù„Ø§Ø³Ù… (Ø¨Ø¯Ù„ NetworkImage)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SenderAvatar extends StatelessWidget {
  final String name;
  const _SenderAvatar({required this.name});

  // Ø£Ù„ÙˆØ§Ù† Ø«Ø§Ø¨ØªØ© Ù…Ø¨Ù†ÙŠØ© Ø¹Ù„Ù‰ Ø£ÙˆÙ„ Ø­Ø±Ù Ù…Ù† Ø§Ù„Ø§Ø³Ù…
  static const _colors = [
    Color(0xFF4186F6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];

  Color _colorFor(String name) {
    if (name.isEmpty) return _colors[0];
    return _colors[name.codeUnitAt(0) % _colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final initial =
        name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 16,
      backgroundColor: _colorFor(name),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Group Header â€” Glassmorphism
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GroupHeader extends StatelessWidget {
  final String groupName;
  final String? groupImage;
  final int memberCount;
  final int onlineCount;

  const _GroupHeader({
    super.key,
    required this.groupName,
    this.groupImage,
    this.memberCount = 0,
    this.onlineCount = 0,
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const _HeaderIcon(icon: Icons.arrow_back_ios_rounded),
                  ),
                  const SizedBox(width: 10),

                  // Group Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF4186F6).withOpacity(0.25),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white12,
                        backgroundImage: groupImage != null
                            ? NetworkImage(groupImage!)
                            : null,
                        child: groupImage == null
                            ? Text(
                                groupName.isNotEmpty
                                    ? groupName[0].toUpperCase()
                                    : 'G',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Group Name + Members
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          groupName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: const TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                text: '$memberCount Ø¹Ø¶Ùˆ',
                                style: const TextStyle(
                                    color: Colors.white54),
                              ),
                              const TextSpan(
                                text: '  â€¢  ',
                                style: TextStyle(
                                    color: Colors.white24, fontSize: 10),
                              ),
                              TextSpan(
                                text: '$onlineCount Ù…ØªØµÙ„',
                                style: const TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _HeaderIcon(icon: Icons.more_vert_rounded),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border:
                  Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(icon, color: Colors.white70, size: 22),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Edit Dialog
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø±Ø³Ø§Ù„Ø©',
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
              borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4186F6))),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('Ø¥Ù„ØºØ§Ø¡', style: TextStyle(color: Colors.white54)),
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
                color: Color(0xFF4186F6), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
