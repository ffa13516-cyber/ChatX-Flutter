import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_model.dart';

class ChatBubble extends StatefulWidget {
  final Message message;

  final Function(Message)? onReply;
  final Function(String)? onTapReply;

  final bool isHighlighted;

  const ChatBubble({
    super.key,
    required this.message,
    this.onReply,
    this.onTapReply,
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
            widget.onReply?.call(widget.message);
          },
          child: AnimatedScale(
            scale: isPressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 100),
            child: _bubble(context, isMe),
          ),
        ),
      ],
    );
  }

  Widget _bubble(BuildContext context, bool isMe) {
    final message = widget.message;

    final time =
        "${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}";

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
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          if (widget.isHighlighted)
            BoxShadow(
              color: const Color(0xFF00E6FF).withOpacity(0.35),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          padding: message.type == MessageType.image
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: radius,

            // ✅ التعديل الوحيد هنا 👇
            color: isMe ? null : const Color(0xFF2A2A2A),

            // 🔥 overlay highlight
            foregroundDecoration: widget.isHighlighted
                ? BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                  )
                : null,

            gradient: isMe
                ? const LinearGradient(
                    colors: [
                      Color(0xFF007AFF),
                      Color(0xFF00C6FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
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
      ),
    );
  }

  // 👇 كل اللي تحت زي ما هو بدون أي تغيير

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
        if (replyId != null) {
          widget.onTapReply?.call(replyId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 34,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF0A84FF) : Colors.grey,
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
                        color:
                            isMe ? const Color(0xFF5AC8FA) : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    previewText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _text() {
    return Text(
      widget.message.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15.5,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _imageWithTime(String time, BorderRadius radius) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: radius,
          child: Image.network(
            widget.message.imageUrl!,
            height: 160,
            width: 240,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 8,
          right: 10,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _voice() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
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
                  )!.withOpacity(isPlaying ? 1.0 : 0.6);

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 1),
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
        const Text(
          "2:45",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  double _staticHeight(int i) {
    final h = [
      6, 12, 18, 8, 22,
      14, 20, 6, 16, 24,
      10, 20, 8, 18
    ];
    return h[i % h.length].toDouble();
  }

  Widget _timeRow(String time, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 11,
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
