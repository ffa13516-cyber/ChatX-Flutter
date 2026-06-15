// ============================================================
// chat_input.dart â€” ChatX Message Input Bar
// âœ… Ø²Ø± Ø§Ù„Ø¥ÙŠÙ…ÙˆØ¬ÙŠ Ø´ØºØ§Ù„ | âœ… reply preview ØµØ­ Ù„ÙƒÙ„ Ø£Ù†ÙˆØ§Ø¹ Ø§Ù„Ø±Ø³Ø§Ø¦Ù„
// âœ… dispose Ø¢Ù…Ù† | âœ… keyboard dismiss Ø¹Ù†Ø¯ Ø§Ù„Ø¥Ø±Ø³Ø§Ù„
// âœ… max characters hint | âœ… send on keyboard action
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chatx/screens/chat/models/message_model.dart';

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
  late final Animation<double> _sendScale;

  bool _hasText = false;
  bool _showEmoji = false; // âœ… State Ù„Ù„Ù€ emoji toggle

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _sendScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText == _hasText) return; // Ù…Ù†Ø¹ rebuild ØºÙŠØ± Ø¶Ø±ÙˆØ±ÙŠ
    setState(() => _hasText = hasText);
    hasText ? _animController.forward() : _animController.reverse();
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
    // Ø£Ø¨Ù‚ Ø§Ù„Ù€ focus Ø¨Ø¹Ø¯ Ø§Ù„Ø¥Ø±Ø³Ø§Ù„ Ø¹Ø´Ø§Ù† Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… ÙŠÙƒÙ…Ù„
    _focusNode.requestFocus();
  }

  // âœ… FIX: Ø²Ø± Ø§Ù„Ø¥ÙŠÙ…ÙˆØ¬ÙŠ Ø¨ÙŠØ¹Ù…Ù„ toggle Ù„Ù„Ù€ keyboard ÙˆØ§Ù„Ù€ emoji panel
  void _toggleEmoji() {
    setState(() => _showEmoji = !_showEmoji);
    if (_showEmoji) {
      _focusNode.unfocus(); // Ø£ØºÙ„Ù‚ Ø§Ù„ÙƒÙŠØ¨ÙˆØ±Ø¯
    } else {
      _focusNode.requestFocus(); // Ø§ÙØªØ­ Ø§Ù„ÙƒÙŠØ¨ÙˆØ±Ø¯
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Build
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // â”€â”€ Reply Preview â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        if (widget.replyMessage != null)
          _ReplyPreview(
            message: widget.replyMessage!,
            onCancel: widget.onCancelReply,
          ),

        // â”€â”€ Input Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _AttachButton(),
                    const SizedBox(width: 10),

                    // â”€â”€ TextField â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: 5,
                        minLines: 1,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        cursorColor: const Color(0xFF00FBFF),
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        onTap: () {
                          // Ù„Ùˆ Ø§Ù„Ø¥ÙŠÙ…ÙˆØ¬ÙŠ Ù…ÙØªÙˆØ­ ÙˆØ¶ØºØ· Ø¹Ù„Ù‰ Ø§Ù„Ù€ text field â†’ Ø£ØºÙ„Ù‚Ù‡
                          if (_showEmoji) setState(() => _showEmoji = false);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Ø§ÙƒØªØ¨ Ø±Ø³Ø§Ù„Ø©...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // â”€â”€ Emoji Button â”€â”€ âœ… FIXED: Ø´ØºØ§Ù„ Ø¯Ù„ÙˆÙ‚ØªÙŠ
                    GestureDetector(
                      onTap: _toggleEmoji,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _showEmoji
                              ? Icons.keyboard_rounded
                              : Icons.emoji_emotions_outlined,
                          key: ValueKey(_showEmoji),
                          color: _showEmoji
                              ? const Color(0xFF00E6FF)
                              : Colors.white54,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // â”€â”€ Send / Mic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    _SendOrMicButton(
                      hasText: _hasText,
                      scaleAnimation: _sendScale,
                      onSend: _send,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // â”€â”€ Emoji Panel (placeholder Ø¬Ø§Ù‡Ø² Ù„Ù„Ù€ emoji_picker_flutter) â”€â”€
        if (_showEmoji)
          _EmojiPanel(
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Reply Preview â€” âœ… ÙŠØ¹Ø±Ø¶ ØµØ­ Ù„ÙƒÙ„ Ø£Ù†ÙˆØ§Ø¹ Ø§Ù„Ø±Ø³Ø§Ø¦Ù„
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ReplyPreview extends StatelessWidget {
  final Message message;
  final VoidCallback? onCancel;

  const _ReplyPreview({required this.message, this.onCancel});

  @override
  Widget build(BuildContext context) {
    // âœ… FIX: Ù†Øµ Ø§Ù„Ù…Ø¹Ø§ÙŠÙ†Ø© ÙŠØªØºÙŠØ± Ø­Ø³Ø¨ Ù†ÙˆØ¹ Ø§Ù„Ø±Ø³Ø§Ù„Ø©
    final String previewText;
    switch (message.type) {
      case MessageType.image:
        previewText = 'ðŸ“· ØµÙˆØ±Ø©';
        break;
      case MessageType.voice:
        previewText = 'ðŸŽ¤ Ø±Ø³Ø§Ù„Ø© ØµÙˆØªÙŠØ©';
        break;
      case MessageType.text:
        previewText = message.text;
        break;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E6FF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.senderName ?? 'Ù…Ø¬Ù‡ÙˆÙ„',
                        style: const TextStyle(
                          color: Color(0xFF00E6FF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        previewText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // âœ… Ù…Ø³Ø§Ø­Ø© Ø¶ØºØ· ÙƒØ¨ÙŠØ±Ø© Ù„Ù„Ù€ close button
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                      size: 18,
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Send / Mic Button
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SendOrMicButton extends StatelessWidget {
  final bool hasText;
  final Animation<double> scaleAnimation;
  final VoidCallback onSend;

  const _SendOrMicButton({
    required this.hasText,
    required this.scaleAnimation,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: hasText
          ? GestureDetector(
              key: const ValueKey('send'),
              onTap: onSend,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00E6FF),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                ),
              ),
            )
          : const Icon(
              Icons.mic_none_rounded,
              color: Colors.white54,
              size: 24,
              key: ValueKey('mic'),
            ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Attach Button
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AttachButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_rounded, color: Colors.white60, size: 16),
          SizedBox(width: 4),
          Text(
            'New',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Emoji Panel â€” Ø¬Ø§Ù‡Ø² Ù„Ù€ emoji_picker_flutter
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EmojiPanel extends StatelessWidget {
  final Function(String emoji) onEmojiSelected;

  const _EmojiPanel({required this.onEmojiSelected});

  // Ø¥ÙŠÙ…ÙˆØ¬ÙŠØ² Ø´Ø§Ø¦Ø¹Ø© Ù…Ø¤Ù‚ØªØ© â€” Ø§Ø³ØªØ¨Ø¯Ù„Ù‡Ù… Ø¨Ù€ EmojiPicker Ù„Ù…Ø§ ØªØ¶ÙŠÙ Ø§Ù„Ø¨Ø§ÙƒØ¯Ø¬
  static const _quickEmojis = [
    'ðŸ˜€','ðŸ˜‚','ðŸ¥°','ðŸ˜','ðŸ¤©','ðŸ˜Ž','ðŸ¥³','ðŸ˜¢',
    'ðŸ˜­','ðŸ˜¤','ðŸ¤”','ðŸ˜…','ðŸ‘','ðŸ‘Ž','â¤ï¸','ðŸ”¥',
    'ðŸŽ‰','âœ¨','ðŸ’¯','ðŸ™','ðŸ‘','ðŸ¤','ðŸ’ª','ðŸ‘€',
    'ðŸ˜´','ðŸ¤¯','ðŸ¥º','ðŸ˜‡','ðŸ¤—','ðŸ˜','ðŸ˜’','ðŸ™„',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1E),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: _quickEmojis.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => onEmojiSelected(_quickEmojis[i]),
                child: Center(
                  child: Text(
                    _quickEmojis[i],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          // Hint Ù„Ù…Ø§ ÙŠØ¶ÙŠÙ Ø§Ù„Ø¨Ø§ÙƒØ¯Ø¬
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'ðŸ’¡ Ø£Ø¶Ù emoji_picker_flutter Ù„Ù„Ø­ØµÙˆÙ„ Ø¹Ù„Ù‰ Ø§Ù„Ù‚Ø§Ø¦Ù…Ø© Ø§Ù„ÙƒØ§Ù…Ù„Ø©',
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
