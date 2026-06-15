// ============================================================
// chat_input.dart — ChatX Premium Message Input Bar
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chatx/screens/chat/models/message_model.dart';

// --- Constants & Styles ---
class _Style {
  // تم تغيير اللون إلى أزرق احترافي مريح للعين بدلاً من السيان
  static const Color accentColor = Color(0xFF007AFF); 
  static const Color textColor = Colors.white;
  static const Color hintTextColor = Colors.white38;
  static const Color backgroundColor = Colors.black;
  static const Color iconColor = Colors.white54;
  
  static const double borderRadius = 28.0;
  static const double compactVerticalPadding = 6.0;
  static const double iconSize = 22.0;
  static const double inputFontSize = 14.0;
}

class ChatInput extends StatefulWidget {
  final Function(String text, String? replyId) onSend;
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
  final FocusNode _focusNode = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _sendAnimation;

  bool _hasText = false;
  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _sendAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText == _hasText) return; 
    
    setState(() => _hasText = hasText);
    
    if (hasText) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text, widget.replyMessage?.id);
    _controller.clear();
    widget.onCancelReply?.call();
    _focusNode.requestFocus();
  }

  void _toggleEmoji() {
    setState(() => _showEmoji = !_showEmoji);
    if (_showEmoji) {
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  // --- Build ---
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.replyMessage != null)
          _ReplyPreviewWidget(
            message: widget.replyMessage!,
            onCancel: widget.onCancelReply,
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_Style.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: _Style.compactVerticalPadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_Style.borderRadius),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  // تم تعديل المحاذاة هنا لتوسيط العناصر بشكل مثالي
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    const _AttachButtonWidget(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TextFieldWidget(
                        controller: _controller,
                        focusNode: _focusNode,
                        onEmojiToggle: _toggleEmoji,
                        showEmoji: _showEmoji,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SendOrMicButtonWidget(
                      hasText: _hasText,
                      animation: _sendAnimation,
                      onSend: _send,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        if (_showEmoji)
          _EmojiPanelWidget(
            onEmojiSelected: (emoji) {
              final sel = _controller.selection;
              final text = _controller.text;
              final newText = sel.isValid
                  ? text.replaceRange(sel.start, sel.end, emoji)
                  : text + emoji;
              _controller.value = _controller.value.copyWith(
                text: newText,
                selection: TextSelection.collapsed(
                  offset: (sel.isValid ? sel.start : text.length) + emoji.length,
                ),
              );
            },
          ),
      ],
    );
  }
}

// --- TextField ---
class _TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onEmojiToggle;
  final bool showEmoji;

  const _TextFieldWidget({
    required this.controller,
    required this.focusNode,
    required this.onEmojiToggle,
    required this.showEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(_Style.borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 4,
              minLines: 1,
              style: const TextStyle(color: _Style.textColor, fontSize: _Style.inputFontSize),
              cursorColor: _Style.accentColor,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                // تم التعديل للإنجليزية
                hintText: 'Message...', 
                hintStyle: TextStyle(color: _Style.hintTextColor, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
            ),
          ),
          
          GestureDetector(
            onTap: onEmojiToggle,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                showEmoji ? Icons.keyboard_rounded : Icons.emoji_emotions_outlined,
                key: ValueKey(showEmoji),
                color: showEmoji ? _Style.accentColor : _Style.iconColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// --- Send / Mic Button ---
class _SendOrMicButtonWidget extends StatelessWidget {
  final bool hasText;
  final Animation<double> animation;
  final VoidCallback onSend;

  const _SendOrMicButtonWidget({
    required this.hasText,
    required this.animation,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: anim, child: child),
      ),
      child: hasText
          ? GestureDetector(
              key: const ValueKey('send_active'),
              onTap: onSend,
              child: ScaleTransition(
                scale: animation,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _Style.accentColor,
                    // لمسة ظل خفيفة تعطي إحساس الـ Premium
                    boxShadow: [
                      BoxShadow(
                        color: _Style.accentColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                ),
              ),
            )
          : const Padding(
              key: ValueKey('mic_inactive'),
              padding: EdgeInsets.only(bottom: 0), // تم تصفير الـ padding لضبط المحاذاة مع السنتر
              child: Icon(
                Icons.mic_none_rounded,
                color: _Style.iconColor,
                size: _Style.iconSize,
              ),
            ),
    );
  }
}

// --- Reply Preview ---
class _ReplyPreviewWidget extends StatelessWidget {
  final Message message;
  final VoidCallback? onCancel;

  const _ReplyPreviewWidget({required this.message, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final String previewText;
    switch (message.type) {
      case MessageType.image: previewText = '📷 Photo'; break;
      case MessageType.voice: previewText = '🎤 Voice message'; break;
      case MessageType.text: previewText = message.text; break;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.04),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 3, height: 32,
                  decoration: BoxDecoration(color: _Style.accentColor, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.senderName ?? 'Unknown',
                        style: const TextStyle(color: _Style.accentColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        previewText, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close_rounded, color: Colors.white54, size: 16),
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

// --- Attach Button "New" ---
class _AttachButtonWidget extends StatelessWidget {
  const _AttachButtonWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      // تم إزالة الـ margin السفلي لضبط المحاذاة مع الـ center
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_rounded, color: Colors.white60, size: 14),
          SizedBox(width: 2),
          Text('New', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// --- Emoji Panel (Placeholder) ---
class _EmojiPanelWidget extends StatelessWidget {
  final Function(String emoji) onEmojiSelected;

  const _EmojiPanelWidget({required this.onEmojiSelected});

  static const _quickEmojis = [
    '😀','😂','😍','😭','🤩','😎','🥳','😢',
    '😊','👍','👎','❤️','🔥','🎉','✨','💯',
    '🤔','😋','🙄','🙏','🤝','💪','👀','🤫',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 8),
            width: 32, height: 3,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, mainAxisSpacing: 4, crossAxisSpacing: 4,
              ),
              itemCount: _quickEmojis.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => onEmojiSelected(_quickEmojis[i]),
                child: Center(child: Text(_quickEmojis[i], style: const TextStyle(fontSize: 22))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
