import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String myUid;
  final String myName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.myUid,
    required this.myName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();

    final message = MessageModel(
      messageId: '',
      senderId: widget.myUid,
      senderName: widget.myName,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    FirebaseRepo.sendMessage(widget.chatId, message);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
            AvatarWidget(name: widget.otherUserName, size: 38),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(color: AppColors.online, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: FirebaseRepo.observeMessages(widget.chatId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No messages yet',
                    subtitle: 'Say hello! 👋',
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
                      time: DateFormat('HH:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(msg.timestamp),
                      ),
                      isSent: msg.senderId == widget.myUid,
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
          ),
        ],
      ),
    );
  }
}
