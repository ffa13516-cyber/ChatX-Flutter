import 'dart:ui'; [span_2](start_span)// 🚀 مسؤولة عن تأثيرات الزجاج والـ Blur الفاخرة[span_2](end_span)
import 'package:flutter/material.dart'; [span_3](start_span)//[span_3](end_span)
import 'package:flutter/services.dart'; [span_4](start_span)//[span_4](end_span)
import 'package:flutter_bloc/flutter_bloc.dart'; [span_5](start_span)//[span_5](end_span)
import 'package:intl/intl.dart'; [span_6](start_span)//[span_6](end_span)
import 'package:chatx/screens/chat/cubit/chat_cubit.dart'; [span_7](start_span)//[span_7](end_span)
import '../../models/models.dart'; [span_8](start_span)//[span_8](end_span)
import '../../repositories/firebase_repo.dart'; [span_9](start_span)//[span_9](end_span)
import '../../utils/app_colors.dart'; [span_10](start_span)//[span_10](end_span)
import '../../utils/session_manager.dart'; [span_11](start_span)//[span_11](end_span)
import '../../widgets/widgets.dart'; [span_12](start_span)//[span_12](end_span)
import 'chat_screen.dart'; [span_13](start_span)//[span_13](end_span)

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key}); [span_14](start_span)//[span_14](end_span)

  @override
  State<ChatsTab> createState() => _ChatsTabState(); [span_15](start_span)//[span_15](end_span)
}

class _ChatsTabState extends State<ChatsTab> {
  String _myUid = ''; [span_16](start_span)//[span_16](end_span)
  String _myName = ''; [span_17](start_span)//[span_17](end_span)
  [span_18](start_span)// ✅ كاش محلي مع حماية ضد الـ Memory Leak[span_18](end_span)
  final Map<String, UserModel> _usersCache = {}; [span_19](start_span)//[span_19](end_span)
  final int _maxCacheSize = 100; [span_20](start_span)// الحد الأقصى لتخزين المستخدمين[span_20](end_span)

  @override
  void initState() {
    super.initState(); [span_21](start_span)//[span_21](end_span)
    _loadUser(); [span_22](start_span)//[span_22](end_span)
  }

  Future<void> _loadUser() async {
    final uid = await SessionManager.instance.getUid(); [span_23](start_span)//[span_23](end_span)
    final name = await SessionManager.instance.getName(); [span_24](start_span)//[span_24](end_span)
    if (!mounted) return; [span_25](start_span)//[span_25](end_span)
    setState(() {
      _[span_26](start_span)myUid = uid; //[span_26](end_span)
      _myName = name; [span_27](start_span)//[span_27](end_span)
    });
  [span_28](start_span)} //[span_28](end_span)

  [span_29](start_span)// ✅ دالة ذكية لإدارة الكاش بكفاءة عالية[span_29](end_span)
  Future<UserModel?> _getOrCreateUser(String uid) async {
    if (_usersCache.containsKey(uid)) {
      return _usersCache[uid]; [span_30](start_span)//[span_30](end_span)
    }
    final user = await FirebaseRepo.getUserById(uid); [span_31](start_span)//[span_31](end_span)
    if (user != null) {
      if (_usersCache.length >= _maxCacheSize) {
        [span_32](start_span)// تفريغ أقدم عنصر في حال امتلاء الكاش للحفاظ على الرامات[span_32](end_span)
        _usersCache.remove(_usersCache.keys.first); [span_33](start_span)//[span_33](end_span)
      }
      _usersCache[uid] = user; [span_34](start_span)//[span_34](end_span)
    }
    return user; [span_35](start_span)//[span_35](end_span)
  }

