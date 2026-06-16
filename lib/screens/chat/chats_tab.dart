import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🚀 تم إضافة الـ Bloc هنا
import 'package:chatx/screens/chat/cubit/chat_cubit.dart'; // 🚀 تم إضافة الـ Cubit هنا
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../utils/session_manager.dart';
import '../../widgets/widgets.dart';
import 'chat_screen.dart';
import 'new_chat_sheet.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  String _myUid = '';
  String _myName = '';

  @override
  void initState() {
    super.initState();
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
      backgroundColor: Colors.transparent, // خليناها شفافة عشان تاخد نفس لون الـ HomeScreen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0), // مسافة بسيطة من فوق عشان الشكل
          child: _buildChatsList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => NewChatSheet(
              myUid: _myUid,
              myName: _myName,
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.black),
      ),
    );
  }

  Widget _buildChatsList() {
    if (_myUid.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return StreamBuilder<List<ChatModel>>(
      stream: FirebaseRepo.observeUserChats(_myUid), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        var chats = snapshot.data!;

        if (chats.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No chats yet',
              subtitle: 'Start chatting!',
            ),
          );
        }

        // استخدام ListView.builder أحسن في الأداء عشان لو الشاتات كترت
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            return _buildChatItem(chats[index]);
          },
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

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => ChatCubit(
                    chatId: chatData.chatId,
                    myUid: _myUid,
                    myName: _myName, 
                  ),
                  child: ChatScreen(
                    chatId: chatData.chatId,
                    myUid: _myUid,
                    myName: _myName, 
                    receiverName: name,            
                    receiverImage: user?.avatarUrl, 
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
