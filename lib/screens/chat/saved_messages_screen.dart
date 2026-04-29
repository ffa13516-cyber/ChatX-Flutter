import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../widgets/widgets.dart';
import '../chat/models/message_model.dart'; // ✅ أضفنا

class SavedMessagesScreen extends StatefulWidget {
  final String myUid;
  final String myName;

  const SavedMessagesScreen({super.key, required this.myUid, required this.myName});

  @override
  State<SavedMessagesScreen> createState() => _SavedMessagesScreenState();
}

class _SavedMessagesScreenState extends State<SavedMessagesScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  String get _savedChatId => 'saved_${widget.myUid}';

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();

    // ✅ تعديل: Message بدل MessageModel
    final message = Message(
      text: text,
      isMe: true,
      senderId: widget.myUid,
      senderName: widget.myName,
    );
    FirebaseRepo.sendMessage(_savedChatId, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Messages',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your personal notes',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            // ✅ تعديل: Stream<List<Message>> مع myUid
            child: StreamBuilder<List<Message>>(
              stream: FirebaseRepo.observeMessages(_savedChatId, widget.myUid),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.bookmark_outline_rounded,
                    title: 'No saved messages',
                    subtitle: 'Save notes, links, and files here',
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    return MessageBubble(
                      text: msg.text,
                      time: DateFormat('HH:mm').format(msg.time), // ✅ msg.time بدل timestamp
                      isSent: true,
                      senderName: msg.senderName,
                    );
                  },
                );
              },
            ),
          ),
          MessageInputBar(
            controller: _msgController,
            onSend: _sendMessage,
            hint: 'Save a note...',
          ),
        ],
      ),
    );
  }
}
