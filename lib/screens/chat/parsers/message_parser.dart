import 'package:flutter/material.dart';
import '../models/emoji_model.dart';

class MessageParser {
  /// 🔥 يدعم:
  /// - Emoji عادي (❤️)
  /// - Custom Emoji (صورة)
  /// - Inline Sticker (صورة / GIF)
  static List<InlineSpan> parse({
    required String text,
    required Map<String, EmojiModel> emojiMap,
    TextStyle? style,
  }) {
    final List<InlineSpan> spans = [];

    final regex = RegExp(r':(.*?):'); // :emoji:
    final matches = regex.allMatches(text);

    int lastIndex = 0;

    for (final match in matches) {
      // ✏️ النص قبل العنصر
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

      if (emoji != null) {
        /// 🟢 1. Emoji عادي (Unicode)
        if (!emoji.isCustom && emoji.char != null) {
          spans.add(
            TextSpan(
              text: emoji.char,
              style: style,
            ),
          );
        }

        /// 🔵 2. Custom Emoji / Inline Sticker
        else if (emoji.assetPath != null) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Image.asset(
                emoji.assetPath!,
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              ),
            ),
          );
        }

        /// ⚠️ fallback لو الداتا ناقصة
        else {
          spans.add(
            TextSpan(
              text: code,
              style: style,
            ),
          );
        }
      } else {
        /// ❌ لو الكود مش معروف
        spans.add(
          TextSpan(
            text: code,
            style: style,
          ),
        );
      }

      lastIndex = match.end;
    }

    // ✏️ باقي النص
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
