import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../utils/session_manager.dart';
import '../../widgets/widgets.dart';

// Channels Tab
class ChannelsTab extends StatefulWidget {
  final String myUid;
  const ChannelsTab({super.key, required this.myUid});

  @override
  State<ChannelsTab> createState() => _ChannelsTabState();
}

class _ChannelsTabState extends State<ChannelsTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChannelModel>>(
      stream: FirebaseRepo.observeUserChannels(widget.myUid),
      builder: (context, snapshot) {
        final channels = snapshot.data ?? [];
        if (channels.isEmpty) {
          return Column(
            children: [
              const Expanded(
                child: EmptyStateWidget(
                  icon: Icons.campaign_outlined,
                  title: 'No channels yet',
                  subtitle: 'Tap + to create a channel',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GradientButton(
                  text: '+ Create Channel',
                  onPressed: () => _showCreateChannel(context),
                ),
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          children: [
            ...channels.map((channel) {
              final time = channel.lastMessageTime > 0
                  ? DateFormat('HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(channel.lastMessageTime))
                  : '';
              return ChatListItem(
                name: channel.name,
                lastMessage: channel.lastMessage,
                time: time,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChannelScreen(channel: channel, myUid: widget.myUid),
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.all(20),
              child: GradientButton(
                text: '+ Create Channel',
                onPressed: () => _showCreateChannel(context),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateChannel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CreateChannelSheet(myUid: widget.myUid),
    );
  }
}

// Channel Screen
class ChannelScreen extends StatefulWidget {
  final ChannelModel channel;
  final String myUid;

  const ChannelScreen({super.key, required this.channel, required this.myUid});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final _msgController = TextEditingController();
  String _myName = '';

  @override
  void initState() {
    super.initState();
    SessionManager.instance.getName().then((n) => setState(() => _myName = n));
  }

  bool get _isAdmin => widget.channel.adminId == widget.myUid;

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty || !_isAdmin) return;
    _msgController.clear();

    final message = MessageModel(
      messageId: '',
      senderId: widget.myUid,
      senderName: _myName,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    FirebaseRepo.sendChannelMessage(widget.channel.channelId, message, widget.myUid);
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
            AvatarWidget(name: widget.channel.name, size: 38),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.channel.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.channel.subscribers.length} subscribers',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
              stream: FirebaseRepo.observeChannelMessages(widget.channel.channelId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.campaign_outlined,
                    title: 'No posts yet',
                    subtitle: 'Admin will post updates here',
                  );
                }
                return ListView.builder(
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
          if (_isAdmin)
            MessageInputBar(
              controller: _msgController,
              onSend: _sendMessage,
              hint: 'Broadcast a message...',
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.bgSurface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 16),
                  SizedBox(width: 8),
                  Text('You can only read this channel', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Create Channel Sheet
class CreateChannelSheet extends StatefulWidget {
  final String myUid;
  const CreateChannelSheet({super.key, required this.myUid});

  @override
  State<CreateChannelSheet> createState() => _CreateChannelSheetState();
}

class _CreateChannelSheetState extends State<CreateChannelSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createChannel() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final channel = ChannelModel(
      channelId: '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      adminId: widget.myUid,
      subscribers: [widget.myUid],
    );
    await FirebaseRepo.createChannel(channel);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Channel', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          CustomTextField(hint: 'Channel name', controller: _nameController, prefixIcon: Icons.campaign_rounded),
          const SizedBox(height: 12),
          CustomTextField(hint: 'Description (optional)', controller: _descController, prefixIcon: Icons.info_outline_rounded),
          const SizedBox(height: 8),
          const Text(
            'Only you (admin) can post. Subscribers can only read.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GradientButton(text: 'Create Channel', onPressed: _createChannel, isLoading: _isLoading),
        ],
      ),
    );
  }
}
