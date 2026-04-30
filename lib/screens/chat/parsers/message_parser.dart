import 'package:flutter/material.dart';
import '../models/emoji_model.dart';

class MessageParser {
  /// 🔥 حوّل النص لـ TextSpan + ImageSpan
  static List<InlineSpan> parse({
    required String text,
    required Map<String, EmojiModel> emojiMap,
    TextStyle? style,
  }) {
    final List<InlineSpan> spans = [];

    final regex = RegExp(r':(.*?):'); // يلقط :emoji:
    final matches = regex.allMatches(text);

    int lastIndex = 0;

    for (final match in matches) {
      // النص قبل الإيموجي
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: style,
          ),
        );
      }

      final code = match.group(0)!; // :smile:

      final emoji = emojiMap[code];

      if (emoji != null && emoji.isCustom) {
        // 🔥 Custom Emoji → صورة
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Image.asset(
              emoji.assetPath!,
              width: 20,
              height: 20,
            ),
          ),
        );
      } else {
        // 🔥 fallback (لو مش موجود)
        spans.add(
          TextSpan(
            text: code,
            style: style,
          ),
        );
      }

      lastIndex = match.end;
    }

    // باقي النص
    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: style,
        ),
      );
    }

    return spans;
  }
}
