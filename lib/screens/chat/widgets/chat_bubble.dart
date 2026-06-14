import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_model.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final Function(Message)? onReply;
  final Function(String)? onTapReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isHighlighted;

  const ChatBubble({
    super.key,
    required this.message,
    this.onReply,
    this.onTapReply,
    this.onEdit,
    this.onDelete,
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
    // ✅ لو الـ animation لسه شغالة نوقفها قبل الـ dispose عشان نتجنب errors
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

  void _showActionMenu(BuildContext context) {
    final isMe = widget.message.isMe;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuItem(
                  icon: Icons.reply_rounded,
                  title: 'رد',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onReply?.call(widget.message);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.copy_rounded,
                  title: 'نسخ',
                  onTap: () {
                    Navigator.pop(context);
                    Clipboard.setData(
                        ClipboardData(text: widget.message.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تم النسخ"),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                if (isMe) ...[
                  const Divider(color: Colors.white12, height: 1),
                  // ✅ FIX: زر التعديل بيظهر بس لو الرسالة نصية مش صورة أو صوت
                  if (widget.message.type == MessageType.text)
                    _buildMenuItem(
                      icon: Icons.edit_rounded,
                      title: 'تعديل',
                      onTap: () {
                        Navigator.pop(context);
                        widget.onEdit?.call();
                      },
                    ),
                  _buildMenuItem(
                    icon: Icons.delete_outline_rounded,
                    title: 'حذف',
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onDelete?.call();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        title,
        style: TextStyle(
            color: color, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;

    return Row(
      mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
            scale: isPressed ? 0.98 : 1,
            duration: const Duration(milliseconds: 100),
            child: _bubble(context, isMe),
          ),
        ),
      ],
    );
  }

  Widget _bubble(BuildContext context, bool isMe) {
    final message = widget.message;

    // ✅ FIX #8: بنستخدم الـ timestamp من Firebase مش device time
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
            color: isMe
                ? const Color(0xFF4186F6)
                : const Color(0xFF2B2C31),
          ),
          child: Stack(
            children: [
              if (widget.isHighlighted)
                Positioned.fill(
                  child: Container(
                      color: Colors.white.withOpacity(0.04)),
                ),
              Padding(
                padding: message.type == MessageType.image
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
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
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIX #8: دالة format للوقت تتعامل مع الـ server timestamp صح
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
      previewText = "📷 Photo";
    } else if (reply.type == MessageType.voice) {
      previewText = "🎤 Voice message";
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
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
        // ✅ FIX: لو الرسالة اتعدلت نبين علامة "تم التعديل"
        if (widget.message.isEdited == true)
          const Text(
            "تم التعديل",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
      ],
    );
  }

  Widget _imageWithTime(String time, BorderRadius radius) {
    return Stack(
      children: [
        // ✅ FIX: error builder لو الصورة مش موجودة
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
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _voice() {
    // ✅ FIX #9: بنعرض المدة الحقيقية من الـ model لو موجودة
    final duration = widget.message.voiceDuration != null
        ? _formatDuration(widget.message.voiceDuration!)
        : "—:——";

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
                  final phase =
                      (_waveController.value + i * 0.07) % 1.0;
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

  // ✅ FIX #9: format حقيقي للمدة
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