  String _formatMessageTime(dynamic timeData) {
    if (timeData == null) return ''; [span_36](start_span)//[span_36](end_span)
    
    DateTime messageTime; [span_37](start_span)//[span_37](end_span)
    try {
      if (timeData is int) {
        messageTime = DateTime.fromMillisecondsSinceEpoch(timeData); [span_38](start_span)//[span_38](end_span)
      [span_39](start_span)} else if (timeData.runtimeType.toString() == 'Timestamp' || timeData.runtimeType.toString() != 'String') { //[span_39](end_span)
        messageTime = (timeData as dynamic).toDate(); [span_40](start_span)//[span_40](end_span)
      } else {
        return ''; [span_41](start_span)//[span_41](end_span)
      }
    } catch (e) {
      debugPrint("Error formatting time: $e"); [span_42](start_span)//[span_42](end_span)
      return ''; [span_43](start_span)//[span_43](end_span)
    }

    final now = DateTime.now(); [span_44](start_span)//[span_44](end_span)
    final today = DateTime(now.year, now.month, now.day); [span_45](start_span)//[span_45](end_span)
    final msgDay = DateTime(messageTime.year, messageTime.month, messageTime.day); [span_46](start_span)//[span_46](end_span)
    final difference = today.difference(msgDay).inDays; [span_47](start_span)//[span_47](end_span)

    if (difference == 0) {
      return DateFormat('hh:mm a').format(messageTime); [span_48](start_span)//[span_48](end_span)
    } else if (difference == 1) {
      return 'Yesterday'; [span_49](start_span)//[span_49](end_span)
    } else if (difference < 7) {
      return DateFormat('EEEE').format(messageTime); [span_50](start_span)//[span_50](end_span)
    } else {
      return DateFormat('dd/MM/yyyy').format(messageTime); [span_51](start_span)//[span_51](end_span)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      [span_52](start_span)backgroundColor: Colors.transparent, //[span_52](end_span)
      body: SafeArea(
        [span_53](start_span)bottom: false, //[span_53](end_span)
        [span_54](start_span)child: _buildChatsList(), //[span_54](end_span)
      ),
    );
  [span_55](start_span)} //[span_55](end_span)

