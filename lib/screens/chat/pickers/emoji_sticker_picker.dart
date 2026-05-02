import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../models/emoji_model.dart';
import '../models/sticker_pack.dart';
import '../services/emoji_service.dart';

class EmojiStickerPicker extends StatefulWidget {
  final Function(ChatXMedia) onEmojiSelected;
  final Function(ChatXMedia) onStickerSelected;

  const EmojiStickerPicker({
    super.key,
    required this.onEmojiSelected,
    required this.onStickerSelected,
  });

  @override
  State<EmojiStickerPicker> createState() => _EmojiStickerPickerState();
}

class _EmojiStickerPickerState extends State<EmojiStickerPicker> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";
  int _selectedPackIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    EmojiService().addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    EmojiService().removeListener(_onServiceUpdate);
    _tabController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _importPack(FileType type, List<String>? extensions) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: extensions,
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();

      if (type == FileType.custom) {
        await EmojiService().importPackFromZip(bytes);
      } else {
        await EmojiService().addSingleMedia(
          bytes: bytes,
          type: MediaType.emoji,
          removeBackground: false, 
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت الإضافة بنجاح', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xAA000000),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  void _showImportMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.folder_zip, color: Colors.white),
                    title: const Text("استيراد حزمة (ZIP)", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      _importPack(FileType.custom, ['zip']);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.image, color: Colors.white),
                    title: const Text("إضافة رمز مخصص (صورة)", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      _importPack(FileType.image, null);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<ChatXMedia> _getFilteredMedia(MediaType targetType) {
    if (EmojiService().packs.isEmpty) return [];
    
    final currentPack = EmojiService().packs[_selectedPackIndex];
    var items = currentPack.items.where((m) => m.type == targetType || (targetType == MediaType.emoji && m.type == MediaType.svg)).toList();

    if (_searchQuery.isNotEmpty) {
      items = items.where((m) => (m.label?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1F22).withOpacity(0.65),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildSearchBar(),
              _buildPacksBar(),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                tabs: const [
                  Tab(icon: Icon(Icons.emoji_emotions_rounded)),
                  Tab(icon: Icon(Icons.sticky_note_2_rounded)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMediaGrid(MediaType.emoji, widget.onEmojiSelected),
                    _buildMediaGrid(MediaType.sticker, widget.onStickerSelected),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "البحث عن الرموز...",
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPacksBar() {
    final packs = EmojiService().packs;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: packs.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedPackIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPackIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      packs[index].title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
            onPressed: _showImportMenu,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(MediaType type, Function(ChatXMedia) onSelected) {
    final items = _getFilteredMedia(type);

    if (items.isEmpty) {
      return const Center(
        child: Text("لا توجد عناصر هنا", style: TextStyle(color: Colors.white38)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: type == MediaType.sticker ? 4 : 8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final media = items[index];
        return GestureDetector(
          onTap: () {
            EmojiService().recordUsage(media.id);
            onSelected(media);
          },
          onLongPress: () {
          },
          child: _renderMediaItem(media),
        );
      },
    );
  }

  Widget _renderMediaItem(ChatXMedia media) {
    final rawBytes = media.metadata?['raw_bytes'];
    
    if (rawBytes != null) {
      if (media.type == MediaType.lottie) return Lottie.memory(rawBytes);
      if (media.type == MediaType.svg) return SvgPicture.memory(rawBytes);
      return Image.memory(rawBytes, fit: BoxFit.contain);
    }

    if (media.url.isNotEmpty) {
      if (media.type == MediaType.lottie) return Lottie.network(media.url);
      if (media.type == MediaType.svg) return SvgPicture.network(media.url);
      return Image.network(media.url, fit: BoxFit.contain);
    }

    return Text(media.label ?? '؟', style: const TextStyle(fontSize: 22));
  }
}
