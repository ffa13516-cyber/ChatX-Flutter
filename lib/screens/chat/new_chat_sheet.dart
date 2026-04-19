import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../widgets/widgets.dart';
import 'chat_screen.dart';

class NewChatSheet extends StatefulWidget {
  final String myUid;

  const NewChatSheet({super.key, required this.myUid});

  @override
  State<NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends State<NewChatSheet> {
  final _searchController = TextEditingController();
  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await FirebaseRepo.getAllUsers();
    setState(() {
      _users = users.where((u) => u.uid != widget.myUid).toList();
      _isLoading = false;
    });
  }

  Future<void> _searchByUsername(String username) async {
    if (username.isEmpty) return;
    setState(() => _isSearching = true);
    final user = await FirebaseRepo.getUserByUsername(username.toLowerCase());
    setState(() => _isSearching = false);

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User @$username not found'),
            backgroundColor: AppColors.bgCard,
          ),
        );
      }
    } else {
      _openChat(user);
    }
  }

  Future<void> _openChat(UserModel user) async {
    final myName = await FirebaseRepo.getUserById(widget.myUid)
        .then((u) => u?.displayName ?? '');
    final chat = await FirebaseRepo.getOrCreateChat(widget.myUid, user.uid);
    if (mounted) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chat.chatId,
            otherUserId: user.uid,
            otherUserName: user.displayName,
            myUid: widget.myUid,
            myName: myName,
          ),
        ),
      );
    }
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'New Chat',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Search by username
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search by @username',
                        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _searchByUsername(_searchController.text.trim()),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Divider(color: AppColors.divider),

          // Users list
          SizedBox(
            height: 300,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _users.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.people_outline_rounded,
                        title: 'No users yet',
                        subtitle: 'Invite friends to join ChatX',
                      )
                    : ListView.builder(
                        itemCount: _users.length,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemBuilder: (_, i) {
                          final user = _users[i];
                          return ListTile(
                            leading: AvatarWidget(name: user.displayName, size: 44),
                            title: Text(
                              user.displayName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              user.username.isNotEmpty ? '@${user.username}' : user.phoneNumber,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            onTap: () => _openChat(user),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
