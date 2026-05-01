import 'package:flutter/material.dart';
import 'dart:io'; // 🆕
import 'package:file_picker/file_picker.dart'; // 🆕
import '../models/emoji_model.dart';
import '../models/sticker_model.dart';
import '../models/sticker_pack.dart';
import '../models/emoji_pack.dart';
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
  final packs = EmojiService().packs;

  String searchQuery = "";

  int selectedPackIndex = 0;

  final Map<String, List<EmojiModel>> categories = {
    "Smileys": [],
    "Love": [],
    "Custom": [],
  };

  // 🆕🔥 IMPORT FUNCTION
  Future<void> _importEmojiPack() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);

      await EmojiService().importFromZip(file);

      setState(() {}); // 🔥 refresh packs

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Emoji pack imported')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Import failed: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _buildCategories();
  }

  void _buildCategories() {
    for (var e in emojis) {
      if (e.isCustom) {
        categories["Custom"]!.add(e);
      } else if (e.code.contains("heart")) {
        categories["Love"]!.add(e);
      } else {
        categories["Smileys"]!.add(e);
      }
    }
  }

  List<EmojiModel> _currentPackEmojis() {
    return packs[selectedPackIndex].emojis;
  }

  List<EmojiModel> _filter(List<EmojiModel> list) {
    if (searchQuery.isEmpty) return list;

    return list.where((e) {
      final q = searchQuery.toLowerCase();
      return e.code.toLowerCase().contains(q) ||
          (e.char?.contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1F22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          _searchBar(),

          _packsBar(),

          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.emoji_emotions)),
              Tab(icon: Icon(Icons.gif_box)),
              Tab(icon: Icon(Icons.sticky_note_2)),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _emojiView(),
                _gifView(),
                _stickerView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF2B2C2F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 🔥 Packs Bar + IMPORT
  Widget _packsBar() {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: packs.length,
              itemBuilder: (context, index) {
                final pack = packs[index];
                final isSelected = index == selectedPackIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedPackIndex = index);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      pack.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🆕🔥 IMPORT BUTTON
          GestureDetector(
            onTap: _importEmojiPack,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Icon(Icons.add, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emojiView() {
    final current = _currentPackEmojis();

    return ListView(
      children: [
        if (searchQuery.isEmpty) _recentBar(),

        ...categories.entries.map((entry) {
          final list = _filter(
            entry.value.where((e) => current.contains(e)).toList(),
          );

          if (list.isEmpty) return const SizedBox();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
              _emojiGrid(list),
            ],
          );
        }),
      ],
    );
  }

  Widget _emojiGrid(List<EmojiModel> list) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final emoji = list[i];

        return GestureDetector(
          onTap: () {
            EmojiService().registerUsage(emoji);
            widget.onEmojiSelected(emoji);
            setState(() {});
          },
          child: Center(
            child: emoji.char != null
                ? Text(emoji.char!, style: const TextStyle(fontSize: 22))
                : Image.asset(emoji.assetPath!, width: 24),
          ),
        );
      },
    );
  }

  Widget _recentBar() {
    final recents = EmojiService().getRecentEmojis();
    if (recents.isEmpty) return const SizedBox();

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: recents.map((e) {
          return GestureDetector(
            onTap: () {
              EmojiService().registerUsage(e);
              widget.onEmojiSelected(e);
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: e.char != null
                  ? Text(e.char!, style: const TextStyle(fontSize: 22))
                  : Image.asset(e.assetPath!, width: 24),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _gifView() {
    return const Center(
      child: Text("GIF Coming Soon 👀",
          style: TextStyle(color: Colors.white54)),
    );
  }

  Widget _stickerView() {
    final packs = StickerService().packs;

    if (packs.isEmpty) {
      return const Center(
        child: Text("No Stickers 😢",
            style: TextStyle(color: Colors.white54)),
      );
    }

    return DefaultTabController(
      length: packs.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
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
                  ),
                  itemCount: pack.stickers.length,
                  itemBuilder: (_, i) {
                    final sticker = pack.stickers[i];

                    return GestureDetector(
                      onTap: () => widget.onStickerSelected(sticker),
                      child: Image.asset(sticker.path),
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
