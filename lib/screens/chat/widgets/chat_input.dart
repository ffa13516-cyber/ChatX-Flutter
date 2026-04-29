import 'dart:ui';
import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  const ChatInput({super.key, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scale;

  bool get _hasText => _controller.text.trim().isNotEmpty;

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
    widget.onSend(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),

              /// نفس vibe الهيدر
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _newButton(),

                const SizedBox(width: 8),

                /// INPUT
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
                          EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                /// 🎤 / SEND (نفس المكان)
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
                      : _iconButton(Icons.mic, key: const ValueKey("mic")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _newButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.white38, size: 20),
    );
  }
}
