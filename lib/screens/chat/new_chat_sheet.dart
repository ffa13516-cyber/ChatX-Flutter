import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import 'chat_screen.dart';

class NewChatSheet extends StatefulWidget {
  final String myUid;

  const NewChatSheet({super.key, required this.myUid});

  @override
  State<NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends State<NewChatSheet> {
  final TextEditingController _controller = TextEditingController();
  UserModel? _result;
  bool _loading = false;

  Future<void> _search(String value) async {
    if (value.trim().isEmpty) {
      setState(() => _result = null);
      return;
    }

    setState(() => _loading = true);

    final user = await FirebaseRepo.getUserByUsername(value.trim());

    setState(() {
      _result = user;
      _loading = false;
    });
  }

  Future<void> _openChat(UserModel user) async {
    final chat = await FirebaseRepo.getOrCreateChat(
      widget.myUid,
      user.uid,
    );

    if (!mounted) return;

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chat.chatId,
          myUid: widget.myUid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        children: [

          /// 🔥 HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Text(
                  "New Chat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search username...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 RESULT
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _result == null
                    ? const Center(
                        child: Text(
                          "No user found",
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : ListTile(
                        onTap: () => _openChat(_result!),
                        leading: CircleAvatar(
                          backgroundImage: _result!.avatarUrl != null
                              ? NetworkImage(_result!.avatarUrl!)
                              : null,
                          child: _result!.avatarUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          _result!.displayName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "@${_result!.username}",
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
