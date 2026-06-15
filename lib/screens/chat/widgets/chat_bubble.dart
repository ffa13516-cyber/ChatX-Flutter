import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message_model.dart';
// أول ما تضيف الباكدج في الـ pubspec.yaml، شيل علامة التعليق (//) من السطر اللي تحت ده:
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class ChatBubble extends StatefulWidget {
  final Message message;
  final Function(Message)? onReply;
  final Function(String)? onTapReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String)? onReact; // ✅ تم إضافة دالة التفاعل هنا
  final bool isHighlighted;

  const ChatBubble({
    super.key,
    required this.message,
    this.onReply,
    this.onTapReply,
    this.onEdit,
    this.onDelete,
    this.onReact, // ✅ وتم تمريرها في الكونسراكتور
    required this.isHighlighted,
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

  // ✅ دالة فتح قائمة الإيموجي الكاملة من الأسفل (Bottom Sheet)
  void _showEmojiPickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45, // بتاخذ 45% من طول الشاشة
          decoration: const BoxDecoration(
            color: Color(0xFF1E1F23), // لون داكن متناسق مع تصميمك
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // مؤشر السحب العلوي (الشرطة الخفيفة)
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // مكان باكدج الإيموجي الجاهزة
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Center(
                    child: Text(
                      "هنا هيتم عرض باكدج الـ Emoji Picker كاملاً 🎯",
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15),
                    ),
                    // 💡 أول ما تضيف الباكدج، تقدر تستبدل الـ Text اللي فوق بـ الـ Widget ده:
                    /*
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        Navigator.pop(context); // قفل البوتوم شيت
                        widget.onReact?.call(emoji.emoji); // إرسال الإيموجي المختار
                      },
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32,
                        backgroundColor: const Color(0xFF1E1F23),
                        indicatorColor: const Color(0xFF4186F6),
                        iconColor: Colors.grey,
                        iconColorSelected: const Color(0xFF4186F6),
                        backspaceColor: const Color(0xFF4186F6),
                        skinToneIndicatorColor: Colors.grey,
                        enableSkinTones: true,
                        recentsLimit: 20,
                        noRecents: const Text(
                          'لا توجد إيموجيز مستخدمة مؤخراً',
                          style: TextStyle(fontSize: 14, color: Colors.white24),
                          textAlign: TextAlign.center,
                        ),
                        loadingIndicator: const SizedBox.shrink(),
                        tabBarDisplayNameStyle: const TextStyle(color: Colors.white70),
                        categoryIcons: const CategoryIcons(),
                        buttonMode: ButtonMode.MATERIAL,
                      ),
                    ),
                    */
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔥 المحرك الذكي للمنيو العائمة
  void _showActionMenu(BuildContext context) {
    final isMe = widget.message.isMe;
    
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    double topPosition = offset.dy - 110;
    if (topPosition < 50) {
      topPosition = offset.dy + renderBox.size.height + 10;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black26, 
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
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
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // 1. صف الإيموجيز التفاعلي + سهم فتح الباكدجات كاملة
                      _buildSilverGlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // عرض الستة إيموجي الأساسيين
                            ...['❤️', '👍', '🔥', '😂', '😮', '😢'].map((emoji) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onReact?.call(emoji); // ✅ إرسال الإيموجي لملف اللوجيك
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              );
                            }).toList(),
                            
                            // ✅ زرار السهم الجديد (يكشف باقي الباكدجات)
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // قفل المنيو العائمة أولاً
                                _showEmojiPickerBottomSheet(context); // فتح قايمة الإيموجي الكاملة
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 4, right: 2),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded, // سهم لأسفل ذكي ومميز
                                  color: Colors.whiteEF,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 2. قائمة الخيارات الذكية
                      _buildSilverGlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        width: 190,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFloatingMenuItem(
                              icon: Icons.reply_rounded,
                              title: 'رد',
                              onTap: () {
                                Navigator.pop(context);
                                widget.onReply?.call(widget.message);
                              },
                            ),
                            _buildFloatingMenuItem(
                              icon: Icons.copy_rounded,
                              title: 'نسخ',
                              onTap: () {
                                Navigator.pop(context);
                                Clipboard.setData(ClipboardData(text: widget.message.text));
                              },
                            ),
                            if (isMe) ...[
                              if (widget.message.type == MessageType.text)
                                _buildFloatingMenuItem(
                                  icon: Icons.edit_rounded,
                                  title: 'تعديل',
                                  onTap: () {
                                    Navigator.pop(context);
                                    widget.onEdit?.call();
                                  },
                                ),
                              const Divider(color: Colors.white12, height: 1, thickness: 0.5),
                              _buildFloatingMenuItem(
                                icon: Icons.delete_outline_rounded,
                                title: 'حذف',
                                color: Colors.redAccent.withOpacity(0.9),
                                onTap: () {
                                  Navigator.pop(context);
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

  // ✅ الزجاج الفضي البلوري (تم تخفيف التشويش لراحة العين)
  Widget _buildSilverGlassCard({required Widget child, double? width, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), 
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0).withOpacity(0.25), 
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.25), 
              width: 1,
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(color: color, fontSize: 14.5, fontWeight: FontWeight.w500),
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
                          if (message.type == MessageType.voice) _voice() else _text(),
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
                          color: isMe ? const Color(0xFF5AC8FA) : Colors.white70,
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
        Image.network(
          widget.message.imageUrl!,
          height: 160,
          width: 240,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 160,
            width: 240,
            color: Colors.white10,
            child: const Icon(Icons.broken_image_outlined, color: Colors.white38, size: 40),
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
                  final phase = (_waveController.value + i * 0.07) % 1.0;
                  final h = isPlaying ? 4 + (phase < 0.5 ? phase : 1 - phase) * 18 : _staticHeight(i);
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
