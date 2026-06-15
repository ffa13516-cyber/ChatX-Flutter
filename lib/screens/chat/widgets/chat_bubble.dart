import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/message_model.dart';
import '../cubit/chat_cubit.dart';

// âœ… Ù‚Ø§Ø¦Ù…Ø© ÙƒØ§Ù…Ù„Ø© Ù…Ù† Ø§Ù„Ù€ emojis Ù„Ù„Ù€ picker
const List<String> _allEmojis = [
  'ðŸ˜€','ðŸ“','â¤ï¸','ðŸ‘','ðŸ‘Ž','ðŸ”¥','ðŸ¥°','ðŸ‘',
  'ðŸ¤”','ðŸ¤¯','ðŸ˜±','ðŸ¤¬','ðŸ˜¢','ðŸŽ‰','ðŸ¤©','ðŸ¤®',
  'ðŸ’©','ðŸ™','ðŸ‘Œ','ðŸ•Šï¸','ðŸ¤¡','ðŸ¤­','ðŸ˜œ','ðŸ˜',
  'ðŸ³','ðŸ’”','ðŸ˜¶','ðŸŒ­','ðŸ’¯','ðŸ¤£','âš¡','ðŸŒ',
  'ðŸ†','ðŸ’”','ðŸ˜‘','ðŸ˜','ðŸ¾','ðŸ’‹','ðŸ–•','ðŸ˜ˆ',
  'ðŸ˜´','ðŸ˜­','ðŸ¤“','ðŸ‘»','ðŸ‘¨â€ðŸ’»','ðŸ‘€','ðŸŽƒ','ðŸ™ˆ',
  'ðŸ˜…','ðŸ˜‚','ðŸ¤—','ðŸ˜Ž','ðŸ¥³','ðŸ˜‡','ðŸ¤«','ðŸ«¡',
  'ðŸ’€','ðŸ«¶','ðŸ¤','âœŠ','ðŸ‘Š','ðŸ« ','ðŸ¥¹','ðŸ˜¤',
];