  Widget _buildChatsList() {
    if (_myUid.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          [span_56](start_span)color: Color(0xFF6C63FF), // البنفسجي الفخم كلون أساسي للتحميل[span_56](end_span)
          [span_57](start_span)strokeWidth: 3, //[span_57](end_span)
        ),
      );
    }

    return StreamBuilder<List<ChatModel>>(
      [span_58](start_span)stream: FirebaseRepo.observeUserChats(_myUid), //[span_58](end_span)
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              [span_59](start_span)'Error: ${snapshot.error}', //[span_59](end_span)
              [span_60](start_span)style: const TextStyle(color: Colors.redAccent), //[span_60](end_span)
            [span_61](start_span)), //[span_61](end_span)
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF), strokeWidth: 3)); [span_62](start_span)//[span_62](end_span)
        }

        final chats = snapshot.data!; [span_63](start_span)//[span_63](end_span)

        if (chats.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              [span_64](start_span)icon: Icons.chat_bubble_outline_rounded, //[span_64](end_span)
              [span_65](start_span)title: 'No chats yet', //[span_65](end_span)
              [span_66](start_span)subtitle: 'Start chatting and make friends!', //[span_66](end_span)
            ),
          );
        }

        // ترتيب المحادثات: المثبتة أولاً ثم الأحدث
        chats.sort((a, b) {
          [span_67](start_span)bool aPinned = a.pinnedBy.contains(_myUid); //[span_67](end_span)
          bool bPinned = b.pinnedBy.contains(_myUid); [span_68](start_span)//[span_68](end_span)
          if (aPinned && !bPinned) return -1; [span_69](start_span)//[span_69](end_span)
          if (!aPinned && bPinned) return 1; [span_70](start_span)//[span_70](end_span)
          
          return b.lastMessageTime.compareTo(a.lastMessageTime); [span_71](start_span)//[span_71](end_span)
        });

        [span_72](start_span)// ✅ تحويل إلى ListView.builder لإزالة الفاصلات (Dividers) تماماً والاعتماد على المسافات الهوائية المريحة للعين[span_72](end_span)
        return ListView.builder(
          [span_73](start_span)padding: const EdgeInsets.only(top: 12, bottom: 120, left: 12, right: 12), //[span_73](end_span)
          [span_74](start_span)itemCount: chats.length, //[span_74](end_span)
          itemBuilder: (context, index) {
            return _buildChatItem(chats[index]); [span_75](start_span)//[span_75](end_span)
          },
        );
      [span_76](start_span)}, //[span_76](end_span)
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    final otherUid = chat.participants.firstWhere((id) => id != _myUid, orElse: () => ''); [span_77](start_span)//[span_77](end_span)
    if (otherUid.isEmpty) return const SizedBox.shrink(); [span_78](start_span)//[span_78](end_span)

    final int unreadCount = chat.unreadCounts[_myUid] ?? 0; [span_79](start_span)//[span_79](end_span)
    final bool isPinned = chat.pinnedBy.contains(_myUid); [span_80](start_span)//[span_80](end_span)

    return FutureBuilder<UserModel?>(
      [span_81](start_span)future: _getOrCreateUser(otherUid), //[span_81](end_span)
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
           return const ModernChatListItemSkeleton(); [span_82](start_span)//[span_82](end_span)
        }

        final user = snapshot.data; [span_83](start_span)//[span_83](end_span)
        final name = user?.displayName ?? 'Unknown User'; [span_84](start_span)//[span_84](end_span)
        final formattedTime = _formatMessageTime(chat.lastMessageTime); [span_85](start_span)//[span_85](end_span)

        return ModernChatListItem(
          [span_86](start_span)name: name, //[span_86](end_span)
          [span_87](start_span)lastMessage: chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Tap to chat', //[span_87](end_span)
          [span_88](start_span)time: formattedTime, //[span_88](end_span)
          [span_89](start_span)avatarUrl: user?.avatarUrl, //[span_89](end_span)
          [span_90](start_span)isOnline: user?.isOnline ?? false, //[span_90](end_span)
          [span_91](start_span)unreadCount: unreadCount, //[span_91](end_span)
          [span_92](start_span)isPinned: isPinned, //[span_92](end_span)
          onTap: () async {
            HapticFeedback.lightImpact(); [span_93](start_span)//[span_93](end_span)
            _navigateToChat(chat.chatId, otherUid, name, user?.avatarUrl); [span_94](start_span)//[span_94](end_span)
          },
          onLongPress: () {
            HapticFeedback.mediumImpact(); [span_95](start_span)//[span_95](end_span)
            _showChatOptionsBottomSheet(context, chat, name, isPinned); [span_96](start_span)//[span_96](end_span)
          },
        );
      },
    );
  [span_97](start_span)} //[span_97](end_span)

  void _navigateToChat(String chatId, String otherUid, String name, String? avatarUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          [span_98](start_span)create: (context) => ChatCubit(chatId: chatId, myUid: _myUid, myName: _myName), //[span_98](end_span)
          child: ChatScreen(
            [span_99](start_span)chatId: chatId, //[span_99](end_span)
            [span_100](start_span)myUid: _myUid, //[span_100](end_span)
            [span_101](start_span)myName: _myName, //[span_101](end_span)
            [span_102](start_span)receiverName: name, //[span_102](end_span)
            [span_103](start_span)receiverImage: avatarUrl, //[span_103](end_span)
          ),
        ),
      ),
    );
  [span_104](start_span)} //[span_104](end_span)

  [span_105](start_span)// ✅ ترقية القائمة الزجاجية إلى Dark Luxury Glass المتناسقة مع الكود الثاني[span_105](end_span)
  void _showChatOptionsBottomSheet(BuildContext context, ChatModel chat, String name, bool isPinned) {
    final luxuryAccentColor = const Color(0xFF6C63FF); [span_106](start_span)//[span_106](end_span)
    showModalBottomSheet(
      [span_107](start_span)context: context, //[span_107](end_span)
      [span_108](start_span)backgroundColor: Colors.transparent, //[span_108](end_span)
      [span_109](start_span)elevation: 0, //[span_109](end_span)
      [span_110](start_span)isScrollControlled: true, //[span_110](end_span)
      builder: (context) {
        return ClipRRect(
          [span_111](start_span)borderRadius: const BorderRadius.vertical(top: Radius.circular(36)), //[span_111](end_span)
          child: BackdropFilter(
            [span_112](start_span)filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // زيادة البلور للفخامة[span_112](end_span)
            child: Container(
              decoration: BoxDecoration(
                [span_113](start_span)// استخدام الأسود الأعمق الممزوج بشفافية الزجاج الفاخر[span_113](end_span)
                [span_114](start_span)color: const Color(0xFF0A0A0E).withOpacity(0.9), //[span_114](end_span)
                [span_115](start_span)borderRadius: const BorderRadius.vertical(top: Radius.circular(36)), //[span_115](end_span)
                border: Border(
                  [span_116](start_span)// حافة علوية دقيقة باللون البنفسجي الفاخر لإضاءة الحواف[span_116](end_span)
                  [span_117](start_span)top: BorderSide(color: luxuryAccentColor.withOpacity(0.25), width: 1), //[span_117](end_span)
                ),
              ),
              child: SafeArea(
                child: Padding(
                  [span_118](start_span)padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20), //[span_118](end_span)
                  child: Column(
                    [span_119](start_span)mainAxisSize: MainAxisSize.min, //[span_119](end_span)
                    children: [
                      Container(
                        [span_120](start_span)width: 40, //[span_120](end_span)
                        [span_121](start_span)height: 4, //[span_121](end_span)
                        decoration: BoxDecoration(
                          [span_122](start_span)color: Colors.white.withOpacity(0.15), //[span_122](end_span)
                          [span_123](start_span)borderRadius: BorderRadius.circular(10), //[span_123](end_span)
                        ),
                      ),
                      [span_124](start_span)const SizedBox(height: 24), //[span_124](end_span)
                      Text(
                        [span_125](start_span)name, //[span_125](end_span)
                        style: const TextStyle(
                          [span_126](start_span)color: Colors.white, //[span_126](end_span)
                          [span_127](start_span)fontSize: 19, //[span_127](end_span)
                          [span_128](start_span)fontWeight: FontWeight.w700, //[span_128](end_span)
                          [span_129](start_span)letterSpacing: 0.3 //[span_129](end_span)
                        ),
                      ),
                      [span_130](start_span)const SizedBox(height: 24), //[span_130](end_span)
                      
                      ListTile(
                        [span_131](start_span)leading: Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin, color: Colors.white.withOpacity(0.9)), //[span_131](end_span)
                        [span_132](start_span)title: Text(isPinned ? 'Unpin Chat' : 'Pin Chat', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)), //[span_132](end_span)
                        [span_133](start_span)shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), //[span_133](end_span)
                        [span_134](start_span)tileColor: Colors.white.withOpacity(0.02), //[span_134](end_span)
                        onTap: () async {
                          Navigator.pop(context); [span_135](start_span)//[span_135](end_span)
                          await FirebaseRepo.togglePinChat(chat.chatId, _myUid); [span_136](start_span)//[span_136](end_span)
                        },
                      ),
                      [span_137](start_span)const SizedBox(height: 10), //[span_137](end_span)
                      ListTile(
                        [span_138](start_span)leading: Icon(Icons.mark_chat_read_outlined, color: Colors.white.withOpacity(0.9)), //[span_138](end_span)
                        [span_139](start_span)title: const Text('Mark as Read', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)), //[span_139](end_span)
                        [span_140](start_span)shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), //[span_140](end_span)
                        [span_141](start_span)tileColor: Colors.white.withOpacity(0.02), //[span_141](end_span)
                        onTap: () async {
                          Navigator.pop(context); [span_142](start_span)//[span_142](end_span)
                          await FirebaseRepo.resetUnreadCount(chat.chatId, _myUid); [span_143](start_span)//[span_143](end_span)
                        },
                      [span_144](start_span)), //[span_144](end_span)
                      [span_145](start_span)const SizedBox(height: 10), //[span_145](end_span)
                      ListTile(
                        [span_146](start_span)leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF4D4D)), //[span_146](end_span)
                        [span_147](start_span)title: const Text('Delete Chat', style: TextStyle(color: Color(0xFFFF4D4D), fontSize: 15, fontWeight: FontWeight.w600)), //[span_147](end_span)
                        [span_148](start_span)shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), //[span_148](end_span)
                        [span_149](start_span)tileColor: const Color(0xFFFF4D4D).withOpacity(0.05), //[span_149](end_span)
                        onTap: () {
                          Navigator.pop(context); [span_150](start_span)//[span_150](end_span)
                        },
                      ),
                      [span_151](start_span)const SizedBox(height: 12), //[span_151](end_span)
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      [span_152](start_span)}, //[span_152](end_span)
    );
  }
}

