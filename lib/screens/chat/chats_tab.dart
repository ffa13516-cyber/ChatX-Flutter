import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🚀 تم إضافة الـ Bloc هنا
import 'package:chatx/screens/chat/cubit/chat_cubit.dart'; // 🚀 تم إضافة الـ Cubit هنا
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../utils/session_manager.dart';
import '../../widgets/widgets.dart';
import '../group/groups_tab.dart';
import '../channel/channels_tab.dart';
import 'chat_screen.dart';
import 'saved_messages_screen.dart';
import 'new_chat_sheet.dart';

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
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatsList(),
                  // ✅ تم إصلاح: تمرير myUid وإزالة const
                  GroupsTab(myUid: _myUid, key: ValueKey(_myUid)), 
                  // ✅ تم إصلاح: تمرير myUid وإزالة const
                  ChannelsTab(myUid: _myUid, key: ValueKey(_myUid)), 
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => NewChatSheet(myUid: _myUid),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.black),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  _myName.isNotEmpty ? _myName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _myName.isNotEmpty ? _myName : 'Loading...',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // ✅ تم إصلاح: تمرير myUid و myName وإزالة const
                  builder: (_) => SavedMessagesScreen(myUid: _myUid, myName: _myName), 
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search chats...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
          fillColor: AppColors.bgSurface,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim().toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primary,
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.white.withOpacity(0.5),
      tabs: const [
        Tab(text: 'Direct'),
        Tab(text: 'Groups'),
        Tab(text: 'Channels'),
      ],
    );
  }

  Widget _buildChatsList() {
    if (_myUid.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return StreamBuilder<List<ChatModel>>(
      // ✅ تم إصلاح: استخدام الاسم الصحيح للدالة observeUserChats بدلاً من observeChats
      stream: FirebaseRepo.observeUserChats(_myUid), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        var chats = snapshot.data!;
        
        if (_searchQuery.isNotEmpty) {
          // فلترة الشاتات بناءً على البحث لو محتاج تعدلها مستقبلاً
        }

        if (chats.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No chats yet',
              subtitle: 'Start chatting!',
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: chats.map((chat) => _buildChatItem(chat)).toList(),
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
          onTap: () async {
            final chatData = await FirebaseRepo.getOrCreateChat(
              _myUid,
              otherUid,
            );

            if (!mounted) return;

            // 🚀 التعديل هنا: تمرير الـ ChatCubit للشاشة عبر الـ BlocProvider لضمان عملها بنجاح
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => ChatCubit(
                    chatId: chatData.chatId,
                    myUid: _myUid,
                  ),
                  child: ChatScreen(
                    chatId: chatData.chatId,
                    myUid: _myUid,
                  ),
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
