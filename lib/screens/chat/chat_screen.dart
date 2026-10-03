// ============================================================
// chat_screen.dart — ChatX Main Chat UI
// ✨ Enterprise Level Optimization & Clean UI Layout
// ============================================================

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatx/screens/chat/models/message_model.dart';
import 'package:chatx/screens/chat/widgets/chat_input.dart';
import 'package:chatx/screens/chat/widgets/chat_bubble.dart';
import 'package:chatx/screens/chat/cubit/chat_cubit.dart';

// ─────────────────────────────────────────────
// Header design tokens
// ─────────────────────────────────────────────

const double _kHeaderCardHeight = 64.0;
const double _kHeaderVerticalMargin = 8.0;
const double _kHeaderSideMargin = 12.0;
const double _kHeaderRadius = 24.0;
// الارتفاع الكلي للهيدر (من غير الـ status bar): الكارت + الـ margin فوق وتحت
const double _kHeaderBlockHeight =
    _kHeaderCardHeight + _kHeaderVerticalMargin * 2;

const Color _kAccentBlue = Color(0xFF4186F6);
const Color _kAccentCyan = Color(0xFF00E6FF);
const Color _kOnline = Color(0xFF22C55E);

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String myUid;
  final String myName; 
  final String receiverName;
  final String? receiverImage;
  final bool isOnline;
  final VoidCallback? onVideoCall;
  final VoidCallback? onVoiceCall;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.myUid,
    required this.myName,
    this.receiverName = 'Unknown',
    this.receiverImage,
    this.isOnline = false,
    this.onVideoCall,
    this.onVoiceCall,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  late final ChatCubit _cubit;
  String? _highlightedMessageId;

  @override
  void initState() {
    super.initState();
    _cubit = ChatCubit(
      chatId: widget.chatId,
      myUid: widget.myUid,
      myName: widget.myName,
    );
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
    final double topInset = MediaQuery.paddingOf(context).top;
    final double headerHeight = topInset + _kHeaderBlockHeight;

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

                return Column(
                  children: [
                    // ── Messages List ─────────────────
                    Expanded(
                      child: ClipRect(
                        child: isLoading
                            ? Padding(
                                padding: EdgeInsets.only(top: headerHeight),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF4186F6),
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : messages.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.only(top: headerHeight),
                                    child: _emptyState(),
                                  )
                                : ListView.builder(
                                    controller: _scrollController,
                                    reverse: true,
                                    padding: EdgeInsets.fromLTRB(
                                      16,
                                      headerHeight + 10,
                                      16,
                                      20,
                                    ),
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
                    Container(
                      color: Colors.transparent,
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

            // ── Top Scrim (يحافظ على وضوح الـ status bar فوق الرسايل) ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset + 28,
              child: const IgnorePointer(child: _TopScrim()),
            ),

            // ── Header ──────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _Header(
                topInset: topInset,
                receiverName: widget.receiverName,
                receiverImage: widget.receiverImage,
                isOnline: widget.isOnline,
                onVideoCall: widget.onVideoCall,
                onVoiceCall: widget.onVoiceCall,
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
  final double topInset;
  final String receiverName;
  final String? receiverImage;
  final bool isOnline;
  final VoidCallback? onVideoCall;
  final VoidCallback? onVoiceCall;

  const _Header({
    required this.topInset,
    required this.receiverName,
    this.receiverImage,
    this.isOnline = false,
    this.onVideoCall,
    this.onVoiceCall,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _kHeaderSideMargin,
        topInset + _kHeaderVerticalMargin,
        _kHeaderSideMargin,
        _kHeaderVerticalMargin,
      ),
      child: SizedBox(
        height: _kHeaderCardHeight,
        child: RepaintBoundary(
          child: DecoratedBox(
            // الظل برا الـ ClipRRect عشان ميتقصش
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_kHeaderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_kHeaderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: CustomPaint(
                  foregroundPainter: const _GlassBorderPainter(
                    radius: _kHeaderRadius,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.04),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: canPop ? 6 : 14,
                        end: 8,
                      ),
                      child: Row(
                        children: [
                          if (canPop) ...[
                            _GlassButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              iconSize: 18,
                              semanticLabel: 'رجوع',
                              onTap: () {
                                Navigator.maybePop(context);
                              },
                            ),
                            const SizedBox(width: 4),
                          ],
                          _HeaderAvatar(
                            name: receiverName,
                            imageUrl: receiverImage,
                            isOnline: isOnline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _HeaderTitle(
                              name: receiverName,
                              isOnline: isOnline,
                            ),
                          ),
                          _GlassButton(
                            icon: Icons.videocam_outlined,
                            semanticLabel: 'مكالمة فيديو',
                            onTap: onVideoCall,
                          ),
                          _GlassButton(
                            icon: Icons.call_outlined,
                            semanticLabel: 'مكالمة صوتية',
                            onTap: onVoiceCall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Title (name + status) ────────────────────

class _HeaderTitle extends StatelessWidget {
  final String name;
  final bool isOnline;

  const _HeaderTitle({required this.name, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    // OverflowBox: لو الـ text scale كبير جداً النص يتقص بدل ما يطلع overflow error
    return OverflowBox(
      maxHeight: double.infinity,
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            ),
            child: Text(
              isOnline ? 'متصل الآن' : 'آخر ظهور مؤخراً',
              key: ValueKey<bool>(isOnline),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isOnline ? _kOnline : Colors.white.withOpacity(0.55),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar ───────────────────────────────────

class _HeaderAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isOnline;

  static const double _size = 48.0;

  const _HeaderAvatar({
    required this.name,
    required this.imageUrl,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final String url = imageUrl?.trim() ?? '';

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isOnline
                      ? const [_kAccentBlue, _kAccentCyan]
                      : [
                          Colors.white.withOpacity(0.22),
                          Colors.white.withOpacity(0.08),
                        ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF101216),
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _AvatarFallback(name: name),
                      if (url.isNotEmpty)
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          cacheWidth: 128,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) return child;
                            return AnimatedOpacity(
                              opacity: frame == null ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              child: child,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isOnline)
            const PositionedDirectional(
              end: -1,
              bottom: -1,
              child: _OnlineDot(),
            ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;

  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final String trimmed = name.trim();
    final String initial = trimmed.isEmpty
        ? '?'
        : String.fromCharCode(trimmed.runes.first).toUpperCase();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F4A7D), Color(0xFF16213A)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Online dot (soft pulse) ──────────────────

class _OnlineDot extends StatefulWidget {
  const _OnlineDot();

  @override
  State<_OnlineDot> createState() => _OnlineDotState();
}

class _OnlineDotState extends State<_OnlineDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double t = Curves.easeOut.transform(_controller.value);
                return Transform.scale(
                  scale: 1.0 + t * 1.1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kOnline.withOpacity(0.45 * (1.0 - t)),
                    ),
                    child: const SizedBox(width: 14, height: 14),
                  ),
                );
              },
            ),
          ),
          Container(
            width: 14,
            height: 14,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF101216),
            ),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kOnline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glass action button ──────────────────────

class _GlassButton extends StatefulWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final double iconSize;

  const _GlassButton({
    required this.icon,
    required this.semanticLabel,
    this.onTap,
    this.iconSize = 20,
  });

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    final VoidCallback? onTap = widget.onTap;
    if (onTap == null) return;
    HapticFeedback.selectionClick();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          // مساحة اللمس 44 والشكل المرئي 38
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(_pressed ? 0.18 : 0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: Colors.white.withOpacity(0.88),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Glass border (gradient hairline) ─────────

class _GlassBorderPainter extends CustomPainter {
  final double radius;

  const _GlassBorderPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      Radius.circular(radius - 0.5),
    );
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.30),
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.12),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

// ── Top scrim (keeps status bar readable) ────

class _TopScrim extends StatelessWidget {
  const _TopScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x99000000), Color(0x00000000)],
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
