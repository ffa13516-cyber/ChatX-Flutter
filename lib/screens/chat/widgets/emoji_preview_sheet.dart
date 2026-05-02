import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../models/emoji_model.dart';

class EmojiPreviewSheet extends StatelessWidget {
  final ChatXMedia media;

  const EmojiPreviewSheet({super.key, required this.media});

  static void show(BuildContext context, ChatXMedia media) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => EmojiPreviewSheet(media: media),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLargePreview(),
                  if (media.label != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      ":${media.label}:",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargePreview() {
    final rawBytes = media.metadata?['raw_bytes'];
    const double previewSize = 220;

    if (rawBytes != null) {
      if (media.type == MediaType.lottie) {
        return Lottie.memory(rawBytes, width: previewSize, height: previewSize);
      } else if (media.type == MediaType.svg) {
        return SvgPicture.memory(rawBytes, width: previewSize, height: previewSize);
      }
      return Image.memory(rawBytes, width: previewSize, height: previewSize, fit: BoxFit.contain);
    }

    if (media.url.isNotEmpty) {
      if (media.type == MediaType.lottie) {
        return Lottie.network(media.url, width: previewSize, height: previewSize);
      } else if (media.type == MediaType.svg) {
        return SvgPicture.network(media.url, width: previewSize, height: previewSize);
      }
      return Image.network(media.url, width: previewSize, height: previewSize, fit: BoxFit.contain);
    }

    return const Icon(Icons.broken_image, size: previewSize, color: Colors.white24);
  }
}
