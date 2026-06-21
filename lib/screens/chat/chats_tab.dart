import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // 🚀 تأكد من إضافة باكيدج intl في pubspec.yaml لتنسيق الوقت
import 'package:chatx/screens/chat/cubit/chat_cubit.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../utils/session_manager.dart';
import '../../widgets/widgets.dart';
import 'chat_screen.dart';

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
      backgroundColor: Colors.transparent, 
      body: SafeArea(
        bottom: false,
        child: _buildChatsList(),
      ),
    );
  }

  Widget _buildChatsList() {
    if (_myUid.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white, // تعديل للون أنيق
          strokeWidth: 3,
        ),
      );
    }

    return StreamBuilder<List<ChatModel>>(
      stream: FirebaseRepo.observeUserChats(_myUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3));
        }

        var chats = snapshot.data!;

        if (chats.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No chats yet',
              subtitle: 'Start chatting and make friends!',
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 16, bottom: 100, left: 8, right: 8), // مساحة سفلية عشان الـ NavBar
          itemCount: chats.length,
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 1), // فاصل شفاف وأنيق جداً
          ),
          itemBuilder: (context, index) {
            return _buildChatItem(chats[index]);
          },
        );
      },
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    final otherUid = chat.participants.firstWhere((id) => id != _myUid, orElse: () => '');

    return FutureBuilder<UserModel?>(
      future: FirebaseRepo.getUserById(otherUid),
      builder: (context, snapshot) {
        // تأثير تحميل ناعم لو البيانات لسه بتيجي (اختياري بس بيخلي الـ UX عالي)
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
           return const SizedBox(height: 76); // مساحة افتراضية لمنع القفز البصري
        }

        final user = snapshot.data;
        final name = user?.displayName ?? 'Unknown User';
        
        // 🚀 معالجة الوقت (افترضنا أن الـ chat فيها حقل timestamp، لو مش موجود ضيفه في الموديل)
        // String formattedTime = '';
        // if (chat.lastMessageTime != null) {
        //   formattedTime = DateFormat('hh:mm a').format(chat.lastMessageTime!);
        // }

        return ModernChatListItem(
          name: name,
          lastMessage: chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Tap to chat',
          time: '12:30 PM', // استبدلها بـ formattedTime بعد تفعيل الـ timestamp
          avatarUrl: user?.avatarUrl,
          isOnline: user?.isOnline ?? false,
          unreadCount: 0, // 🚀 ضيف الحقل ده في الـ Firebase عندك عشان تظهر عدد الرسائل
          onTap: () async {
            HapticFeedback.lightImpact(); // تجاوب لمسي مع الضغطة
            final chatData = await FirebaseRepo.getOrCreateChat(_myUid, otherUid);

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

// 🚀 الويدجت السحرية اللي هتحول شكل الشات لتصميم عالمي
class ModernChatListItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final String? avatarUrl;
  final bool isOnline;
  final int unreadCount;
  final VoidCallback onTap;

  const ModernChatListItem({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.avatarUrl,
    required this.isOnline,
    this.unreadCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // تأثير ضوء خفيف جداً لما يكون فيه رسائل جديدة
        color: unreadCount > 0 ? Colors.white.withOpacity(0.03) : Colors.transparent, 
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.02),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // 1. User Avatar & Online Status
                Stack(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: avatarUrl == null
                            ? const LinearGradient(
                                colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        image: avatarUrl != null && avatarUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: avatarUrl == null || avatarUrl!.isEmpty
                          ? Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            )
                          : null,
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853), // لون أخضر عصري
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.bgDark, // 🚀 الـ Cut-out effect
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // 2. Name & Message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: unreadCount > 0 ? Colors.white : Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage,
                        style: TextStyle(
                          color: unreadCount > 0 ? Colors.white70 : Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Time & Unread Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: unreadCount > 0 ? const Color(0xFF00E676) : Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676), // أخضر فاقع للفت الانتباه
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 20), // للحفاظ على التوازن البصري لو مفيش رسائل
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