// =========================================================================
// ويدجت العناصر المعاد تصميمها لتوفير راحة بصرية فائقة (Premium Matte Edition)
// =========================================================================

class ModernChatListItem extends StatelessWidget {
  final String name; [span_153](start_span)//[span_153](end_span)
  final String lastMessage; [span_154](start_span)//[span_154](end_span)
  final String time; [span_155](start_span)//[span_155](end_span)
  final String? avatarUrl; [span_156](start_span)//[span_156](end_span)
  final bool isOnline; [span_157](start_span)//[span_157](end_span)
  final int unreadCount; [span_158](start_span)//[span_158](end_span)
  final bool isPinned; [span_159](start_span)//[span_159](end_span)
  final VoidCallback onTap; [span_160](start_span)//[span_160](end_span)
  final VoidCallback onLongPress; [span_161](start_span)//[span_161](end_span)

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
    // لوحة الألوان الفاخرة المطفية والمريحة للعين (UI/UX Optimized)
    final Color onlineIndicatorColor = const Color(0xFF8B5CF6); // بنفسجي مطفي وراقي جداً (Violet/Matte Purple) بدلاً من الأخضر الفاقع
    final Color deepMattePurple = const Color(0xFF6D28D9);      // بنفسجي عميق مريح للعين لعداد الرسائل غير المقروءة لمنع تشتت العين
    final Color luxuryAccent = const Color(0xFF6C63FF);         [span_162](start_span)// التناسق التام مع حزمة الـ Luxury البنفسجية للهيكل[span_162](end_span)

