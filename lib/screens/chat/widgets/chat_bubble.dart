// ============================================================
// chat_bubble.dart — ChatX Message Bubble
// ✅ Context bug مصلح (emoji bottom sheet) 
// ✅ Copy guard (مش بيكوبي صور/صوت)
// ✅ Reactions toggle (نفس الإيموجي = ازيله)
// ✅ AnimationController dispose آمن
// ✅ _showActionMenu يستخدم rootContext مش dialog context
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_model.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final Function(Message)? onReply;
  final Function(String replyId)? onTapReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String emoji)? onReact;
  final bool isHighlighted;

  const ChatBubble({
    super.key,
    required this.message,
    this.onReply,
    this.onTapReply,
    this.onEdit,
    this.onDelete,
    this.onReact,
    this.isHighlighted = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isPlaying = false;

  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _waveController.dispose(); // stop + dispose في نفس الوقت
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    _isPlaying ? _waveController.repeat() : _waveController.stop();
  }

  // ─────────────────────────────────────────
  // Action Menu — ✅ FIX: rootContext محفوظ قبل فتح الـ dialog
  // ─────────────────────────────────────────

  void _showActionMenu(BuildContext rootContext) {
    final isMe = widget.message.isMe;
    final box = rootContext.findRenderObject() as RenderBox?;
    if (box == null) return;

    final offset = box.localToGlobal(Offset.zero);
    double topPos = offset.dy - 120;
    if (topPos < 60) topPos = offset.dy + box.size.height + 12;

    showGeneralDialog(
      context: rootContext,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogCtx, animation, _) {
        return Stack(
          children: [
            // Dismiss area
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(dialogCtx),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),

            Positioned(
              top: topPos,
              left: isMe ? null : 20,
              right: isMe ? 20 : null,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // ── Quick Reactions Row ────────────────
                      _GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...['❤️', '👍', '🔥', '😂', '😮', '😢'].map(
                              (emoji) => GestureDetector(
                                onTap: () {
                                  Navigator.pop(dialogCtx);
                                  widget.onReact?.call(emoji);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6),
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ),
                            // More emojis button
                            // ✅ FIX: بنستخدم rootContext مش dialogCtx
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(dialogCtx);
                                // ✅ FIX: rootContext صالح هنا لأننا أغلقنا الـ dialog
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _showEmojiSheet(rootContext);
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.only(left: 4, right: 2),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Context Menu ──────────────────────
                      _GlassCard(
                        width: 195,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // رد
                            _MenuItem(
                              icon: Icons.reply_rounded,
                              label: 'رد',
                              onTap: () {
                                Navigator.pop(dialogCtx);
                                widget.onReply?.call(widget.message);
                              },
                            ),

                            // نسخ — ✅ FIX: text فقط
                            if (widget.message.type == MessageType.text)
                              _MenuItem(
                                icon: Icons.copy_rounded,
                                label: 'نسخ',
                                onTap: () {
                                  Navigator.pop(dialogCtx);
                                  Clipboard.setData(
                                    ClipboardData(
                                        text: widget.message.text),
                                  );
                                  ScaffoldMessenger.of(rootContext)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('تم نسخ الرسالة ✓'),
                                      duration: Duration(seconds: 1),
                                      backgroundColor:
                                          Color(0xFF2B2C31),
                                      behavior:
                                          SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),

                            // تعديل وحذف (مرسل فقط)
                            if (isMe) ...[
                              if (widget.message.isEditable)
                                _MenuItem(
                                  icon: Icons.edit_rounded,
                                  label: 'تعديل',
                                  onTap: () {
                                    Navigator.pop(dialogCtx);
                                    widget.onEdit?.call();
                                  },
                                ),
                              const Divider(
                                color: Colors.white12,
                                height: 1,
                                thickness: 0.5,
                              ),
                              _MenuItem(
                                icon: Icons.delete_outline_rounded,
                                label: 'حذف',
                                color: Colors.redAccent,
                                onTap: () {
                                  Navigator.pop(dialogCtx);
                                  widget.onDelete?.call();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────
  // Emoji Bottom Sheet — ✅ FIX: context صح
  // ─────────────────────────────────────────

  void _showEmojiSheet(BuildContext ctx) {
    if (!ctx.mounted) return;

    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.45,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1F23),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _allEmojis.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () {
                      // ✅ FIX: نغلق الـ sheet بـ sheetCtx مش ctx
                      Navigator.pop(sheetCtx);
                      widget.onReact?.call(_allEmojis[i]);
                    },
                    child: Center(
                      child: Text(
                        _allEmojis[i],
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────
  // Reactions Pill
  // ─────────────────────────────────────────

  Widget _buildReactionsPill() {
    final grouped = widget.message.groupedReactions;
    if (grouped.isEmpty) return const SizedBox.shrink();

    final totalCount = widget.message.reactionCount;
    // الإيموجي اللي اختاره المستخدم الحالي (لو موجود)
    final myCurrentReaction = widget.message.reactions?[
        // نستخدم onReact لأننا مش عندنا myUid هنا — الـ bubble يعمل toggle
        // بس نعرض الـ pill كـ tappable عشان UX
        'placeholder'
    ];

    return GestureDetector(
      // ✅ UX: ضغطة على الـ pill تفتح الـ quick reaction menu
      onTap: () => _showActionMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1F23),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...grouped.keys.take(3).map(
                  (emoji) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Text(emoji, style: const TextStyle(fontSize: 13)),
                  ),
                ),
            if (totalCount > 1) ...[
              const SizedBox(width: 4),
              Text(
                '$totalCount',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;
    final hasReactions = widget.message.hasReactions;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showActionMenu(context); // ✅ بنمرر الـ context هنا قبل ما ندخل في dialogs
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _Bubble(
                message: widget.message,
                isHighlighted: widget.isHighlighted,
                hasReactions: hasReactions,
                onTapReply: widget.onTapReply,
                isPlaying: _isPlaying,
                waveController: _waveController,
                onTogglePlay: _togglePlay,
              ),
              if (hasReactions)
                Positioned(
                  bottom: -10, // ✅ FIX: كان hasReactions ? -10 : 0 وده redundant لأن الـ if فوق كافي
                  right: isMe ? 12 : null,
                  left: isMe ? null : 12,
                  child: _buildReactionsPill(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Full emoji list ──────────────────────
  static const _allEmojis = [
    '😀','😁','😂','🤣','😃','😄','😅','😆',
    '😉','😊','😋','😎','😍','🥰','😘','😗',
    '🤩','🥳','😏','😒','😞','😔','😟','😕',
    '🙁','😣','😖','😫','😩','🥺','😢','😭',
    '😤','😠','😡','🤬','🤯','😳','🥵','🥶',
    '😱','😨','😰','😥','😓','🤗','🤔','🤭',
    '🤫','🤥','😶','😐','😑','😬','🙄','😯',
    '👍','👎','❤️','🔥','💯','🎉','✨','🙏',
    '👏','💪','👀','🤝','🫶','💀','🤡','👻',
  ];
}

// ─────────────────────────────────────────────
// Bubble Widget — extracted for clarity
// ─────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final Message message;
  final bool isHighlighted;
  final bool hasReactions;
  final Function(String)? onTapReply;
  final bool isPlaying;
  final AnimationController waveController;
  final VoidCallback onTogglePlay;

  const _Bubble({
    required this.message,
    required this.isHighlighted,
    required this.hasReactions,
    required this.onTapReply,
    required this.isPlaying,
    required this.waveController,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final time = _formatTime(message.time);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
      bottomLeft: Radius.circular(isMe ? 22 : 10),
      bottomRight: Radius.circular(isMe ? 10 : 22),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      margin: EdgeInsets.only(
        top: 1.5,
        bottom: hasReactions ? 16 : 1.5,
      ),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: ColoredBox(
          color: isMe ? const Color(0xFF4186F6) : const Color(0xFF2B2C31),
          child: Stack(
            children: [
              // Highlight overlay
              if (isHighlighted)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),

              // Content
              Padding(
                padding: message.type == MessageType.image
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: message.type == MessageType.image
                    ? _ImageContent(message: message, time: time, radius: radius)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (message.replyTo != null)
                            _ReplyPreview(
                              reply: message.replyTo!,
                              isMe: isMe,
                              onTap: () {
                                final id = message.replyToId;
                                if (id != null) onTapReply?.call(id);
                              },
                            ),
                          if (message.type == MessageType.voice)
                            _VoiceContent(
                              message: message,
                              isPlaying: isPlaying,
                              waveController: waveController,
                              onTogglePlay: onTogglePlay,
                            )
                          else
                            _TextContent(message: message),
                          const SizedBox(height: 4),
                          _TimeRow(time: time, isMe: isMe, status: message.status),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _TextContent extends StatelessWidget {
  final Message message;
  const _TextContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.5,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (message.isEdited)
          const Text(
            'تم التعديل',
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
      ],
    );
  }
}

class _ImageContent extends StatelessWidget {
  final Message message;
  final String time;
  final BorderRadius radius;

  const _ImageContent({
    required this.message,
    required this.time,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: radius,
          child: Image.network(
            message.imageUrl!,
            height: 180,
            width: 240,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 180,
              width: 240,
              color: Colors.white10,
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.white38,
                size: 40,
              ),
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 180,
                width: 240,
                color: Colors.white10,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                    color: Colors.white38,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 8,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}

class _VoiceContent extends StatelessWidget {
  final Message message;
  final bool isPlaying;
  final AnimationController waveController;
  final VoidCallback onTogglePlay;

  const _VoiceContent({
    required this.message,
    required this.isPlaying,
    required this.waveController,
    required this.onTogglePlay,
  });

  static const _staticHeights = [6.0, 12, 18, 8, 22, 14, 20, 6, 16, 24, 10, 20, 8, 18];

  String _formatDuration(int s) {
    final m = (s ~/ 60).toString();
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final duration = message.voiceDuration != null
        ? _formatDuration(message.voiceDuration!)
        : '—:——';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTogglePlay,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 28,
          width: 90,
          child: AnimatedBuilder(
            animation: waveController,
            builder: (_, __) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(14, (i) {
                  final phase = (waveController.value + i * 0.07) % 1.0;
                  final h = isPlaying
                      ? 4 + (phase < 0.5 ? phase : 1 - phase) * 18
                      : _staticHeights[i % _staticHeights.length];
                  final t = i / 13;
                  final color = Color.lerp(
                    const Color(0xFF0A84FF),
                    const Color(0xFF5AC8FA),
                    t,
                  )!.withOpacity(isPlaying ? 1.0 : 0.5);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 2.3,
                    height: h.toDouble(), // ✅ التعديل هنا فقط لتوافق الـ Types
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          duration,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  final Message reply;
  final bool isMe;
  final VoidCallback onTap;

  const _ReplyPreview({
    required this.reply,
    required this.isMe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String previewText;
    switch (reply.type) {
      case MessageType.image:
        previewText = '📷 Photo';
        break;
      case MessageType.voice:
        previewText = '🎤 Voice message';
        break;
      case MessageType.text:
        previewText = reply.text;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isMe
                      ? const Color(0xFF0A84FF)
                      : Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reply.senderName != null)
                      Text(
                        reply.senderName!,
                        style: TextStyle(
                          color: isMe
                              ? const Color(0xFF5AC8FA)
                              : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      previewText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String time;
  final bool isMe;
  final MessageStatus status;

  const _TimeRow({
    required this.time,
    required this.isMe,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 10.5,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          _StatusIcon(status: status),
        ],
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final MessageStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;

    switch (status) {
      case MessageStatus.sent:
        icon = Icons.check_rounded;
        color = Colors.white24;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all_rounded;
        color = Colors.white38;
        break;
      case MessageStatus.seen:
        icon = Icons.done_all_rounded;
        color = const Color(0xFF0A84FF);
        break;
    }

    return Icon(icon, size: 13, color: color);
  }
}

// ─────────────────────────────────────────────
// Glass Card Widget
// ─────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const _GlassCard({required this.child, this.width, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0).withOpacity(0.22),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Material(color: Colors.transparent, child: child),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Menu Item
// ─────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
