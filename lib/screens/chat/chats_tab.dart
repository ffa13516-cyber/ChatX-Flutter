import 'dart:ui';
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
import '../group/group_chat_screen_ui.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  String _myUid = '';
  String _myName = '';

  int _selectedCategoryIndex = 0; // 0: All, 1: Private, 2: Groups
  final List<String> _categories = ['All', 'Private', 'Groups'];

  final Map<String, UserModel> _usersCache = {};
  final int _maxCacheSize = 100;

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

  Future<UserModel?> _getOrCreateUser(String uid) async {
    if (_usersCache.containsKey(uid)) return _usersCache[uid];
    final user = await FirebaseRepo.getUserById(uid);
    if (user != null) {
      if (_usersCache.length >= _maxCacheSize) {
        _usersCache.remove(_usersCache.keys.first);
      }
      _usersCache[uid] = user;
    }
    return user;
  }

  int _getTimestamp(dynamic timeData) {
    if (timeData == null) return 0;
    if (timeData is int) return timeData;
    try {
      return (timeData as dynamic).toDate().millisecondsSinceEpoch;
    } catch (_) {
      return 0;
    }
  }

  String _formatMessageTime(dynamic timeData) {
    if (timeData == null) return '';
    DateTime messageTime;
    try {
      if (timeData is int) {
        messageTime = DateTime.fromMillisecondsSinceEpoch(timeData);
      } else if (timeData.runtimeType.toString() == 'Timestamp' ||
          timeData.runtimeType.toString() != 'String') {
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
    final msgDay =
        DateTime(messageTime.year, messageTime.month, messageTime.day);
    final difference = today.difference(msgDay).inDays;

    if (difference == 0) return DateFormat('hh:mm a').format(messageTime);
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return DateFormat('EEEE').format(messageTime);
    return DateFormat('dd/MM/yyyy').format(messageTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_myUid.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6C63FF),
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        top: false, // تم الإلغاء للسماح للقائمة بالغوص تحت الهيدر والتصنيفات
        child: StreamBuilder<List<ChatModel>>(
          stream: FirebaseRepo.observeUserChats(_myUid),
          builder: (context, chatsSnapshot) {
            return StreamBuilder<List<GroupModel>>(
              stream: FirebaseRepo.observeUserGroups(_myUid),
              builder: (context, groupsSnapshot) {
                final bool isLoading =
                    !chatsSnapshot.hasData && !groupsSnapshot.hasData;
                final chats = chatsSnapshot.data ?? [];
                final groups = groupsSnapshot.data ?? [];

                // حساب عدد المحادثات الخاصة الغير مقروءة
                int unreadPrivateChats = chats
                    .where((chat) => (chat.unreadCounts[_myUid] ?? 0) > 0)
                    .length;

                // إذا كان للمجموعات عداد، يتم إضافته هنا
                int unreadGroupChats = 0; 
                int totalUnreadChats = unreadPrivateChats + unreadGroupChats;

                // استخدام Stack لفصل التصنيفات الزجاجية عن القائمة المتحركة
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // الطبقة السفلية: قائمة المحادثات (تتحرك بحرية)
                    _buildCombinedList(chats, groups, isLoading),

                    // الطبقة العلوية: شريط التصنيفات الزجاجي الطاير
                    Positioned(
                      top: 12, // مسافة أسفل الهيدر الزجاجي الرئيسي
                      left: 16,
                      right: 16,
                      child: _buildGlassCategoryTabs(
                          totalUnreadChats, unreadPrivateChats, unreadGroupChats),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // كبسولة التصنيفات الزجاجية (Floating Glass Pill)
  Widget _buildGlassCategoryTabs(
      int totalUnread, int privateUnread, int groupsUnread) {
    int getUnreadCountForIndex(int index) {
      if (index == 0) return totalUnread;
      if (index == 1) return privateUnread;
      if (index == 2) return groupsUnread;
      return 0;
    }

    final luxuryAccentColor = const Color(0xFF6C63FF);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        // بلور قوي ليعطي تأثير زجاجي عميق للشاتات في الخلفية
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A22).withOpacity(0.35),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: luxuryAccentColor.withOpacity(0.2),
              width: 0.8,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                luxuryAccentColor.withOpacity(0.1),
                Colors.white.withOpacity(0.02),
              ],
            ),
          ),
          child: Row(
            children: List.generate(_categories.length, (index) {
              final isSelected = _selectedCategoryIndex == index;
              final unreadChatsCount = getUnreadCountForIndex(index);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategoryIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? luxuryAccentColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: luxuryAccentColor.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _categories[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (unreadChatsCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: luxuryAccentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: luxuryAccentColor.withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            ),
                            child: Text(
                              unreadChatsCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // القائمة المفلترة حسب التصنيف (مع هندسة المسافات العلوية والسفلية)
  Widget _buildCombinedList(
      List<ChatModel> chats, List<GroupModel> groups, bool isLoading) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF6C63FF), strokeWidth: 3),
      );
    }

    final List<_CombinedListItem> combinedList = [];

    // 0: All | 1: Private (Chats)
    if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 1) {
      for (var chat in chats) {
        final isPinned = chat.pinnedBy.contains(_myUid);
        combinedList.add(_CombinedListItem(
          chat: chat,
          timestamp: _getTimestamp(chat.lastMessageTime),
          isPinned: isPinned,
        ));
      }
    }

    // 0: All | 2: Groups
    if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 2) {
      for (var group in groups) {
        combinedList.add(_CombinedListItem(
          group: group,
          timestamp: group.lastMessageTime,
          isPinned: false,
        ));
      }
    }

    // ترتيب زمني مع تقديم المثبت أولاً
    combinedList.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.timestamp.compareTo(a.timestamp);
    });

    if (combinedList.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'No activity yet',
          subtitle: 'Start chatting and make friends!',
        ),
      );
    }

    return ListView.builder(
      // Padding مخصص: 85 من فوق لتفادي التصنيفات الزجاجية، 120 من تحت لتفادي الـ Navigation Bar
      padding: const EdgeInsets.only(top: 85, bottom: 120, left: 8, right: 8),
      // BouncingScrollPhysics لإعطاء إحساس مرن واحترافي في السحب
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: combinedList.length,
      itemBuilder: (context, index) {
        final item = combinedList[index];
        if (item.chat != null) {
          return _buildChatItem(item.chat!);
        } else if (item.group != null) {
          return _buildGroupItem(item.group!);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    final otherUid =
        chat.participants.firstWhere((id) => id != _myUid, orElse: () => '');
    if (otherUid.isEmpty) return const SizedBox.shrink();

    final int unreadCount = chat.unreadCounts[_myUid] ?? 0;
    final bool isPinned = chat.pinnedBy.contains(_myUid);

    return FutureBuilder<UserModel?>(
      future: _getOrCreateUser(otherUid),
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const ModernChatListItemSkeleton();
        }
        final user = snapshot.data;
        final name = user?.displayName ?? 'Unknown User';
        final formattedTime = _formatMessageTime(chat.lastMessageTime);

        return ModernChatListItem(
          name: name,
          lastMessage:
              chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Tap to chat',
          time: formattedTime,
          avatarUrl: user?.avatarUrl,
          isOnline: user?.isOnline ?? false,
          unreadCount: unreadCount,
          isPinned: isPinned,
          onTap: () {
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

  Widget _buildGroupItem(GroupModel group) {
    final time = group.lastMessageTime > 0
        ? _formatMessageTime(group.lastMessageTime)
        : '';

    return ModernChatListItem(
      name: group.name,
      lastMessage:
          group.lastMessage.isNotEmpty ? group.lastMessage : 'Tap to chat',
      time: time,
      avatarUrl: null,
      isOnline: false,
      unreadCount: 0, 
      isPinned: false,
      onTap: () async {
        HapticFeedback.lightImpact();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupChatScreenUI(
              groupId: group.groupId,
              myUid: _myUid,
              myName: _myName,
              groupName: group.name,
              memberCount: group.members.length,
            ),
          ),
        );
      },
      onLongPress: () {},
    );
  }

  void _navigateToChat(
      String chatId, String otherUid, String name, String? avatarUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) =>
              ChatCubit(chatId: chatId, myUid: _myUid, myName: _myName),
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

  void _showChatOptionsBottomSheet(
      BuildContext context, ChatModel chat, String name, bool isPinned) {
    final luxuryAccentColor = const Color(0xFF6C63FF);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0E).withOpacity(0.9),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(36)),
                border: Border(
                  top: BorderSide(
                      color: luxuryAccentColor.withOpacity(0.25), width: 1),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        leading: Icon(
                            isPinned
                                ? Icons.push_pin_outlined
                                : Icons.push_pin,
                            color: Colors.white.withOpacity(0.9)),
                        title: Text(isPinned ? 'Unpin Chat' : 'Pin Chat',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        tileColor: Colors.white.withOpacity(0.02),
                        onTap: () async {
                          Navigator.pop(context);
                          await FirebaseRepo.togglePinChat(
                              chat.chatId, _myUid);
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.mark_chat_read_outlined,
                            color: Colors.white.withOpacity(0.9)),
                        title: const Text('Mark as Read',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        tileColor: Colors.white.withOpacity(0.02),
                        onTap: () async {
                          Navigator.pop(context);
                          await FirebaseRepo.resetUnreadCount(
                              chat.chatId, _myUid);
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFFF4D4D)),
                        title: const Text('Delete Chat',
                            style: TextStyle(
                                color: Color(0xFFFF4D4D),
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        tileColor: const Color(0xFFFF4D4D).withOpacity(0.05),
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 12),
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

class _CombinedListItem {
  final ChatModel? chat;
  final GroupModel? group;
  final int timestamp;
  final bool isPinned;

  _CombinedListItem({
    this.chat,
    this.group,
    required this.timestamp,
    required this.isPinned,
  });
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
    final Color onlineColor = const Color(0xFF8C82FF);
    final Color luxuryAccent = const Color(0xFF6C63FF);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: unreadCount > 0
            ? luxuryAccent.withOpacity(0.06)
            : (isPinned ? Colors.white.withOpacity(0.02) : Colors.transparent),
        border: Border.all(
          color: unreadCount > 0
              ? luxuryAccent.withOpacity(0.15)
              : (isPinned
                  ? Colors.white.withOpacity(0.05)
                  : Colors.transparent),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.white.withOpacity(0.03),
          highlightColor: Colors.white.withOpacity(0.01),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
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
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08), width: 1),
                      ),
                      child: (avatarUrl == null || avatarUrl!.isEmpty)
                          ? Center(
                              child: Text(
                                name.trim().isNotEmpty
                                    ? name.trim()[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            )
                          : null,
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: onlineColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0A0A0E),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
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
                                color: unreadCount > 0
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: unreadCount > 0
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPinned)
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Transform.rotate(
                                angle: 0.4,
                                child: Icon(Icons.push_pin_rounded,
                                    color: luxuryAccent.withOpacity(0.6),
                                    size: 14),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lastMessage,
                        style: TextStyle(
                          color: unreadCount > 0
                              ? Colors.white.withOpacity(0.85)
                              : Colors.white.withOpacity(0.45),
                          fontSize: 13.5,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w500
                              : FontWeight.normal,
                          letterSpacing: 0.1,
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
                        color: unreadCount > 0
                            ? luxuryAccent
                            : Colors.white.withOpacity(0.35),
                        fontSize: 11.5,
                        fontWeight: unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: luxuryAccent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: luxuryAccent.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 19),
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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.01),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.03),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 130,
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 190,
                  height: 11,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white.withOpacity(0.015),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 35,
            height: 11,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withOpacity(0.015),
            ),
          ),
        ],
      ),
    );
  }
}

