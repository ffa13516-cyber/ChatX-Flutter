import 'package:flutter/material.dart';
import '../models/emoji_model.dart';
import '../parsers/message_parser.dart';

class InlineEmojiText extends StatelessWidget {
  final String text;
  final Map<String, EmojiModel> emojiMap;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const InlineEmojiText({
    super.key,
    required this.text,
    required this.emojiMap,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final spans = MessageParser.parse(
      text: text,
      emojiMap: emojiMap,
      style: style,
    );

    return RichText(
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(
        children: spans,
        style: style ?? DefaultTextStyle.of(context).style,
      ),
    );
  }
}
