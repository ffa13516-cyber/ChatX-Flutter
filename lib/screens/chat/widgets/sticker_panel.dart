import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/sticker_model.dart';

class StickerPanel extends StatelessWidget {
  final List<StickerModel> stickers; // لستة الاستيكرز اللي هنعرضها
  final Function(StickerModel) onStickerSelected;

  const StickerPanel({
    super.key, 
    required this.stickers, 
    required this.onStickerSelected
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // تأثير الزجاج (Glassmorphism)
        child: Container(
          height: 350,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // خلفية شفافة
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildHeader(), // زرار الـ Restore والتبويبات
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 استيكرز في الصف الواحد
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: stickers.length,
                  itemBuilder: (context, index) => _buildStickerItem(stickers[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // الجزء العلوي (Header) اللي فيه شكل الـ Premium
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {}, 
            child: const Text("Restore", style: TextStyle(color: Colors.blueAccent)),
          ),
          const Text("Trending Packs", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const Icon(Icons.settings_outlined, color: Colors.white70),
        ],
      ),
    );
  }

  // شكل الاستيكر الفردي (Item)
  Widget _buildStickerItem(StickerModel sticker) {
    return GestureDetector(
      onTap: () => onStickerSelected(sticker),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.network(sticker.url, fit: BoxFit.contain),
            ),
          ),
          if (sticker.isPremium) // لو الاستيكر بفلوس يظهر القفل
            const Positioned(
              top: 5,
              right: 5,
              child: Icon(Icons.lock_rounded, size: 16, color: Colors.amber),
            ),
        ],
      ),
    );
  }
}
