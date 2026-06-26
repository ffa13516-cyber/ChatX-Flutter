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
import '../group/groups_tab.dart'; // âœ… Ø¹Ø´Ø§Ù† GroupChatScreen Ùˆ CreateGroupSheet

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  String _myUid = '';
  String _myName = '';

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: _buildCombinedList(),
      ),
    );
  }

  // âœ… Ø§Ù„Ù‚Ø§Ø¦Ù…Ø© Ø§Ù„Ù…ÙˆØ­Ø¯Ø© â€” Ø´Ø§ØªØ³ + Ø¬Ø±ÙˆØ¨Ø§Øª ÙÙŠ Ù†ÙØ³ Ø§Ù„Ù€ scroll
  Widget _buildCombinedList() {
    if (_myUid.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C63FF),
          strokeWidth: 3,
        ),
      );
    }

    return StreamBuilder<List<ChatModel>>(
      stream: FirebaseRepo.observeUserChats(_myUid),
      builder: (context, chatsSnapshot) {
        return StreamBuilder<List<GroupModel>>(
          stream: FirebaseRepo.observeUserGroups(_myUid),
          builder: (context, groupsSnapshot) {
            final chats = chatsSnapshot.data ?? [];
            final groups = groupsSnapshot.data ?? [];

            // ØªØ±ØªÙŠØ¨ Ø§Ù„Ø´Ø§ØªØ³: Ø§Ù„Ù…Ø«Ø¨ØªØ© Ø£ÙˆÙ„Ø§Ù‹ Ø«Ù… Ø§Ù„Ø£Ø­Ø¯Ø«
            chats.sort((a, b) {
              bool aPinned = a.pinnedBy.contains(_myUid);
              bool bPinned = b.pinnedBy.contains(_myUid);
              if (aPinned && !bPinned) return -1;
              if (!aPinned && bPinned) return 1;
              return b.lastMessageTime.compareTo(a.lastMessageTime);
            });

            final bool noData = chats.isEmpty && groups.isEmpty;
            final bool isLoading = !chatsSnapshot.hasData && !groupsSnapshot.hasData;

            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF6C63FF), strokeWidth: 3),
              );
            }

            if (noData) {
              return const Center(
                child: EmptyStateWidget(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No chats yet',
                  subtitle: 'Start chatting and make friends!',
                ),
              );
            }

            // âœ… Ø¨Ù†Ø§Ø¡ Ø§Ù„Ù‚Ø§Ø¦Ù…Ø© Ø§Ù„Ù…ÙˆØ­Ø¯Ø©
            return CustomScrollView(
              slivers: [
                // â”€â”€â”€â”€â”€ Ù‚Ø³Ù… Ø§Ù„Ø´Ø§ØªØ³ â”€â”€â”€â”€â”€
                if (chats.isNotEmpty) ...[
                  _buildSectionHeader('Messages', Icons.chat_bubble_outline_rounded),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildChatItem(chats[index]),
                        childCount: chats.length,
                      ),
                    ),
                  ),
                ],

                // â”€â”€â”€â”€â”€ Ù‚Ø³Ù… Ø§Ù„Ø¬Ø±ÙˆØ¨Ø§Øª â”€â”€â”€â”€â”€
                if (groups.isNotEmpty) ...[
                  _buildSectionHeader('Groups', Icons.group_outlined),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildGroupItem(groups[index]),
                        childCount: groups.length,
                      ),
                    ),
                  ),
                ],

                // âœ… Ø²Ø±Ø§Ø± Create Group ÙÙŠ Ø§Ù„Ø£Ø³ÙÙ„ Ù„Ùˆ ÙÙŠ Ø¬Ø±ÙˆØ¨Ø§Øª Ø£Ùˆ Ø§Ù„ÙƒÙ„ ÙØ§Ø¶ÙŠ
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  sliver: SliverToBoxAdapter(
                    child: _buildCreateGroupButton(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // â”€â”€â”€â”€â”€ Section Header â”€â”€â”€â”€â”€
  Widget _buildSectionHeader(String title, IconData icon) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6C63FF), size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€â”€â”€â”€ Chat Item (Ù…ÙˆØ¬ÙˆØ¯ Ù…Ù† Ù‚Ø¨Ù„) â”€â”€â”€â”€â”€
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

  // â”€â”€â”€â”€â”€ Group Item â”€â”€â”€â”€â”€
  Widget _buildGroupItem(GroupModel group) {
    final time = group.lastMessageTime > 0
        ? _formatMessageTime(group.lastMessageTime)
        : '';

    return ModernChatListItem(
      name: group.name,
      lastMessage:
          group.lastMessage.isNotEmpty ? group.lastMessage : 'Tap to chat',
      time: time,
      avatarUrl: null, // Ø§Ù„Ø¬Ø±ÙˆØ¨Ø§Øª Ù…ÙÙŠÙ‡Ø§Ø´ ØµÙˆØ±Ø© â€” Ù‡ÙŠØªØ¹Ù…Ù„ avatar Ø¨Ø§Ù„Ø­Ø±Ù Ø§Ù„Ø£ÙˆÙ„
      isOnline: false,
      unreadCount: 0,
      isPinned: false,
      onTap: () {
        HapticFeedback.lightImpact();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                GroupChatScreen(group: group, myUid: _myUid),
          ),
        );
      },
      onLongPress: () {},
    );
  }

  // â”€â”€â”€â”€â”€ Create Group Button â”€â”€â”€â”€â”€
  Widget _buildCreateGroupButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => CreateGroupSheet(myUid: _myUid),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            width: 1,
          ),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.08),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add_rounded,
                color: const Color(0xFF6C63FF).withOpacity(0.8), size: 20),
            const SizedBox(width: 10),
            Text(
              '+ Create Group',
              style: TextStyle(
                color: const Color(0xFF6C63FF).withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
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

// ==========================================
// Widgets Ø§Ù„Ù…Ø³Ø§Ø¹Ø¯Ø© (Ù…Ø­ØªÙØ¸ Ø¨ÙŠÙ‡Ø§ ÙƒÙ…Ø§ Ù‡ÙŠ)
// ==========================================

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
