import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/message_model.dart';

// 🆕🔥
import '../services/emoji_service.dart';
import '../pickers/emoji_sticker_picker.dart';

class ChatInput extends StatefulWidget {
  final Function(String, String?) onSend;

  final Message? replyMessage;
  final VoidCallback? onCancelReply;

  const ChatInput({
    super.key,
    required this.onSend,
    this.replyMessage,
    this.onCancelReply,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scale;

  bool get _hasText => _controller.text.trim().isNotEmpty;

  final emojiService = EmojiService();

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _controller.addListener(() {
      if (_hasText) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _send() {
    if (!_hasText) return;

    widget.onSend(
      _controller.text.trim(),
      widget.replyMessage?.id,
    );

    _controller.clear();
    widget.onCancelReply?.call();
  }

  void insertEmoji(String code) {
    final text = _controller.text;
    final selection = _controller.selection;

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      "$code ",
    );

    _controller.text = newText;

    _controller.selection = TextSelection.collapsed(
      offset: selection.start + code.length + 1,
    );
  }

  /// 🔥🔥🔥 التعديل الوحيد الحقيقي
  void sendSticker(String path) {
    widget.onSend(
      "[sticker]$path", // 👈 هنا السحر
      widget.replyMessage?.id,
    );

    widget.onCancelReply?.call();
  }

  void _sendCustom({
    String text = "",
    MessageType type = MessageType.text,
    String? imageUrl,
  }) {
    widget.onSend(
      text,
      widget.replyMessage?.id,
    );

    widget.onCancelReply?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.replyMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Builder(
                  builder: (context) {
                    final reply = widget.replyMessage!;

                    String previewText;
                    if (reply.type == MessageType.image) {
                      previewText = "📷 Photo";
                    } else if (reply.type == MessageType.voice) {
                      previewText = "🎤 Voice message";
                    } else {
                      previewText = reply.text;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E6FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (reply.senderName != null)
                                  Text(
                                    reply.senderName!,
                                    style: const TextStyle(
                                      color: Color(0xFF00E6FF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  previewText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onCancelReply,
                            child: const Icon(
                              Icons.close,
                              color: Colors.white54,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.10),
                      Colors.white.withOpacity(0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _newButton(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        cursorColor: const Color(0xFF00FBFF),
                        decoration: const InputDecoration(
                          hintText: "Type Message...",
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 🔥 picker
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) {
                            return EmojiStickerPicker(
                              onEmojiSelected: (emoji) {
                                insertEmoji(emoji.code);
                              },
                              onStickerSelected: (sticker) {
                                sendSticker(sticker.path);
                              },
                            );
                          },
                        );
                      },
                      child: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: _hasText
                          ? GestureDetector(
                              key: const ValueKey("send"),
                              onTap: _send,
                              child: ScaleTransition(
                                scale: _scale,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF00E6FF),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00E6FF)
                                            .withOpacity(0.4),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ),
                              ),
                            )
                          : _iconButton(Icons.mic,
                              key: const ValueKey("mic")),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _newButton() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.add, color: Colors.white60, size: 16),
          SizedBox(width: 4),
          Text(
            "New",
            style:
                TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.white54, size: 20),
    );
  }
}
