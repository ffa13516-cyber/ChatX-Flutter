import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // 🚀 مسؤولة عن تنسيق الوقت
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
  
  // ✅ التعديل 1: كاش محلي لحفظ بيانات المستخدمين لتجنب مشكلة الـ N+1 Queries أثناء الـ Scroll
  final Map<String, UserModel> _usersCache = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = await SessionManager.instance.getUid();
    final name = await SessionManager.instance.getName();
    if (!mounted) return;
    setState(() {
      _myUid = uid;
      _myName = name;
    });
  }

  // دالة ذكية لإرجاع اليوزر من الكاش أو جلبها من Firebase إذا لم تكن موجودة
  Future<UserModel?> _getOrCreateUser(String uid) async {
    if (_usersCache.containsKey(uid)) {
      return _usersCache[uid];
    }
    final user = await FirebaseRepo.getUserById(uid);
    if (user != null) {
      _usersCache[uid] = user; // حفظ في الكاش
    }
    return user;
  }

  // ✅ التعديل 2: دالة معالجة وتنسيق الوقت بشكل آمن وذكي للغاية لمنع الـ Type Casting Crash
  String _formatMessageTime(dynamic timeData) {
    if (timeData == null) return '';
    
    DateTime messageTime;
    try {
      if (timeData is int) {
        messageTime = DateTime.fromMillisecondsSinceEpoch(timeData);
      } else if (timeData.runtimeType.toString() == 'Timestamp') {
        // التعامل الآمن في حال أرجعت فايربيز كائن Timestamp
        messageTime = (timeData as dynamic).toDate();
      } else {
        return '';
      }
    } catch (e) {
      debugPrint("Error formatting time: $e");
      return '';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(messageTime.year, messageTime.month, messageTime.day);
    final difference = today.difference(msgDay).inDays;

    if (difference == 0) {
      return DateFormat('hh:mm a').format(messageTime); // اليوم
    } else if (difference == 1) {
      return 'Yesterday'; // أمس
    } else if (difference < 7) {
      return DateFormat('EEEE').format(messageTime); // اسم اليوم (مثل Monday)
    } else {
      return DateFormat('dd/MM/yyyy').format(messageTime); // تاريخ قديم
    }
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
          color: Colors.white, 
          strokeWidth: 3,
        ),
      );
    }

    return StreamBuilder<List<ChatModel>>(
      stream: FirebaseRepo.observeUserChats(_myUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}', 
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3));
        }

        final chats = snapshot.data!;

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
          padding: const EdgeInsets.only(top: 16, bottom: 100, left: 8, right: 8), 
          itemCount: chats.length,
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 1), 
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

    if (otherUid.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<UserModel?>(
      future: _getOrCreateUser(otherUid),
      builder: (context, snapshot) {
        // ✅ التعديل 3: استخدام الـ Skeleton المخصص بدلاً من الفراغ الأبيض الثابت لتحسين الـ UX
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
           return const ModernChatListItemSkeleton(); 
        }

        final user = snapshot.data;
        final name = user?.displayName ?? 'Unknown User';
        final formattedTime = _formatMessageTime(chat.lastMessageTime);

        return ModernChatListItem(
          name: name,
          lastMessage: chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Tap to chat',
          time: formattedTime, 
          avatarUrl: user?.avatarUrl,
          isOnline: user?.isOnline ?? false,
          unreadCount: 0, // يمكنك ربطها لاحقاً بـ chat.unreadCount إن وُجدت
          onTap: () async {
            HapticFeedback.lightImpact(); 
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
    // ✅ التعديل 4: تجميع الألوان في متغيرات لتسهيل الصيانة ودعم الـ Themes مستقبلاً
    final Color onlineColor = const Color(0xFF00C853);
    final Color unreadAccentColor = const Color(0xFF00E676);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
                        color: (avatarUrl == null || avatarUrl!.isEmpty) 
                            ? AppColors.avatarColor(name) 
                            : Colors.transparent,
                        image: (avatarUrl != null && avatarUrl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (avatarUrl == null || avatarUrl!.isEmpty)
                          ? Center(
                              child: Text(
                                name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?',
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
                            color: onlineColor, 
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.bgDark, 
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
                        color: unreadCount > 0 ? unreadAccentColor : Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: unreadAccentColor, 
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
                      const SizedBox(height: 20), 
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

// ✅ التعديل 5: إضافة الـ Skeleton المخصص لمنع الـ Flicker وإعطاء تجربة تحميل بصرية سلسة ومحترفة
class ModernChatListItemSkeleton extends StatelessWidget {
  const ModernChatListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // صور الحساب الوهمية
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          const SizedBox(width: 16),
          // النصوص الوهمية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white.withOpacity(0.02),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // الوقت الوهمي
          Container(
            width: 40,
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withOpacity(0.02),
            ),
          ),
        ],
      ),
    );
  }
}