class ChatBubble extends StatefulWidget {
  final Message message;
  final Function(Message)? onReply;
  final Function(String)? onTapReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String)? onReact;
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
  bool isPlaying = false;
  bool isPressed = false;
  late AnimationController _waveController;

  // âœ… Ø§Ù„Ù€ emojis Ø§Ù„Ø£Ø³Ø§Ø³ÙŠØ© ÙÙŠ Ø§Ù„Ù€ reactions bar
  static const List<String> _quickEmojis = ['ðŸ˜€', 'ðŸ“', 'â¤ï¸', 'ðŸ‘', 'ðŸ‘Ž', 'ðŸ”¥', 'ðŸ¥°'];

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
    _waveController.stop();
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _waveController.repeat();
      } else {
        _waveController.stop();
      }
    });
  }

  // âœ… ÙØªØ­ Ø§Ù„Ù€ emoji picker Ø§Ù„ÙƒØ§Ù…Ù„ Ø¨Ù†ÙØ³ Ø§Ù„Ù€ glassmorphism style
  void _showFullEmojiPicker(BuildContext rootContext) {
    showGeneralDialog(
      context: rootContext,
      barrierDismissible: true,
      barrierLabel: 'EmojiPicker',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, animation, _) {
        return Stack(
          children: [
            // âœ… Ø§Ø¶ØºØ· Ø¨Ø±Ø§ ÙŠÙ‚ÙÙ„
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(color: Colors.transparent),
              ),
            ),
            // âœ… Ø§Ù„Ù€ picker Ù†ÙØ³Ù‡ ÙÙŠ Ø§Ù„Ù†Øµ
            Center(
              child: ScaleTransition(
                scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                child: FadeTransition(
                  opacity: animation,
                  child: _buildGlassEmojiPicker(ctx),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlassEmojiPicker(BuildContext ctx) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 320,
          constraints: const BoxConstraints(maxHeight: 420),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0).withOpacity(0.18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // âœ… Ù‡ÙŠØ¯Ø± Ø§Ù„Ù€ picker
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Ø§Ø®ØªØ± ØªÙØ§Ø¹Ù„Ø§Ù‹',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                // âœ… Ø§Ù„Ù€ grid Ù…Ù† Ø§Ù„Ù€ emojis
                Flexible(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemCount: _allEmojis.length,
                    itemBuilder: (_, i) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx); // âœ… Ø§Ù‚ÙÙ„ Ø§Ù„Ù€ picker
                          Navigator.pop(ctx); // âœ… Ø§Ù‚ÙÙ„ Ø§Ù„Ù€ action menu
                          widget.onReact?.call(_allEmojis[i]);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withOpacity(0.04),
                          ),
                          child: Center(
                            child: Text(
                              _allEmojis[i],
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    final isMe = widget.message.isMe;

    // âœ… SECURITY: Ù…Ø´ Ø¨Ù†Ø¹Ø±Ø¶ Ù‚Ø§Ø¦Ù…Ø© Ù„Ùˆ Ø§Ù„Ù€ message Ù…Ø´ Ø¹Ù†Ø¯Ù‡Ø§ id
    if (widget.message.id == null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    double topPosition = offset.dy - 130;
    if (topPosition < 60) {
      topPosition = offset.dy + renderBox.size.height + 10;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogCtx, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(dialogCtx),
                child: Container(color: Colors.transparent),
              ),
            ),

            Positioned(
              top: topPosition,
              left: isMe ? null : 24,
              right: isMe ? 24 : null,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: Column(
                    crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // âœ… ØµÙ Ø§Ù„Ù€ emojis + Ø²Ø± Ø§Ù„ØªÙˆØ³ÙŠØ¹
                      _buildSilverGlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ø§Ù„Ù€ emojis Ø§Ù„Ø£Ø³Ø§Ø³ÙŠØ©
                            ..._quickEmojis.map((emoji) {
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(dialogCtx);
                                  widget.onReact?.call(emoji);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              );
                            }),

                            // âœ… Ø²Ø± Ø§Ù„ØªÙˆØ³ÙŠØ¹ Ë…
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                // âœ… Ù…Ø´ Ø¨Ù†Ù‚ÙÙ„ Ø§Ù„Ù€ action menu Ø¹Ø´Ø§Ù† Ø§Ù„Ù€ picker ÙŠØ±Ø¬Ø¹Ù„Ù‡
                                _showFullEmojiPicker(dialogCtx);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.expand_more_rounded,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // âœ… Ù‚Ø§Ø¦Ù…Ø© Ø§Ù„Ø®ÙŠØ§Ø±Ø§Øª
                      _buildSilverGlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        width: 200,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFloatingMenuItem(
                              icon: Icons.reply_rounded,
                              title: 'Ø±Ø¯',
                              onTap: () {
                                Navigator.pop(dialogCtx);
                                widget.onReply?.call(widget.message);
                              },
                            ),
                            _buildDivider(),
                            _buildFloatingMenuItem(
                              icon: Icons.copy_rounded,
                              title: 'Ù†Ø³Ø®',
                              onTap: () {
                                Navigator.pop(dialogCtx);
                                // âœ… SECURITY: Ù†Ø³Ø® Ù†Øµ ÙØ§Ø¶ÙŠ Ù…Ø´ Ù…ÙÙŠØ¯
                                if (widget.message.text.isNotEmpty) {
                                  Clipboard.setData(
                                      ClipboardData(text: widget.message.text));
                                }
                              },
                            ),
                            if (isMe) ...[
                              if (widget.message.type == MessageType.text) ...[
                                _buildDivider(),
                                _buildFloatingMenuItem(
                                  icon: Icons.edit_rounded,
                                  title: 'ØªØ¹Ø¯ÙŠÙ„',
                                  onTap: () {
                                    Navigator.pop(dialogCtx);
                                    widget.onEdit?.call();
                                  },
                                ),
                              ],
                              _buildDivider(),
                              _buildFloatingMenuItem(
                                icon: Icons.delete_outline_rounded,
                                title: 'Ø­Ø°Ù',
                                color: Colors.redAccent.withOpacity(0.9),
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

  Widget _buildDivider() => const Divider(color: Colors.white12, height: 1, thickness: 0.5);

  Widget _buildSilverGlassCard({
    required Widget child,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0).withOpacity(0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(
              title,
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

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTapDown: (_) {
            setState(() => isPressed = true);
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showActionMenu(context);
          },
          child: AnimatedScale(
            scale: isPressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 90),
            child: _bubble(context, isMe),
          ),
        ),
      ],
    );
  }

  Widget _bubble(BuildContext context, bool isMe) {
    final message = widget.message;
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
      margin: const EdgeInsets.symmetric(vertical: 1.5),
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: isMe ? const Color(0xFF4186F6) : const Color(0xFF2B2C31),
          ),
          child: Stack(
            children: [
              if (widget.isHighlighted)
                Positioned.fill(
                  child: Container(color: Colors.white.withOpacity(0.04)),
                ),
              Padding(
                padding: message.type == MessageType.image
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: message.type == MessageType.image
                    ? _imageWithTime(time, radius)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (message.replyTo != null) _replyPreview(),
                          if (message.type == MessageType.voice)
                            _voice()
                          else
                            _text(),
                          const SizedBox(height: 4),
                          _timeRow(time, isMe),
                        ],
                      ),
              ),
              // âœ… Ø¹Ø±Ø¶ Ø§Ù„Ù€ reactions Ø§Ù„Ù…ÙˆØ¬ÙˆØ¯Ø© Ø¹Ù„Ù‰ Ø§Ù„Ø±Ø³Ø§Ù„Ø©
              if (message.reactions != null && message.reactions!.isNotEmpty)
                Positioned(
                  bottom: -10,
                  right: isMe ? 8 : null,
                  left: isMe ? null : 8,
                  child: _buildReactionsDisplay(message.reactions!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // âœ… Ø¹Ø±Ø¶ Ø§Ù„Ù€ reactions Ø¹Ù„Ù‰ Ø§Ù„Ù€ bubble
  Widget _buildReactionsDisplay(Map<String, String> reactions) {
    // Ù†Ø¬Ù…Ø¹ Ø§Ù„Ù€ emojis Ø§Ù„Ù…ØªÙƒØ±Ø±Ø© Ù…Ø¹ Ø¹Ø¯Ø¯Ù‡Ø§
    final Map<String, int> counts = {};
    for (final emoji in reactions.values) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: counts.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  e.value > 1 ? '${e.key} ${e.value}' : e.key,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  Widget _replyPreview() {
    final reply = widget.message.replyTo!;
    final isMe = reply.isMe;

    String previewText;
    if (reply.type == MessageType.image) {
      previewText = "ðŸ“· Photo";
    } else if (reply.type == MessageType.voice) {
      previewText = "ðŸŽ¤ Voice message";
    } else {
      previewText = reply.text;
    }

    return GestureDetector(
      onTap: () {
        final replyId = widget.message.replyToId;
        if (replyId != null) widget.onTapReply?.call(replyId);
      },
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
                  color: isMe ? const Color(0xFF0A84FF) : Colors.grey.shade600,
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

  Widget _text() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.5,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (widget.message.isEdited == true)
          const Text(
            "ØªÙ… Ø§Ù„ØªØ¹Ø¯ÙŠÙ„",
            style: TextStyle(color: Colors.white38, fontSize: 10),
          ),
      ],
    );
  }

  Widget _imageWithTime(String time, BorderRadius radius) {
    return Stack(
      children: [
        Image.network(
          widget.message.imageUrl!,
          height: 160,
          width: 240,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 160,
            width: 240,
            color: Colors.white10,
            child: const Icon(Icons.broken_image_outlined,
                color: Colors.white38, size: 40),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 160,
              width: 240,
              color: Colors.white10,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white38,
                ),
              ),
            );
          },
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

  Widget _voice() {
    final duration = widget.message.voiceDuration != null
        ? _formatDuration(widget.message.voiceDuration!)
        : "â€”:â€”â€”";

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
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
            animation: _waveController,
            builder: (_, __) {
              return Row(
                children: List.generate(14, (i) {
                  final phase = (_waveController.value + i * 0.07) % 1.0;
                  final h = isPlaying
                      ? 4 + (phase < 0.5 ? phase : 1 - phase) * 18
                      : _staticHeight(i);
                  final t = i / 13;
                  final color = Color.lerp(
                    const Color(0xFF0A84FF),
                    const Color(0xFF5AC8FA),
                    t,
                  )!
                      .withOpacity(isPlaying ? 1.0 : 0.5);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 2.3,
                    height: h,
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

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  double _staticHeight(int i) {
    final h = [6, 12, 18, 8, 22, 14, 20, 6, 16, 24, 10, 20, 8, 18];
    return h[i % h.length].toDouble();
  }

  Widget _timeRow(String time, bool isMe) {
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
          _statusIcon(),
        ],
      ],
    );
  }

  Widget _statusIcon() {
    IconData icon;
    Color color;

    switch (widget.message.status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.white24;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white24;
        break;
      case MessageStatus.seen:
        icon = Icons.done_all;
        color = const Color(0xFF0A84FF);
        break;
    }

    return Icon(icon, size: 13, color: color);
  }
}
