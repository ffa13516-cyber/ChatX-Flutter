import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class FirebaseRepo {
  static final _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'PUT_YOUR_DATABASE_URL_HERE',
  );

  static const _uuid = Uuid();

  // References
  static DatabaseReference get usersRef => _db.ref('users');
  static DatabaseReference get chatsRef => _db.ref('chats');
  static DatabaseReference get messagesRef => _db.ref('messages');
  static DatabaseReference get groupsRef => _db.ref('groups');
  static DatabaseReference get groupMsgsRef => _db.ref('groupMessages');
  static DatabaseReference get channelsRef => _db.ref('channels');
  static DatabaseReference get channelMsgsRef => _db.ref('channelMessages');

  // ==================== USERS ====================
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

  static Future<List<UserModel>> getAllUsers() async {
    final snap = await usersRef.get();
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

  // ==================== CHATS ====================
  static String getChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  static Future<ChatModel> getOrCreateChat(String myUid, String otherUid) async {
    final chatId = getChatId(myUid, otherUid);
    final snap = await chatsRef.child(chatId).get();
    if (snap.exists) {
      return ChatModel.fromMap(snap.value as Map);
    }
    final chat = ChatModel(
      chatId: chatId,
      participants: [myUid, otherUid],
    );
    await chatsRef.child(chatId).set(chat.toMap());
    return chat;
  }

  static Future<void> sendMessage(String chatId, MessageModel message) async {
    final msgRef = messagesRef.child(chatId).push();
    final msgWithId = MessageModel(
      messageId: msgRef.key ?? _uuid.v4(),
      senderId: message.senderId,
      senderName: message.senderName,
      text: message.text,
      timestamp: message.timestamp,
    );
    await msgRef.set(msgWithId.toMap());
    await chatsRef.child(chatId).update({
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp,
      'lastMessageSenderId': message.senderId,
    });
  }

  static Stream<List<MessageModel>> observeMessages(String chatId) {
    return messagesRef.child(chatId).onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final map = event.snapshot.value as Map;
      return map.entries
          .map((e) => MessageModel.fromMap(e.key, e.value as Map))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  static Stream<List<ChatModel>> observeUserChats(String uid) {
    return chatsRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final map = event.snapshot.value as Map;
      return map.values
          .map((v) => ChatModel.fromMap(v as Map))
          .where((c) => c.participants.contains(uid))
          .toList()
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    });
  }

  // ==================== GROUPS ====================
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

  static Future<void> sendGroupMessage(String groupId, MessageModel message) async {
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
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp,
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
      return map.values
          .map((v) => GroupModel.fromMap(v as Map))
          .where((g) => g.members.contains(uid))
          .toList()
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    });
  }

  // ==================== CHANNELS ====================
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

  static Future<void> sendChannelMessage(String channelId, MessageModel message, String adminId) async {
    final channel = await channelsRef.child(channelId).get();
    if (!channel.exists) return;
    final channelData = ChannelModel.fromMap(channel.value as Map);
    if (channelData.adminId != adminId) return;

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
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp,
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

  static Stream<List<ChannelModel>> observeUserChannels(String uid) {
    return channelsRef.onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final map = event.snapshot.value as Map;
      return map.values
          .map((v) => ChannelModel.fromMap(v as Map))
          .where((c) => c.subscribers.contains(uid) || c.adminId == uid)
          .toList()
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    });
  }
}
