// ============================================================
// chat_screen.dart — ChatX Main Chat UI
// ============================================================

import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:chatx/screens/chat/models/message_model.dart';
import 'package:chatx/screens/chat/widgets/chat_input.dart';
import 'package:chatx/screens/chat/widgets/chat_bubble.dart';
import 'package:chatx/screens/chat/cubit/chat_cubit.dart';

const double _kHeaderHeight = 108.0;

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String myUid;
  final String myName;
  final String receiverName;
  final String? receiverImage;
  final bool isOnline;
  final VoidCallback? onHeaderTap;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.myUid,
    required this.myName,
    this.receiverName = 'Unknown',
    this.receiverImage,
    this.isOnline = false,
    this.onHeaderTap,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  late ChatCubit _cubit;
  StreamSubscription<String>? _errorsSub;

  final ValueNotifier<int> _unread = ValueNotifier<int>(0);

  Timer? _highlightTimer;
  String? _highlightedMessageId;
  double _swipeDx = 0;

  void _createCubit() {
    _errorsSub?.cancel();
    _cubit = ChatCubit(
      chatId: widget.chatId,
      myUid: widget.myUid,
      myName: widget.myName,
    );
    _errorsSub = _cubit.errors.listen((message) {
      if (mounted) _showErrorSnackBar(context, message);
    });
  }

  @override
  void initState() {
    super.initState();
    _createCubit();
    _itemPositionsListener.itemPositions.addListener(_onPositionsChanged);
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId || oldWidget.myUid != widget.myUid) {
      final previous = _cubit;
      _unread.value = 0;
      _createCubit();
      previous.close();
    }
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onPositionsChanged);
    _highlightTimer?.cancel();
    _errorsSub?.cancel();
    _unread.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onPositionsChanged() {
    if (_unread.value != 0 && _isNearBottom()) _unread.value = 0;
  }

  // ── Gestures & Scroll Helpers ─────────────────────────────

  void _onSwipeStart(DragStartDetails details) => _swipeDx = 0;
  void _onSwipeUpdate(DragUpdateDetails details) => _swipeDx += details.delta.dx;
  void _onSwipeCancel() => _swipeDx = 0;

  void _onSwipeEnd(DragEndDetails details) {
    final double width = MediaQuery.of(context).size.width;
    final double velocity = details.primaryVelocity ?? 0;
    final bool shouldExit = _swipeDx > width * 0.25 || (_swipeDx > 60 && velocity > 700);
    _swipeDx = 0;

    if (shouldExit) {
      FocusManager.instance.primaryFocus?.unfocus();
      unawaited(Navigator.of(context).maybePop());
    }
  }

  bool _isNearBottom() {
    if (!_itemScrollController.isAttached) return true;
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return true;
    return positions.any((p) => p.index == 0);
  }

  void _scrollToBottom() {
    if (!mounted || !_itemScrollController.isAttached) return;
    unawaited(
      _itemScrollController.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  void _scrollToMessage(String id, List<Message> messages) {
    final int index = messages.indexWhere((m) => m.id == id);
    if (index == -1) {
      _showErrorSnackBar(context, 'الرسالة الأصلية محذوفة أو غير متاحة.');
      return;
    }
    if (!_itemScrollController.isAttached) return;

    _setHighlight(id);

    unawaited(
      _itemScrollController.scrollTo(
        index: index,
        alignment: 0.5,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ),
    );
  }

  void _setHighlight(String id) {
    _highlightTimer?.cancel();
    if (mounted) setState(() => _highlightedMessageId = id);
    _highlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlightedMessageId = null);
    });
  }

  List<Message> _messagesOf(ChatState s) {
    if (s is ChatLoaded) return s.messages;
    if (s is ChatError) return s.lastKnownMessages ?? const <Message>[];
    return const <Message>[];
  }

  Message? _newestOf(ChatState s) {
    final list = _messagesOf(s);
    return list.isEmpty ? null : list.first;
  }

  bool _hasNewNewest(ChatState prev, ChatState curr) {
    if (curr is! ChatLoaded) return false;
    final Message? c = _newestOf(curr);
    if (c == null) return false;
    final Message? p = _newestOf(prev);
    if (p == null) return true;
    return c.id != p.id && !c.time.isBefore(p.time);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    if (_isSameDay(d, now)) return 'اليوم';
    if (_isSameDay(d, now.subtract(const Duration(days: 1)))) return 'أمس';
    return '${d.day}/${d.month}/${d.year}';
  }

  Widget _withDateHeader(DateTime? date, Widget child) {
    if (date == null) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DateSeparator(label: _dateLabel(date)),
        child,
      ],
    );
  }

  // ── Dialogs ───────────────────────────────────────────────

  void _showDeleteDialog(BuildContext ctx, String? messageId) {
    if (messageId == null || messageId.isEmpty) {
      _showErrorSnackBar(context, 'الرسالة لسه بتتبعت، حاول بعد لحظة.');
      return;
    }

    showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'حذف الرسالة',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Message message) {
    if (!message.isEditable) return;

    showDialog<void>(
      context: context,
      builder: (_) => _EditDialog(
        initialText: message.text,
        onSave: (newText) => _cubit.editMessage(message.id, newText),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2B2C31),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;
    final double headerTotal = topInset + _kHeaderHeight;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
                    const ColoredBox(color: Color(0x4D000000)),
                  ],
                ),
              ),
            ),
            BlocConsumer<ChatCubit, ChatState>(
              listenWhen: (prev, curr) => _hasNewNewest(prev, curr),
              listener: (context, state) {
                if (state is ChatLoaded && state.messages.isNotEmpty) {
                  if (state.messages.first.isMe || _isNearBottom()) {
                    _unread.value = 0;
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  } else {
                    _unread.value++;
                  }
                }
              },
              builder: (context, state) {
                final List<Message> messages = _messagesOf(state);
                final Message? replyingTo = state is ChatLoaded ? state.replyingTo : null;
                final cubit = context.read<ChatCubit>();
                final bool isLoading = state is ChatLoading || state is ChatInitial;
                final bool isFatalError = state is ChatError && state.isFatal && messages.isEmpty;
                final bool showBanner = state is ChatError && state.isFatal && messages.isNotEmpty;

                final Widget content;
                if (isLoading) {
                  content = Padding(
                    padding: EdgeInsets.only(top: headerTotal),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4186F6),
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                } else if (isFatalError) {
                  content = _errorState(headerTotal, cubit.retry);
                } else if (messages.isEmpty) {
                  content = _emptyState(headerTotal);
                } else {
                  content = ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final bool isNewest = index == 0;
                      final bool isOldest = index == messages.length - 1;
                      final bool showDate = isOldest || !_isSameDay(messages[index + 1].time, msg.time);
                      return Padding(
                        padding: EdgeInsets.only(
                          top: isOldest ? headerTotal + 24 : 14,
                          bottom: isNewest ? 20 : 0,
                        ),
                        child: _withDateHeader(
                          showDate ? msg.time : null,
                          ChatBubble(
                            key: ValueKey(msg.id ?? 'tmp_${msg.time.microsecondsSinceEpoch}'),
                            message: msg,
                            onReply: cubit.setReply,
                            onTapReply: (replyId) => _scrollToMessage(replyId, messages),
                            isHighlighted: msg.id != null && msg.id == _highlightedMessageId,
                            onEdit: () => _showEditDialog(msg),
                            onDelete: () => _showDeleteDialog(context, msg.id),
                            onReact: (emoji) => cubit.addReaction(msg.id, emoji),
                          ),
                        ),
                      );
                    },
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragStart: _onSwipeStart,
                        onHorizontalDragUpdate: _onSwipeUpdate,
                        onHorizontalDragEnd: _onSwipeEnd,
                        onHorizontalDragCancel: _onSwipeCancel,
                        child: Stack(
                          children: [
                            Positioned.fill(child: content),
                            if (showBanner)
                              Positioned(
                                top: headerTotal + 8,
                                left: 16,
                                right: 16,
                                child: _ConnectionBanner(onRetry: cubit.retry),
                              ),
                            Positioned(
                              right: 16,
                              bottom: 12,
                              child: ValueListenableBuilder<int>(
                                valueListenable: _unread,
                                builder: (_, n, __) => n == 0
                                    ? const SizedBox.shrink()
                                    : FloatingActionButton.small(
                                        onPressed: _scrollToBottom,
                                        backgroundColor: const Color(0xFF4186F6),
                                        foregroundColor: Colors.white,
                                        child: Text('$n'),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.transparent,
                      child: SafeArea(
                        top: false,
                        child: ChatInput(
                          initialDraft: cubit.draft,
                          onDraftChanged: cubit.saveDraft,
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 1.2),
                  ),
                  child: _Header(
                    receiverName: widget.receiverName,
                    receiverImage: widget.receiverImage,
                    isOnline: widget.isOnline,
                    onTap: widget.onHeaderTap,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(double topPadding) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, color: Colors.white12, size: 56),
            SizedBox(height: 12),
            Text('ابدأ المحادثة الآن 👋', style: TextStyle(color: Colors.white24, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _errorState(double topPadding, VoidCallback onRetry) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 56),
            const SizedBox(height: 12),
            const Text('تعذّر تحميل الرسائل', style: TextStyle(color: Colors.white54, fontSize: 15)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة', style: TextStyle(color: Color(0xFF4186F6), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String receiverName;
  final String? receiverImage;
  final bool isOnline;
  final VoidCallback? onTap;

  const _Header({
    super.key,
    required this.receiverName,
    this.receiverImage,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: _kHeaderHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [Color(0x99000000), Color(0x662C2C2C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0x14FFFFFF)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x2E000000), blurRadius: 25, offset: Offset(0, 12)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onTap,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildAvatar(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    receiverName,
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isOnline) ...const [
                                    SizedBox(height: 2),
                                    Text('Online', style: TextStyle(color: Color(0xFF22C55E), fontSize: 11)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
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
      ),
    );
  }

  Widget _initialAvatar() {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF4186F6), Color(0xFF00E6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        receiverName.trim().isNotEmpty ? receiverName.trim()[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAvatar() {
    final String? image = receiverImage;
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [Color(0x3300E6FF), Colors.transparent]),
          ),
        ),
        Positioned(
          left: 8,
          top: 8,
          child: image != null && image.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    image,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initialAvatar(),
                  ),
                )
              : Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4186F6), Color(0xFF00E6FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Text(
                    receiverName.trim().isNotEmpty ? receiverName.trim()[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('قريباً'), duration: Duration(seconds: 1))),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x14FFFFFF),
          border: Border.all(color: const Color(0x14FFFFFF)),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }
}

class _EditDialog extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onSave;

  const _EditDialog({
    required this.initialText,
    required this.onSave,
  });

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final String newText = _controller.text.trim();
    if (newText.isNotEmpty && newText != widget.initialText.trim()) {
      widget.onSave(newText);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('تعديل الرسالة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        maxLines: null,
        textInputAction: TextInputAction.newline,
        decoration: const InputDecoration(
          hintText: 'تعديل النص...',
          hintStyle: TextStyle(color: Colors.white38),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4186F6))),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('حفظ', style: TextStyle(color: Color(0xFF4186F6), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x33000000),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ),
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final VoidCallback onRetry;
  const _ConnectionBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3A2A2A),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'انقطع التحديث التلقائي، اضغط لإعادة المحاولة',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
