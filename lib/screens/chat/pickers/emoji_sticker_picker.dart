import 'package:flutter/material.dart';
import '../models/emoji_model.dart';
import '../models/sticker_model.dart';
import '../models/sticker_pack.dart'; // 🆕🔥 مهم
import '../services/emoji_service.dart';
import '../services/sticker_service.dart';

class EmojiStickerPicker extends StatefulWidget {
  final Function(EmojiModel) onEmojiSelected;
  final Function(StickerModel) onStickerSelected;

  const EmojiStickerPicker({
    super.key,
    required this.onEmojiSelected,
    required this.onStickerSelected,
  });

  @override
  State<EmojiStickerPicker> createState() => _EmojiStickerPickerState();
}

class _EmojiStickerPickerState extends State<EmojiStickerPicker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final emojis = EmojiService().allEmojis;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1F22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.emoji_emotions)),
              Tab(icon: Icon(Icons.sticky_note_2)),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _emojiGrid(),
                _stickerView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emojiGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final emoji = emojis[index];

        return GestureDetector(
          onTap: () => widget.onEmojiSelected(emoji),
          child: Center(
            child: emoji.char != null
                ? Text(
                    emoji.char!,
                    style: const TextStyle(fontSize: 22),
                  )
                : Image.asset(
                    emoji.assetPath!,
                    width: 24,
                    height: 24,
                  ),
          ),
        );
      },
    );
  }

  Widget _stickerView() {
    final List<StickerPack> packs = StickerService().packs; // 🔥 FIX

    if (packs.isEmpty) {
      return const Center(
        child: Text(
          "No Stickers 😢",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return DefaultTabController(
      length: packs.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: packs.map((p) => Tab(text: p.name)).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: packs.map((pack) {
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: pack.stickers.length,
                  itemBuilder: (context, index) {
                    final sticker = pack.stickers[index];

                    return GestureDetector(
                      onTap: () =>
                          widget.onStickerSelected(sticker),
                      child: Image.asset(
                        sticker.path,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
