import 'dart:ui'; // 🚀 مسؤولة عن تأثيرات الزجاج والـ Blur
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
  
  // ✅ كاش محلي مع حماية ضد الـ Memory Leak
  final Map<String, UserModel> _usersCache = {};
  final int _maxCacheSize = 100; // الحد الأقصى لتخزين المستخدمين

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

  // ✅ دالة ذكية لإدارة الكاش بكفاءة عالية
  Future<UserModel?> _getOrCreateUser(String uid) async {
    if (_usersCache.containsKey(uid)) {
      return _usersCache[uid];
    }
    final user = await FirebaseRepo.getUserById(uid);
    if (user != null) {
      if (_usersCache.length >= _maxCacheSize) {
        // تفريغ أقدم عنصر في حال امتلاء الكاش للحفاظ على الرامات
        _usersCache.remove(_usersCache.keys.first); 
      }
      _usersCache[uid] = user; 
    }
    return user;
  }

  String _formatMessageTime(dynamic timeData) {
    if (timeData == null) return '';
    
    DateTime messageTime;
    try {
      if (timeData is int) {
        messageTime = DateTime.fromMillisecondsSinceEpoch(timeData);
      } else if (timeData.runtimeType.toString() == 'Timestamp' || timeData.runtimeType.toString() != 'String') {
        // معالجة مرنة للأنواع
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
      return DateFormat('hh:mm a').format(messageTime);
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return DateFormat('EEEE').format(messageTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(messageTime);
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

        // ترتيب المحادثات: المثبتة أولاً ثم الأحدث
        chats.sort((a, b) {
          bool aPinned = a.pinnedBy.contains(_myUid);
          bool bPinned = b.pinnedBy.contains(_myUid);
          
          if (aPinned && !bPinned) return -1;
          if (!aPinned && bPinned) return 1;
          
          return b.lastMessageTime.compareTo(a.lastMessageTime); 
        });

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

    final int unreadCount = chat.unreadCounts[_myUid] ?? 0;
    final bool isPinned = chat.pinnedBy.contains(_myUid);

    return FutureBuilder<UserModel?>(
      future: _getOrCreateUser(otherUid),
      builder: (context, snapshot) {
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
          unreadCount: unreadCount, 
          isPinned: isPinned,
          onTap: () async {
            HapticFeedback.lightImpact(); 
            _navigateToChat(chat.chatId, otherUid, name, user?.avatarUrl);
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showChatOptionsBottomSheet(context, chat, name, isPinned);
          },
        );
      },
    );
  }

  void _navigateToChat(String chatId, String otherUid, String name, String? avatarUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => ChatCubit(chatId: chatId, myUid: _myUid, myName: _myName),
          child: ChatScreen(
            chatId: chatId,
            myUid: _myUid,
            myName: _myName,
            receiverName: name,
            receiverImage: avatarUrl,
          ),
        ),
      ),
    );
  }

  // ✅ واجهة زجاجية فضية (Silver Glassmorphism) متقدمة
  void _showChatOptionsBottomSheet(BuildContext context, ChatModel chat, String name, bool isPinned) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // مهم جداً لتشغيل الشفافية والبلور
      elevation: 0,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // تأثير الـ Blur
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08), // الشفافية الزجاجية
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5), // حافة فضية مضيئة
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 20),
                      
                      // ✅ ربط العمليات بالفايربيز مباشرة
                      ListTile(
                        leading: Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin, color: Colors.white),
                        title: Text(isPinned ? 'Unpin Chat' : 'Pin Chat', style: const TextStyle(color: Colors.white, fontSize: 16)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        tileColor: Colors.white.withOpacity(0.03),
                        onTap: () async {
                          Navigator.pop(context);
                          await FirebaseRepo.togglePinChat(chat.chatId, _myUid);
                        },
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.mark_chat_read_outlined, color: Colors.white),
                        title: const Text('Mark as Read', style: TextStyle(color: Colors.white, fontSize: 16)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        tileColor: Colors.white.withOpacity(0.03),
                        onTap: () async {
                          Navigator.pop(context);
                          await FirebaseRepo.resetUnreadCount(chat.chatId, _myUid);
                        },
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        title: const Text('Delete Chat', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        tileColor: Colors.white.withOpacity(0.03),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement Delete Chat Logic
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ModernChatListItem({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.avatarUrl,
    required this.isOnline,
    this.unreadCount = 0,
    this.isPinned = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final Color onlineColor = const Color(0xFF00C853);
    // ✅ تم تعديل اللون للأزرق الملكي
    final Color unreadAccentColor = const Color(0xFF246BFD); 

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: unreadCount > 0 
            ? unreadAccentColor.withOpacity(0.1) // لمسة خفيفة بلون العداد للخلفية
            : (isPinned ? Colors.white.withOpacity(0.02) : Colors.transparent), 
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.02),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
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
                          ),
                          if (isPinned)
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Transform.rotate(
                                angle: 0.5,
                                child: Icon(Icons.push_pin, color: Colors.white.withOpacity(0.4), size: 14),
                              ),
                            ),
                        ],
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
                          boxShadow: [
                            BoxShadow(
                              color: unreadAccentColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white, // النص أبيض ليناسب الخلفية الزرقاء
                            fontSize: 11,
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

class ModernChatListItemSkeleton extends StatelessWidget {
  const ModernChatListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          const SizedBox(width: 16),
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
