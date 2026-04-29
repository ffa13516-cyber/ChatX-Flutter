import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../utils/session_manager.dart';
import '../../widgets/widgets.dart';
import '../group/groups_tab.dart';
import '../channel/channels_tab.dart';
import 'chat_screen.dart';
import 'saved_messages_screen.dart';
import 'new_chat_sheet.dart'; // 🆕 رجعناه

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _myUid = '';
  String _myName = '';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = await SessionManager.instance.getUid();
    final name = await SessionManager.instance.getName();
    setState(() {
      _myUid = uid;
      _myName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'ChatX',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),

                  /// ✏️ NEW CHAT
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => NewChatSheet(myUid: _myUid),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            /// SEARCH BAR
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search chats...',
                    hintStyle: TextStyle(
                        color: AppColors.textHint, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textHint, size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            /// TABS
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              tabs: const [
                Tab(text: '💬  Chats'),
                Tab(text: '👥  Groups'),
                Tab(text: '📢  Channels'),
              ],
            ),

            /// CONTENT
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatsList(),
                  GroupsTab(myUid: _myUid),
                  ChannelsTab(myUid: _myUid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    if (_myUid.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    return StreamBuilder<List<ChatModel>>(
      stream: FirebaseRepo.observeUserChats(_myUid),
      builder: (context, snapshot) {
        final chats = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          children: [
            ChatListItem(
              name: 'Saved Messages',
              lastMessage: 'Your personal notes',
              time: '',
              isSavedMessages: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SavedMessagesScreen(
                      myUid: _myUid, myName: _myName),
                ),
              ),
            ),

            if (chats.isEmpty && _searchQuery.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: EmptyStateWidget(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No chats yet',
                  subtitle: 'Start chatting!',
                ),
              )
            else
              ...chats.map((chat) => _buildChatItem(chat)),
          ],
        );
      },
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    final otherUid =
        chat.participants.firstWhere((id) => id != _myUid, orElse: () => '');

    return FutureBuilder<UserModel?>(
      future: FirebaseRepo.getUserById(otherUid),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.displayName ?? 'Unknown';

        return ChatListItem(
          name: name,
          lastMessage: chat.lastMessage,
          time: '',
          avatarUrl: user?.avatarUrl,
          isOnline: user?.isOnline ?? false,

          /// 🔥 FIXED HERE
          onTap: () async {
            final chat = await FirebaseRepo.getOrCreateChat(
              _myUid,
              otherUid,
            );

            if (!mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatId: chat.chatId,
                  myUid: _myUid,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
