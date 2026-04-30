import 'package:flutter/material.dart';
import '../models/emoji_model.dart';
import '../models/sticker_model.dart';
import '../services/emoji_service.dart';

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

          // 🔥 Tabs
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
                _stickerPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 😀 Emoji Grid
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

  // 🖼️ مؤقت (هنبدله بالـ packs بعدين)
  Widget _stickerPlaceholder() {
    return const Center(
      child: Text(
        "No Stickers Yet 😢",
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
