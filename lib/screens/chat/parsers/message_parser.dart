import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../models/emoji_model.dart';

class MessageParser {
  static final RegExp _emojiRegex = RegExp(r':(.*?):', multiLine: true);

  static List<InlineSpan> parse({
    required String text,
    required Map<String, ChatXMedia> mediaMap,
    TextStyle? style,
    double scaleFactor = 1.3,
  }) {
    if (!text.contains(':')) {
      return [TextSpan(text: text, style: style)];
    }

    final List<InlineSpan> spans = [];
    final matches = _emojiRegex.allMatches(text);
    final double size = (style?.fontSize ?? 16) * scaleFactor;
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
      }

      final code = match.group(0)!;
      final media = mediaMap[code] ?? 
                    mediaMap.values.firstWhere((m) => m.label == match.group(1), 
                    orElse: () => ChatXMedia(id: '', packId: '', url: '', type: MediaType.emoji));

      if (media.id.isNotEmpty) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildMediaWidget(media, size),
        ));
      } else {
        spans.add(TextSpan(text: code, style: style));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: style));
    }

    return spans;
  }

  static Widget _buildMediaWidget(ChatXMedia media, double size) {
    final rawBytes = media.metadata?['raw_bytes'];

    if (rawBytes != null) {
      if (media.type == MediaType.lottie) {
        return Lottie.memory(rawBytes, width: size, height: size, fit: BoxFit.contain);
      } else if (media.type == MediaType.svg) {
        return SvgPicture.memory(rawBytes, width: size, height: size, fit: BoxFit.contain);
      }
      return Image.memory(rawBytes, width: size, height: size, fit: BoxFit.contain);
    }

    if (media.url.isNotEmpty) {
      if (media.type == MediaType.lottie) {
        return Lottie.network(media.url, width: size, height: size, fit: BoxFit.contain);
      } else if (media.type == MediaType.svg) {
        return SvgPicture.network(media.url, width: size, height: size, fit: BoxFit.contain);
      }
      return Image.network(media.url, width: size, height: size, fit: BoxFit.contain);
    }

    return const SizedBox.shrink();
  }
}
