// ============================================================
// chat_bubble.dart — ChatX Message Bubble
// ✨ Enterprise Level Optimization & Telegram UX Refinement
// ============================================================

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_model.dart';

// ✅ استخدام const constructor لتقليل تكلفة إعادة إنشاء الـ Widget
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
    with TickerProviderStateMixin {
  
  // 🟢 Performance: استخدام ValueNotifier لتجنب setState للـ Bubble بالكامل
  // عند تغيير حالة الضغط أو تشغيل الصوت. هذا يعزل الـ Repaint boundary.
  final ValueNotifier<bool> _isPressedListenable = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPlayingListenable = ValueNotifier<bool>(false);

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
    // 🟢 Performance Fix: وقّف الـ animation قبل الـ dispose لمنع الـ Memory Leak
    _waveController.stop();
    _waveController.dispose();
    _isPressedListenable.dispose();
    _isPlayingListenable.dispose();
    super.dispose();
  }

  void _togglePlay() {
    _isPlayingListenable.value = !_isPlayingListenable.value;
    if (_isPlayingListenable.value) {
      _waveController.repeat();
    } else {
      _waveController.stop();
    }
  }

  // ─────────────────────────────────────────
  // Action Menu — Telegram Pop-up UI
  // ─────────────────────────────────────────

  void _showActionMenu(BuildContext rootContext) {
    HapticFeedback.heavyImpact(); // ✅ UX: رد فعل اهتزازي قوي للقائمة
    
    final isMe = widget.message.isMe;
    final box = rootContext.findRenderObject() as RenderBox?;
    if (box == null) return;

    final offset = box.localToGlobal(Offset.zero);
    double topPos = offset.dy - 140;
    if (topPos < 80) topPos = offset.dy + box.size.height + 16;

    showGeneralDialog(
      context: rootContext,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black54, // تعميق الخلفية لزيادة التركيز
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogCtx, animation, secondaryAnimation) {
        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack, // حركة مطاطية فخمة جداً كالتليجرام
          reverseCurve: Curves.easeIn,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(dialogCtx),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: topPos,
              left: isMe ? null : 16,
              right: isMe ? 16 : null,
              child: ScaleTransition(
                scale: curvedAnim,
                alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                child: FadeTransition(
                  opacity: animation,
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // ── Quick Reactions Row (Telegram Horizontal Scroll Style) ──
                      _TelegramReactionsStrip(
                        onReact: (emoji) {
                          Navigator.pop(dialogCtx);
                          widget.onReact?.call(emoji);
                        },
                        onExpand: () {
                          Navigator.pop(dialogCtx);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showEmojiSheet(rootContext);
                          });
                        },
                      ),
                      
                      const SizedBox(height: 12),

                      // ── Context Menu ──────────────────────
                      _GlassCard(
                        width: 210,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MenuItem(
                              icon: Icons.reply_rounded,
                              label: 'رد',
                              onTap: () {
                                Navigator.pop(dialogCtx);
                                widget.onReply?.call(widget.message);
                              },
                            ),
                            if (widget.message.type == MessageType.text)
                              _MenuItem(
                                icon: Icons.copy_rounded,
                                label: 'نسخ النص',
                                onTap: () {
                                  Navigator.pop(dialogCtx);
                                  Clipboard.setData(
                                    ClipboardData(text: widget.message.text),
                                  );
                                },
                              ),
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
                              const Divider(color: Colors.white12, height: 1),
                              _MenuItem(
                                icon: Icons.delete_outline_rounded,
                                label: 'حذف الرسالة',
                                color: Colors.redAccent.shade100,
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
  // Emoji Bottom Sheet
  // ─────────────────────────────────────────

  void _showEmojiSheet(BuildContext ctx) {
    if (!ctx.mounted) return;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          height: MediaQuery.of(ctx).size.height * 0.55,
          decoration: const BoxDecoration(
            color: Color(0xFF17181C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: _allEmojis.length,
                  itemBuilder: (_, i) => _EmojiGridItem(
                    emoji: _allEmojis[i],
                    onTap: (selectedEmoji) {
                      Navigator.pop(sheetCtx);
                      widget.onReact?.call(selectedEmoji);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Reactions Pill (Overlapped On Bubble)
  // ─────────────────────────────────────────

  Widget _buildReactionsPill() {
    final grouped = widget.message.groupedReactions;
    if (grouped.isEmpty) return const SizedBox.shrink();

    final emojiKeys = grouped.keys.toList(growable: false);
    final totalCount = widget.message.reactionCount;

    return GestureDetector(
      onTap: () => _showActionMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1F23), // لون كبسولة تليجرام الداكن والمميز
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ReactionsStack(emojis: emojiKeys),
            if (totalCount > 1) ...[
              const SizedBox(width: 4),
              Text(
                '$totalCount',
                style: const TextStyle(
                  color: Color(0xFFEEEEEE),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Build Method
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;
    final hasReactions = widget.message.hasReactions;
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.78;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        // ✅ UX Refinement: تقليص المسافة مع حواف الشاشة لتكون 6 تماماً كالتليجرام
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: GestureDetector(
          onTapDown: (_) {
            _isPressedListenable.value = true;
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) => _isPressedListenable.value = false,
          onTapCancel: () => _isPressedListenable.value = false,
          onLongPress: () => _showActionMenu(context),
          child: ValueListenableBuilder<bool>(
            valueListenable: _isPressedListenable,
            builder: (context, isPressed, child) {
              return AnimatedScale(
                scale: isPressed ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeInOut,
                child: child,
              );
            },
            child: Stack(
              clipBehavior: Clip.none, // مهم جداً للسماح بالتداخل الخارجي للإيموجي
              children: [
                _Bubble(
                  message: widget.message,
                  isHighlighted: widget.isHighlighted,
                  hasReactions: hasReactions,
                  onTapReply: widget.onTapReply,
                  isPlayingListenable: _isPlayingListenable,
                  waveController: _waveController,
                  onTogglePlay: _togglePlay,
                  maxWidth: maxBubbleWidth,
                ),
                if (hasReactions)
                  Positioned(
                    // ✅ Telegram Style: وضع التفاعلات مدمجة ومباشرة فوق حافة البابل السفلية
                    bottom: -6, 
                    right: isMe ? 12 : null,
                    left: isMe ? null : 12,
                    child: _buildReactionsPill(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _allEmojis = [
    '❤️','👍','🔥','😂','😮','😢','✅','💯','🎉','✨','🙏','👏','💪','👀','🤝','🫶',
    '💀','🤡','🥳','😎','🤔','🤫','🤯','🥵','🥶','🥺','😭','😤','😠','🚫','👻','🤖',
    '😀','😁','🤣','😃','😄','😅','😆','😉','😊','😋','😍','🥰','😘','😗','🤩','😏',
    '😒','😞','😔','😟','😕','🙁','😣','😖','😫','😩','🤥','😶','😐','😑','😬','🙄',
  ];
}

// ─────────────────────────────────────────────
// ✅ Sub-widgets Isolated for Performance
// ─────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final Message message;
  final bool isHighlighted;
  final bool hasReactions;
  final Function(String)? onTapReply;
  final ValueNotifier<bool> isPlayingListenable; 
  final AnimationController waveController;
  final VoidCallback onTogglePlay;
  final double maxWidth;

  const _Bubble({
    required this.message,
    required this.isHighlighted,
    required this.hasReactions,
    required this.onTapReply,
    required this.isPlayingListenable,
    required this.waveController,
    required this.onTogglePlay,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final time = _formatTime(message.time);
    
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    final bubbleColor = isMe ? const Color(0xFF387CFF) : const Color(0xFF2B2C31);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      constraints: BoxConstraints(maxWidth: maxWidth),
      margin: EdgeInsets.only(
        top: 2,
        // ✅ تم تعديل الهامش السفلي ليكون 6 فقط ليحدث التداخل المثالي مع كبسولة الإيموجي
        bottom: hasReactions ? 6 : 2, 
      ),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: ColoredBox(
          color: bubbleColor,
          child: Stack(
            children: [
              if (isHighlighted)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              Padding(
                padding: message.type == MessageType.image
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                child: _buildContentByStatus(context, time, radius, isMe),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentByStatus(BuildContext context, String time, BorderRadius radius, bool isMe) {
    if (message.type == MessageType.image) {
      return _ImageContent(message: message, time: time, radius: radius);
    }

    return Column(
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
            isPlayingListenable: isPlayingListenable,
            waveController: waveController,
            onTogglePlay: onTogglePlay,
          )
        else
          _TextContent(message: message),
        
        const SizedBox(height: 2),
        _TimeRow(time: time, isMe: isMe, status: message.status, isEdited: message.isEdited),
      ],
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─────────────────────────────────────────────
// Content Sub-widgets (Refactored & Optimized)
// ─────────────────────────────────────────────

class _TextContent extends StatelessWidget {
  final Message message;
  const _TextContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        height: 1.3,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
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
    const double imageHeight = 200;
    const double imageWidth = 260;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {},
          child: ClipRRect(
            borderRadius: radius,
            child: Hero( 
              tag: 'img_${message.id}',
              child: Image.network(
                message.imageUrl!,
                height: imageHeight,
                width: imageWidth,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImagePlaceholder(height: imageHeight, width: imageWidth, isError: true,),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _ImagePlaceholder(height: imageHeight, width: imageWidth, progress: progress);
                },
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black26,
                child: Text(
                  time,
                  style: const TextStyle(color: Color(0xFFD9D9D9), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final bool isError;
  final ImageChunkEvent? progress;

  const _ImagePlaceholder({required this.height, required this.width, this.isError = false, this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFF1E1F23),
      child: Center(
        child: isError 
          ? const Icon(Icons.broken_image_outlined, color: Colors.white24, size: 40,)
          : CircularProgressIndicator(
              strokeWidth: 2,
              value: progress?.expectedTotalBytes != null
                  ? progress!.cumulativeBytesLoaded / progress!.expectedTotalBytes!
                  : null,
              color: Colors.white24,
            ),
      ),
    );
  }
}

class _VoiceContent extends StatelessWidget {
  final Message message;
  final ValueNotifier<bool> isPlayingListenable;
  final AnimationController waveController;
  final VoidCallback onTogglePlay;

  const _VoiceContent({
    required this.message,
    required this.isPlayingListenable,
    required this.waveController,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    final duration = message.voiceDuration != null
        ? _formatDuration(message.voiceDuration!)
        : '0:00';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _VoicePlayButton(isPlayingListenable: isPlayingListenable, onTogglePlay: onTogglePlay),
        const SizedBox(width: 12),
        _VoiceWaveVisualizer(waveController: waveController, isPlayingListenable: isPlayingListenable),
        const SizedBox(width: 10),
        Text(
          duration,
          style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500, fontFeatures: [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }

  String _formatDuration(int s) {
    final m = (s ~/ 60).toString();
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }
}

class _VoicePlayButton extends StatelessWidget {
  final ValueNotifier<bool> isPlayingListenable;
  final VoidCallback onTogglePlay;

  const _VoicePlayButton({required this.isPlayingListenable, required this.onTogglePlay});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTogglePlay();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: isPlayingListenable,
          builder: (_, isPlaying, __) {
            return Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 20,
            );
          },
        ),
      ),
    );
  }
}

class _VoiceWaveVisualizer extends StatelessWidget {
  final AnimationController waveController;
  final ValueNotifier<bool> isPlayingListenable;

  const _VoiceWaveVisualizer({required this.waveController, required this.isPlayingListenable});
  static const _barHeights = [0.2, 0.5, 0.8, 0.3, 0.9, 0.6, 0.8, 0.2, 0.7, 1.0, 0.4, 0.9, 0.3, 0.8];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 100,
      child: AnimatedBuilder(
        animation: waveController,
        builder: (context, _) {
          return CustomPaint(
            painter: _WaveBarPainter(
              animationValue: waveController.value,
              isPlaying: isPlayingListenable.value,
              barHeights: _barHeights,
            ),
          );
        },
      ),
    );
  }
}

class _WaveBarPainter extends CustomPainter {
  final double animationValue;
  final bool isPlaying;
  final List<double> barHeights;

  const _WaveBarPainter({
    required this.animationValue,
    required this.isPlaying,
    required this.barHeights,
  });

  static const _colorA = Color(0xFF8AB4F8);
  static const _colorB = Colors.white;
  static const _barWidth = 2.5;
  static const _barSpacing = 2.4;
  static const _minHeight = 4.0;
  static const _maxExtraHeight = 22.0;
  static const _cornerRadius = Radius.circular(2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final totalBarWidth = _barWidth + _barSpacing;
    final startX = (size.width - barHeights.length * totalBarWidth) / 2;

    for (int i = 0; i < barHeights.length; i++) {
      double hFactor;
      if (isPlaying) {
        final phase = (animationValue - i * 0.05) % 1.0;
        final sine = (1 + math.sin(phase * 2 * math.pi)) / 2;
        hFactor = 0.2 + (sine * 0.8);
      } else {
        hFactor = barHeights[i];
      }

      final barHeight = _minHeight + (hFactor * _maxExtraHeight);
      final x = startX + i * totalBarWidth;
      final y = (size.height - barHeight) / 2;
      paint.color = Color.lerp(_colorA, _colorB, hFactor)!
          .withOpacity(isPlaying ? 1.0 : 0.6);

      canvas.drawRRect(
        RRect.fromLTRBR(x, y, x + _barWidth, y + barHeight, _cornerRadius),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveBarPainter old) =>
      old.animationValue != animationValue || old.isPlaying != isPlaying;
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
    IconData? icon;
    String previewText = reply.text;

    switch (reply.type) {
      case MessageType.image:
        icon = Icons.image_rounded;
        previewText = 'صورة';
        break;
      case MessageType.voice:
        icon = Icons.mic_rounded;
        previewText = 'رسالة صوتية';
        break;
      case MessageType.text: 
        break;
    }

    final lineColor = isMe ? Colors.white70 : const Color(0xFF387CFF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: isMe ? null : Border(left: BorderSide(color: lineColor.withOpacity(0.5), width: 0.5)),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? 'أنت' : (reply.senderName ?? 'مستخدم'),
                      style: TextStyle(
                        color: lineColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            previewText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
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
  final bool isEdited;

  const _TimeRow({
    required this.time,
    required this.isMe,
    required this.status,
    required this.isEdited,
  });

  @override
  Widget build(BuildContext context) {
    final showEdited = isEdited;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showEdited) ...[
          const Text(
            'معدلة',
            style: TextStyle(color: Colors.white30, fontSize: 10),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          time,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 5),
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
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sent:
        icon = Icons.check_rounded;
        color = Colors.white30;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all_rounded;
        color = Colors.white54;
        break;
      case MessageStatus.seen:
        icon = Icons.done_all_rounded;
        color = const Color(0xFF8AB4F8);
        break;
    }

    return Icon(icon, size: 14, color: color);
  }
}

// ─────────────────────────────────────────────
// ✅ UI Components (Telegram Custom Strip & Glass)
// ─────────────────────────────────────────────

class _TelegramReactionsStrip extends StatelessWidget {
  final Function(String) onReact;
  final VoidCallback onExpand;

  // قائمة الإيموجي الأكثر استخداماً تظهر في الشريط السريع القابل للسكرول
  static const _quickEmojis = ['❤️', '👍', '🔥', '😂', '😮', '😢', '🎉', '💯', '🙏', '👏', '👀', '✨', '💀', '💩'];

  const _TelegramReactionsStrip({
    required this.onReact,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 48,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2C31).withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _quickEmojis.length,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    itemBuilder: (context, index) {
                      return _ReactionEmojiItem(
                        emoji: _quickEmojis[index],
                        onTap: () => onReact(_quickEmojis[index]),
                      );
                    },
                  ),
                ),
                Container(
                  width: 1,
                  height: 22,
                  color: Colors.white.withOpacity(0.15),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
                GestureDetector(
                  onTap: onExpand,
                  child: Container(
                    padding: const EdgeInsets.only(left: 6, right: 12),
                    color: Colors.transparent, // توسيع الـ Hitbox للضغط المريح
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white80,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionEmojiItem extends StatefulWidget {
  final String emoji;
  final VoidCallback onTap;

  const _ReactionEmojiItem({required this.emoji, required this.onTap});

  @override
  State<_ReactionEmojiItem> createState() => _ReactionEmojiItemState();
}

class _ReactionEmojiItemState extends State<_ReactionEmojiItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => setState(() => _isPressed = true),
      onPanCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 1.35 : 1.0, // تكبير مطاطي مميز عند اللمس
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutBack,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          alignment: Alignment.center,
          child: Text(
            widget.emoji,
            style: const TextStyle(fontSize: 25),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const _GlassCard({required this.child, this.width, this.padding});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: width,
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xFF2B2C31).withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Material(color: Colors.transparent, child: child),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFFEEEEEE),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.02),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color.withOpacity(0.8), size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmojiGridItem extends StatelessWidget {
  final String emoji;
  final Function(String) onTap;

  const _EmojiGridItem({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(emoji),
      borderRadius: BorderRadius.circular(12),
      splashColor: const Color(0xFF387CFF).withOpacity(0.2), 
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

class _ReactionsStack extends StatelessWidget {
  final List<String> emojis;

  const _ReactionsStack({required this.emojis});

  @override
  Widget build(BuildContext context) {
    final displayEmojis = emojis.take(3).toList();
    
    return SizedBox(
      height: 18,
      width: 14.0 + (displayEmojis.length - 1) * 10.0, // حساب العرض الديناميكي المتداخل
      child: Stack(
        children: List.generate(displayEmojis.length, (i) {
          return Positioned(
            left: i * 10.0,
            child: Text(displayEmojis[i], style: const TextStyle(fontSize: 14)),
          );
        }),
      ),
    );
  }
}
