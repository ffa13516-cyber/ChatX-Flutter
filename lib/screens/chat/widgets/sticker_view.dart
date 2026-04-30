import 'dart:io';
import 'package:flutter/material.dart';

class StickerView extends StatelessWidget {
  final String path;
  final double size;

  const StickerView({
    super.key,
    required this.path,
    this.size = 120,
  });

  bool get isNetwork => path.startsWith('http');
  bool get isFile => path.startsWith('/');
  bool get isAsset => !isNetwork && !isFile;

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (isNetwork) {
      image = Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    } else if (isFile) {
      image = Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    } else {
      image = Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: image,
    );
  }
}
