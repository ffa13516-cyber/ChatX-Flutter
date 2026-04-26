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
      if (_controller.text.isNotEmpty) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
      setState(() {}); // مهم عشان opacity يتحدث
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;

    widget.onSend(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                _icon(Icons.add),

                const SizedBox(width: 6),

                /// ✍️ TextField
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: "Message...",
                      hintStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                /// 🎤 mic
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _controller.text.isEmpty ? 1 : 0,
                  child: _icon(Icons.mic),
                ),

                /// 🚀 send
                ScaleTransition(
                  scale: _scale,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _controller.text.isNotEmpty ? 1 : 0,
                    child: GestureDetector(
                      onTap: _send,
                      child: Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF60A5FA).withOpacity(0.9),
                              const Color(0xFF3B82F6).withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6)
                                  .withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
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

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
      ),
      child: Icon(
        icon,
        color: Colors.white.withOpacity(0.65),
        size: 18,
      ),
    );
  }
}