    return Container(
      [span_163](start_span)// زيادة الـ vertical margin يعطي مساحات هوائية ويغني عن الفواصل التقليدية[span_163](end_span)
      [span_164](start_span)margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6), //[span_164](end_span)
      decoration: BoxDecoration(
        [span_165](start_span)borderRadius: BorderRadius.circular(24), // حواف دائرية فخمة جداً متطابقة مع الـ Appbar والـ Navbar[span_165](end_span)
        color: unreadCount > 0 
            [span_166](start_span)? luxuryAccent.withOpacity(0.06) // توهج خلفي ناعم جداً للمسجات غير المقروءة[span_166](end_span)
            [span_167](start_span): (isPinned ? Colors.white.withOpacity(0.02) : Colors.transparent), //[span_167](end_span)
        border: Border.all(
          color: unreadCount > 0 
              [span_168](start_span)? luxuryAccent.withOpacity(0.15) // حافة دقيقة بلون التوهج[span_168](end_span)
              [span_169](start_span): (isPinned ? Colors.white.withOpacity(0.05) : Colors.transparent), //[span_169](end_span)
          width: 0.8,
        ),
      ),
      child: Material(
        [span_170](start_span)color: Colors.transparent, //[span_170](end_span)
        child: InkWell(
          [span_171](start_span)borderRadius: BorderRadius.circular(24), //[span_171](end_span)
          [span_172](start_span)splashColor: Colors.white.withOpacity(0.03), //[span_172](end_span)
          [span_173](start_span)highlightColor: Colors.white.withOpacity(0.01), //[span_173](end_span)
          [span_174](start_span)onTap: onTap, //[span_174](end_span)
          [span_175](start_span)onLongPress: onLongPress, //[span_175](end_span)
          child: Padding(
            [span_176](start_span)padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0), // مسافات مريحة للعين أثناء القراءة[span_176](end_span)
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      [span_177](start_span)width: 56, // تكبير دقيق ومدروس للأفاتار لراحة العين[span_177](end_span)
                      [span_178](start_span)height: 56, //[span_178](end_span)
                      decoration: BoxDecoration(
                        [span_179](start_span)shape: BoxShape.circle, //[span_179](end_span)
                        color: (avatarUrl == null || avatarUrl!.isEmpty) 
                            ? [span_180](start_span)AppColors.avatarColor(name) //[span_180](end_span)
                            [span_181](start_span): Colors.transparent, //[span_181](end_span)
                        image: (avatarUrl != null && avatarUrl!.isNotEmpty)
                            ? DecorationImage(
                                [span_182](start_span)image: NetworkImage(avatarUrl!), //[span_182](end_span)
                                [span_183](start_span)fit: BoxFit.cover, //[span_183](end_span)
                              )
                            [span_184](start_span): null, //[span_184](end_span)
                        [span_185](start_span)border: Border.all(color: Colors.white.withOpacity(0.08), width: 1), //[span_185](end_span)
                      ),
                      child: (avatarUrl == null || avatarUrl!.isEmpty)
                          ? Center(
                              child: Text(
                                [span_186](start_span)name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?', //[span_186](end_span)
                                style: const TextStyle(
                                  [span_187](start_span)color: Colors.white, //[span_187](end_span)
                                  [span_188](start_span)fontWeight: FontWeight.bold, //[span_188](end_span)
                                  [span_189](start_span)fontSize: 20, //[span_189](end_span)
                                ),
                              ),
                            )
                          [span_190](start_span): null, //[span_190](end_span)
                    ),
                    // 1. نقطة حالة الاتصال بالإنترنت (تتحقق وتظهر بشكل صارم فقط في حال كان المستخدم متصلاً بالإنترنت)
                    if (isOnline == true)
                      Positioned(
                        [span_191](start_span)bottom: 1, //[span_191](end_span)
                        [span_192](start_span)right: 1, //[span_192](end_span)
                        child: Container(
                          [span_193](start_span)width: 14, //[span_193](end_span)
                          [span_194](start_span)height: 14, //[span_194](end_span)
                          decoration: BoxDecoration(
                            color: onlineIndicatorColor, 
                            [span_195](start_span)shape: BoxShape.circle, //[span_195](end_span)
                            border: Border.all(
                              [span_196](start_span)color: const Color(0xFF0A0A0E), // حافة مطابقة للأسود الأعمق المعتمد في الملف[span_196](end_span)
                              [span_197](start_span)width: 2.5, //[span_197](end_span)
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                [span_198](start_span)const SizedBox(width: 14), //[span_198](end_span)
                Expanded(
                  child: Column(
                    [span_199](start_span)crossAxisAlignment: CrossAxisAlignment.start, //[span_199](end_span)
                    [span_200](start_span)mainAxisAlignment: MainAxisAlignment.center, //[span_200](end_span)
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              [span_201](start_span)name, //[span_201](end_span)
                              style: TextStyle(
                                [span_202](start_span)color: unreadCount > 0 ? Colors.white : Colors.white.withOpacity(0.9), //[span_202](end_span)
                                [span_203](start_span)fontSize: 16, //[span_203](end_span)
                                fontWeight: unreadCount > 0 ? [span_204](start_span)FontWeight.w700 : FontWeight.w600, //[span_204](end_span)
                                [span_205](start_span)letterSpacing: 0.2, //[span_205](end_span)
                              ),
                              [span_206](start_span)maxLines: 1, //[span_206](end_span)
                              [span_207](start_span)overflow: TextOverflow.ellipsis, //[span_207](end_span)
                            ),
                          ),
                          if (isPinned)
                            Padding(
                              [span_208](start_span)padding: const EdgeInsets.only(left: 6.0), //[span_208](end_span)
                              child: Transform.rotate(
                                [span_209](start_span)angle: 0.4, //[span_209](end_span)
                                [span_210](start_span)child: Icon(Icons.push_pin_rounded, color: luxuryAccent.withOpacity(0.6), size: 14), //[span_210](end_span)
                              ),
                            ),
                        ],
                      ),
                      [span_211](start_span)const SizedBox(height: 6), //[span_211](end_span)
                      Text(
                        [span_212](start_span)lastMessage, //[span_212](end_span)
                        style: TextStyle(
                          [span_213](start_span)color: unreadCount > 0 ? Colors.white.withOpacity(0.85) : Colors.white.withOpacity(0.45), //[span_213](end_span)
                          [span_214](start_span)fontSize: 13.5, //[span_214](end_span)
                          fontWeight: unreadCount > 0 ? [span_215](start_span)FontWeight.w500 : FontWeight.normal, //[span_215](end_span)
                          [span_216](start_span)letterSpacing: 0.1, //[span_216](end_span)
                        ),
                        [span_217](start_span)maxLines: 1, //[span_217](end_span)
                        [span_218](start_span)overflow: TextOverflow.ellipsis, //[span_218](end_span)
                      ),
                    ],
                  ),
                ),
                [span_219](start_span)const SizedBox(width: 8), //[span_219](end_span)
                Column(
                  [span_220](start_span)crossAxisAlignment: CrossAxisAlignment.end, //[span_220](end_span)
                  [span_221](start_span)mainAxisAlignment: MainAxisAlignment.center, //[span_221](end_span)
                  children: [
                    Text(
                      [span_222](start_span)time, //[span_222](end_span)
                      style: TextStyle(
                        [span_223](start_span)color: unreadCount > 0 ? deepMattePurple : Colors.white.withOpacity(0.35), //[span_223](end_span)
                        [span_224](start_span)fontSize: 11.5, //[span_224](end_span)
                        fontWeight: unreadCount > 0 ? [span_225](start_span)FontWeight.bold : FontWeight.normal, //[span_225](end_span)
                      ),
                    ),
                    [span_226](start_span)const SizedBox(height: 8), //[span_226](end_span)
                    // 2. عداد الرسائل غير المقروءة الفاخر (UI/UX Flat Design)
                    if (unreadCount > 0)
                      Container(
                        [span_227](start_span)padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), //[span_227](end_span)
                        decoration: BoxDecoration(
                          color: deepMattePurple, // لون بنفسجي داكن مطفي مريح جداً للعين عند القراءة لفترات طويلة
                          [span_228](start_span)borderRadius: BorderRadius.circular(10), //[span_228](end_span)
                          [span_229](start_span)// تم حذف التوهج والـ BoxShadow المزعج تماماً للحفاظ على فخامة التصميم الـ Flat وحماية العين [cite: 100-102]
                        ),
                        child: Text(
                          [cite_start]unreadCount.toString(), //[span_229](end_span)
                          style: TextStyle(
                            [span_230](start_span)color: Colors.white.withOpacity(0.9), // أبيض ناعم جداً هادئ وغير مشع لتقليل التباين الحاد[span_230](end_span)
                            [span_231](start_span)fontSize: 11, //[span_231](end_span)
                            [span_232](start_span)fontWeight: FontWeight.w900, //[span_232](end_span)
                          ),
                        ),
                      )
                    else
                      [span_233](start_span)const SizedBox(height: 19), //[span_233](end_span)
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
  const ModernChatListItemSkeleton({super.key}); [span_234](start_span)//[span_234](end_span)

  @override
  Widget build(BuildContext context) {
    return Container(
      [span_235](start_span)margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6), //[span_235](end_span)
      [span_236](start_span)padding: const EdgeInsets.all(14.0), //[span_236](end_span)
      decoration: BoxDecoration(
        [span_237](start_span)borderRadius: BorderRadius.circular(24), //[span_237](end_span)
        [span_238](start_span)color: Colors.white.withOpacity(0.01), //[span_238](end_span)
      ),
      child: Row(
        children: [
          Container(
            [span_239](start_span)width: 56, //[span_239](end_span)
            [span_240](start_span)height: 56, //[span_240](end_span)
            decoration: BoxDecoration(
              [span_241](start_span)shape: BoxShape.circle, //[span_241](end_span)
              [span_242](start_span)color: Colors.white.withOpacity(0.03), //[span_242](end_span)
            ),
          ),
          [span_243](start_span)const SizedBox(width: 14), //[span_243](end_span)
          Expanded(
            child: Column(
              [span_244](start_span)crossAxisAlignment: CrossAxisAlignment.start, //[span_244](end_span)
              children: [
                Container(
                  [span_245](start_span)width: 130, //[span_245](end_span)
                  [span_246](start_span)height: 14, //[span_246](end_span)
                  decoration: BoxDecoration(
                    [span_247](start_span)borderRadius: BorderRadius.circular(6), //[span_247](end_span)
                    [span_248](start_span)color: Colors.white.withOpacity(0.03), //[span_248](end_span)
                  ),
                ),
                [span_249](start_span)const SizedBox(height: 10), //[span_249](end_span)
                Container(
                  [span_250](start_span)width: 190, //[span_250](end_span)
                  [span_251](start_span)height: 11, //[span_251](end_span)
                  decoration: BoxDecoration(
                    [span_252](start_span)borderRadius: BorderRadius.circular(4), //[span_252](end_span)
                    [span_253](start_span)color: Colors.white.withOpacity(0.015), //[span_253](end_span)
                  ),
                ),
              ],
            ),
          ),
          [span_254](start_span)const SizedBox(width: 8), //[span_254](end_span)
          Container(
            [span_255](start_span)width: 35, //[span_255](end_span)
            [span_256](start_span)height: 11, //[span_256](end_span)
            decoration: BoxDecoration(
              [span_257](start_span)borderRadius: BorderRadius.circular(4), //[span_257](end_span)
              [span_258](start_span)color: Colors.white.withOpacity(0.015), //[span_258](end_span)
            ),
          ),
        ],
      ),
    );
  }
}

