import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../screens/chat/models/message_model.dart';

class FirebaseRepo {
  static final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    // 🛡️ ملاحظة أمنية: يُفضل مستقبلاً وضع هذا الرابط في ملف بيئة (.env)
    databaseURL: 'https://messengerapp-d6e7c-default-rtdb.firebaseio.com',
  );
  static const _uuid = Uuid();

  static DatabaseReference get usersRef => _db.ref('users');
  static DatabaseReference get chatsRef => _db.ref('chats');
  static DatabaseReference get messagesRef => _db.ref('messages');
  static DatabaseReference get groupsRef => _db.ref('groups');
  static DatabaseReference get groupMsgsRef => _db.ref('groupMessages');
  static DatabaseReference get channelsRef => _db.ref('channels');
  static DatabaseReference get channelMsgsRef => _db.ref('channelMessages');

  // ───────────────────────── Users ─────────────────────────

  static Future<void> saveUser(UserModel user) async {
    await usersRef.child(user.uid).set(user.toMap());
  }

  static Future<UserModel?> getUserById(String uid) async {
    final snap = await usersRef.child(uid).get();
    if (!snap.exists) return null;
    return UserModel.fromMap(snap.value as Map);
  }

  static Future<UserModel?> getUserByPhone(String phone) async {
    final snap = await usersRef.orderByChild('phoneNumber').equalTo(phone).get();
    if (!snap.exists) return null;
    final map = snap.value as Map;
    return UserModel.fromMap(map.values.first as Map);
  }

  static Future<UserModel?> getUserByUsername(String username) async {
    final snap = await usersRef.orderByChild('username').equalTo(username).get();
    if (!snap.exists) return null;
    final map = snap.value as Map;
    return UserModel.fromMap(map.values.first as Map);
  }

  static Future<List<UserModel>> getAllUsers({int limit = 100}) async {
    final snap = await usersRef.limitToFirst(limit).get();
    if (!snap.exists) return [];
    final map = snap.value as Map;
    return map.values.map((v) => UserModel.fromMap(v as Map)).toList();
  }

  static Stream<UserModel?> observeUser(String uid) {
    return usersRef.child(uid).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return UserModel.fromMap(event.snapshot.value as Map);
    });
  }

  // ───────────────────────── Chats & UX Features ─────────────────────────

  static String getChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  static Future<ChatModel> getOrCreateChat(String myUid, String otherUid) async {
    final chatId = getChatId(myUid, otherUid);
    final snap = await chatsRef.child(chatId).get();
    if (snap.exists) return ChatModel.fromMap(snap.value as Map);
    final chat = ChatModel(chatId: chatId, participants: [myUid, otherUid]);
    await chatsRef.child(chatId).set(chat.toMap());
    return chat;
  }

  static Stream<List<ChatModel>> observeUserChats(String uid) {
    return chatsRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final map = event.snapshot.value as Map;
      final list = map.values
          .map((v) => ChatModel.fromMap(v as Map))
          .where((c) => c.participants.contains(uid))
          .toList();
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }

  // ✅ تم تأمين الدالة ضد أخطاء تحويل الأنواع (Type Casting)
  static Future<void> togglePinChat(String chatId, String myUid) async {
    final chatRef = chatsRef.child(chatId);
    final snap = await chatRef.child('pinnedBy').get();
    
    List<String> pinnedBy = [];
    if (snap.exists && snap.value is List) {
      pinnedBy = List<String>.from((snap.value as List).map((e) => e.toString()));
    }

    if (pinnedBy.contains(myUid)) {
      pinnedBy.remove(myUid); // Unpin
    } else {
      pinnedBy.add(myUid);    // Pin
    }

    await chatRef.update({'pinnedBy': pinnedBy});
  }

  static Future<void> resetUnreadCount(String chatId, String myUid) async {
    await chatsRef.child(chatId).child('unreadCounts').child(myUid).set(0);
  }

  static Future<void> _incrementUnreadCountForOther(String chatId, String otherUid) async {
    final unreadRef = chatsRef.child(chatId).child('unreadCounts').child(otherUid);
    final snap = await unreadRef.get();
    
    int currentCount = 0;
    if (snap.exists) {
      currentCount = int.tryParse(snap.value.toString()) ?? 0;
    }
    
    await unreadRef.set(currentCount + 1);
  }

  // ───────────────────────── Messages ─────────────────────────

  static Future<void> sendMessage(String chatId, Message message) async {
    if (message.senderId == null || message.senderId!.isEmpty) {
      throw Exception('senderId is required');
    }
    
    final chatSnap = await chatsRef.child(chatId).get();
    if (!chatSnap.exists) throw Exception('Chat not found');
    final chatData = chatSnap.value as Map;
    final participants = List<String>.from(chatData['participants'] ?? []);
    if (!participants.contains(message.senderId)) {
      throw Exception('Unauthorized: sender not in this chat');
    }

    final otherUid = participants.firstWhere((id) => id != message.senderId, orElse: () => '');

    final msgRef = messagesRef.child(chatId).push();
    final data = message.toMap();
    data['messageId'] = msgRef.key ?? _uuid.v4();
    data['timestamp'] = ServerValue.timestamp;
    data['status'] = 'sent';
    await msgRef.set(data);

    String lastMessageText;
    switch (message.type) {
      case MessageType.image:
        lastMessageText = "📸 Photo";
        break;
      case MessageType.voice:
        lastMessageText = "🎤 Voice message";
        break;
      default:
        lastMessageText = message.text.length > 200
            ? message.text.substring(0, 200)
            : message.text;
    }

    await chatsRef.child(chatId).update({
      'lastMessage': lastMessageText,
      'lastMessageTime': ServerValue.timestamp,
      'lastMessageSenderId': message.senderId ?? '',
    });

    if (otherUid.isNotEmpty) {
      await _incrementUnreadCountForOther(chatId, otherUid);
    }
  }

  // 🚀 تحسين الأداء: تقليل تعقيد البحث والوصول المباشر للمفتاح
  static Future<void> deleteMessage(
    String chatId,
    String messageId,
    String myUid,
  ) async {
    if (messageId.trim().isEmpty || myUid.trim().isEmpty) return;

    final ref = messagesRef.child(chatId);
    final snap = await ref.orderByChild('messageId').equalTo(messageId).get();
    if (!snap.exists) return;

    final map = snap.value as Map;
    final msgKey = map.keys.first;
    final msgData = map[msgKey] as Map;

    if (msgData['senderId'] == myUid) {
      await ref.child(msgKey.toString()).remove();
    }
  }

  // 🚀 تحسين الأداء: التخلص من الـ loop لتقليل المعالجة
  static Future<void> updateMessage(
    String chatId,
    String messageId,
    String newText,
    String myUid,
  ) async {
    if (newText.trim().isEmpty) return;
    if (newText.length > 4000) throw Exception('Message too long');

    final ref = messagesRef.child(chatId);
    final snap = await ref.orderByChild('messageId').equalTo(messageId).get();
    if (!snap.exists) return;

    final map = snap.value as Map;
    final msgKey = map.keys.first;
    final msgData = map[msgKey] as Map;

    if (msgData['senderId'] == myUid) {
      await ref.child(msgKey.toString()).update({
        'text': newText.trim(),
        'isEdited': true,
        'editedAt': ServerValue.timestamp,
      });
    }
  }

  // ✅ حل مشكلة تعليق العداد: تصفير العداد قبل أي شرط عودة (return)
  static Future<void> markAsSeen(String chatId, String myUid) async {
    await resetUnreadCount(chatId, myUid);

    final ref = messagesRef.child(chatId);
    final snap = await ref
        .orderByChild('status')
        .equalTo('delivered')
        .get();

    if (!snap.exists) return;

    final map = snap.value as Map;
    final updates = <String, dynamic>{};
    for (var e in map.entries) {
      final msg = e.value as Map;
      if (msg['senderId'] != myUid) {
        updates['${e.key}/status'] = 'seen';
      }
    }

    if (updates.isNotEmpty) {
      await ref.update(updates);
    }
  }

  static Future<void> markAsDelivered(String chatId, String messageId) async {
    final ref = messagesRef.child(chatId);
    final snap = await ref.orderByChild('messageId').equalTo(messageId).get();
    if (!snap.exists) return;

    final map = snap.value as Map;
    final updates = <String, dynamic>{};
    for (var e in map.entries) {
      updates['${e.key}/status'] = 'delivered';
    }
    if (updates.isNotEmpty) {
      await ref.update(updates);
    }
  }

  static Stream<List<Message>> observeMessages(String chatId, String myUid) {
    return messagesRef.child(chatId).onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final map = event.snapshot.value as Map;

      // ✅ ترتيب تنازلي (الأحدث أولاً) من المصدر مباشرة — عشان index 0
      // يبقى دايمًا أحدث رسالة، وده اللي الـ ListView (reverse: true) في
      // chat_screen.dart مفترضه. كذلك بيشيل الحاجة لعكس الـ list تاني
      // في الـ cubit.
      return map.entries
          .map((e) => Message.fromMap(e.value as Map, myUid, id: e.key))
          .toList()
        ..sort((a, b) => b.time.compareTo(a.time));
    });
  }

  // ───────────────────────── Reactions ─────────────────────────

  // 🚀 تحسين الأداء: التخلص من البحث الزائد إذا لم يكن ضرورياً
  static Future<void> addReaction(
    String chatId,
    String messageId,
    String emoji,
    String uid,
  ) async {
    if (chatId.trim().isEmpty || messageId.trim().isEmpty) return;
    if (uid.trim().isEmpty || emoji.trim().isEmpty) return;

    final chatSnap = await chatsRef.child(chatId).get();
    if (!chatSnap.exists) throw Exception('Chat not found');
    final chatData = chatSnap.value as Map;
    final participants = List<String>.from(chatData['participants'] ?? []);
    if (!participants.contains(uid)) {
      throw Exception('Unauthorized: user not in this chat');
    }

    final ref = messagesRef.child(chatId);
    final snap = await ref.orderByChild('messageId').equalTo(messageId).get();
    if (!snap.exists) throw Exception('Message not found');

    final map = snap.value as Map;
    final msgKey = map.keys.first;

    await ref.child(msgKey.toString()).child('reactions').child(uid).set(emoji);
  }

  static Future<void> removeReaction(
    String chatId,
    String messageId,
    String uid,
  ) async {
    if (chatId.trim().isEmpty || messageId.trim().isEmpty || uid.trim().isEmpty) return;

    final ref = messagesRef.child(chatId);
    final snap = await ref.orderByChild('messageId').equalTo(messageId).get();
    if (!snap.exists) return;

    final map = snap.value as Map;
    final msgKey = map.keys.first;
    await ref.child(msgKey.toString()).child('reactions').child(uid).remove();
  }

  // ───────────────────────── Groups ─────────────────────────

  static Future<void> sendGroupMessage(
      String groupId, MessageModel message) async {
    if (message.senderId == null || message.senderId!.isEmpty) {
      throw Exception('senderId is required');
    }
    final groupSnap = await groupsRef.child(groupId).get();
    if (!groupSnap.exists) throw Exception('Group not found');
    final groupData = groupSnap.value as Map;
    final members = List<String>.from(groupData['members'] ?? []);
    if (!members.contains(message.senderId)) {
      throw Exception('Unauthorized: user not in this group');
    }

    final msgRef = groupMsgsRef.child(groupId).push();
    final msgWithId = MessageModel(
      messageId: msgRef.key ?? _uuid.v4(),
      senderId: message.senderId,
      senderName: message.senderName,
      text: message.text,
      timestamp: message.timestamp,
    );
    await msgRef.set(msgWithId.toMap());
    await groupsRef.child(groupId).update({
      'lastMessage': message.text.length > 200
          ? message.text.substring(0, 200)
          : message.text,
      'lastMessageTime': ServerValue.timestamp,
    });
  }

  static Stream<List<MessageModel>> observeGroupMessages(String groupId) {
    return groupMsgsRef.child(groupId).onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final map = event.snapshot.value as Map;
      return map.entries
          .map((e) => MessageModel.fromMap(e.key, e.value as Map))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  static Stream<List<GroupModel>> observeUserGroups(String uid) {
    return groupsRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final map = event.snapshot.value as Map;
      final list = map.values
          .map((v) => GroupModel.fromMap(v as Map))
          .where((g) => g.members.contains(uid))
          .toList();
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }

  static Future<GroupModel> createGroup(GroupModel group) async {
    final ref = groupsRef.push();
    final groupWithId = GroupModel(
      groupId: ref.key ?? _uuid.v4(),
      name: group.name,
      description: group.description,
      adminId: group.adminId,
      members: group.members,
    );
    await ref.set(groupWithId.toMap());
    return groupWithId;
  }

  // ───────────────────────── Channels ─────────────────────────

  static Future<void> sendChannelMessage(
    String channelId,
    MessageModel message,
    String adminId,
  ) async {
    final channel = await channelsRef.child(channelId).get();
    if (!channel.exists) return;
    final channelData = ChannelModel.fromMap(channel.value as Map);
    if (channelData.adminId != adminId) {
      throw Exception('Unauthorized: only admin can send channel messages');
    }

    final msgRef = channelMsgsRef.child(channelId).push();
    final msgWithId = MessageModel(
      messageId: msgRef.key ?? _uuid.v4(),
      senderId: message.senderId,
      senderName: message.senderName,
      text: message.text,
      timestamp: message.timestamp,
    );
    await msgRef.set(msgWithId.toMap());
    await channelsRef.child(channelId).update({
      'lastMessage': message.text.length > 200
          ? message.text.substring(0, 200)
          : message.text,
      'lastMessageTime': ServerValue.timestamp,
    });
  }

  static Stream<List<MessageModel>> observeChannelMessages(String channelId) {
    return channelMsgsRef.child(channelId).onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final map = event.snapshot.value as Map;
      return map.entries
          .map((e) => MessageModel.fromMap(e.key, e.value as Map))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  static Future<ChannelModel> createChannel(ChannelModel channel) async {
    final ref = channelsRef.push();
    final channelWithId = ChannelModel(
      channelId: ref.key ?? _uuid.v4(),
      name: channel.name,
      description: channel.description,
      adminId: channel.adminId,
      subscribers: channel.subscribers,
    );
    await ref.set(channelWithId.toMap());
    return channelWithId;
  }

  static Stream<List<ChannelModel>> observeUserChannels(String uid) {
    return channelsRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final map = event.snapshot.value as Map;
      final list = map.values
          .map((v) => ChannelModel.fromMap(v as Map))
          .where((c) => c.subscribers.contains(uid) || c.adminId == uid)
          .toList();
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }
}
