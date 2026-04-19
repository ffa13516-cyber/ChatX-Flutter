import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../utils/session_manager.dart';
import '../../widgets/widgets.dart';

// Groups Tab
class GroupsTab extends StatefulWidget {
  final String myUid;
  const GroupsTab({super.key, required this.myUid});

  @override
  State<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<GroupsTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GroupModel>>(
      stream: FirebaseRepo.observeUserGroups(widget.myUid),
      builder: (context, snapshot) {
        final groups = snapshot.data ?? [];
        if (groups.isEmpty) {
          return Column(
            children: [
              const Expanded(
                child: EmptyStateWidget(
                  icon: Icons.group_outlined,
                  title: 'No groups yet',
                  subtitle: 'Tap + to create a group',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: GradientButton(
                  text: '+ Create Group',
                  onPressed: () => _showCreateGroup(context),
                ),
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          children: [
            ...groups.map((group) {
              final time = group.lastMessageTime > 0
                  ? DateFormat('HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(group.lastMessageTime))
                  : '';
              return ChatListItem(
                name: group.name,
                lastMessage: group.lastMessage,
                time: time,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupChatScreen(group: group, myUid: widget.myUid),
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.all(20),
              child: GradientButton(
                text: '+ Create Group',
                onPressed: () => _showCreateGroup(context),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateGroup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CreateGroupSheet(myUid: widget.myUid),
    );
  }
}

// Group Chat Screen
class GroupChatScreen extends StatefulWidget {
  final GroupModel group;
  final String myUid;

  const GroupChatScreen({super.key, required this.group, required this.myUid});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _msgController = TextEditingController();
  String _myName = '';

  @override
  void initState() {
    super.initState();
    SessionManager.instance.getName().then((n) => setState(() => _myName = n));
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();

    final message = MessageModel(
      messageId: '',
      senderId: widget.myUid,
      senderName: _myName,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    FirebaseRepo.sendGroupMessage(widget.group.groupId, message);
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
            AvatarWidget(name: widget.group.name, size: 38),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.group.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.group.members.length} members',
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
              stream: FirebaseRepo.observeGroupMessages(widget.group.groupId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.group_outlined,
                    title: 'No messages yet',
                    subtitle: 'Be the first to say something!',
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
                      showSenderName: msg.senderId != widget.myUid,
                    );
                  },
                );
              },
            ),
          ),
          MessageInputBar(controller: _msgController, onSend: _sendMessage),
        ],
      ),
    );
  }
}

// Create Group Sheet
class CreateGroupSheet extends StatefulWidget {
  final String myUid;
  const CreateGroupSheet({super.key, required this.myUid});

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  List<UserModel> _users = [];
  final Set<String> _selectedUids = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await FirebaseRepo.getAllUsers();
    setState(() => _users = users.where((u) => u.uid != widget.myUid).toList());
  }

  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    final allMembers = [widget.myUid, ..._selectedUids];
    final group = GroupModel(
      groupId: '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      adminId: widget.myUid,
      members: allMembers,
    );
    await FirebaseRepo.createGroup(group);
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
          const Text('New Group', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          CustomTextField(hint: 'Group name', controller: _nameController, prefixIcon: Icons.group_rounded),
          const SizedBox(height: 12),
          CustomTextField(hint: 'Description (optional)', controller: _descController, prefixIcon: Icons.info_outline_rounded),
          const SizedBox(height: 16),
          const Text('Add Members', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (_, i) {
                final user = _users[i];
                final isSelected = _selectedUids.contains(user.uid);
                return ListTile(
                  leading: AvatarWidget(name: user.displayName, size: 40),
                  title: Text(user.displayName, style: const TextStyle(color: AppColors.textPrimary)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : const Icon(Icons.circle_outlined, color: AppColors.textHint),
                  onTap: () => setState(() {
                    if (isSelected) _selectedUids.remove(user.uid);
                    else _selectedUids.add(user.uid);
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          GradientButton(text: 'Create Group', onPressed: _createGroup, isLoading: _isLoading),
        ],
      ),
    );
  }
}
