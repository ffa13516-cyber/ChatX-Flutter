import 'package:flutter/material.dart';
import '../models/emoji_model.dart';

class MessageParser {
  /// 🔥 Parser احترافي:
  /// - سريع (skip لو مفيش :)
  /// - non-greedy regex
  /// - scalable emoji size
  /// - safe fallback

  static final RegExp _regex = RegExp(r':(.*?):', multiLine: true);

  static List<InlineSpan> parse({
    required String text,
    required Map<String, EmojiModel> emojiMap,
    TextStyle? style,
  }) {
    // 🚀 تحسين الأداء: لو مفيش : خالص
    if (!text.contains(':')) {
      return [
        TextSpan(text: text, style: style),
      ];
    }

    final List<InlineSpan> spans = [];
    final matches = _regex.allMatches(text);

    int lastIndex = 0;

    for (final match in matches) {
      // ✏️ النص العادي
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
        /// 🟢 Unicode Emoji
        if (!emoji.isCustom && emoji.char != null) {
          spans.add(
            TextSpan(
              text: emoji.char,
              style: style,
            ),
          );
        }

        /// 🔵 Custom Emoji / Sticker
        else if (emoji.assetPath != null) {
          final fontSize = style?.fontSize ?? 16;

          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Image.asset(
                emoji.assetPath!,
                width: fontSize * 1.4,
                height: fontSize * 1.4,
                fit: BoxFit.contain,
              ),
            ),
          );
        }

        /// ⚠️ fallback
        else {
          spans.add(
            TextSpan(
              text: code,
              style: style,
            ),
          );
        }
      } else {
        /// ❌ unknown code
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
