// models/user_model.dart
class UserModel {
  final String uid;
  final String phoneNumber;
  final String displayName;
  final String username;
  final String avatarUrl;
  final bool isOnline;
  final int lastSeen;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.displayName,
    this.username = '',
    this.avatarUrl = '',
    this.isOnline = false,
    required this.lastSeen,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      displayName: map['displayName'] ?? '',
      username: map['username'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'phoneNumber': phoneNumber,
    'displayName': displayName,
    'username': username,
    'avatarUrl': avatarUrl,
    'isOnline': isOnline,
    'lastSeen': lastSeen,
  };

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}

// models/message_model.dart
class MessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String text;
  final int timestamp;
  final bool isRead;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MessageModel(
      messageId: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'messageId': messageId,
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'timestamp': timestamp,
    'isRead': isRead,
  };
}

// models/chat_model.dart
class ChatModel {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final int lastMessageTime;
  final String lastMessageSenderId;

  ChatModel({
    required this.chatId,
    required this.participants,
    this.lastMessage = '',
    this.lastMessageTime = 0,
    this.lastMessageSenderId = '',
  });

  factory ChatModel.fromMap(Map<dynamic, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? 0,
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'chatId': chatId,
    'participants': participants,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime,
    'lastMessageSenderId': lastMessageSenderId,
  };
}

// models/group_model.dart
class GroupModel {
  final String groupId;
  final String name;
  final String description;
  final String adminId;
  final List<String> members;
  final String lastMessage;
  final int lastMessageTime;

  GroupModel({
    required this.groupId,
    required this.name,
    this.description = '',
    required this.adminId,
    required this.members,
    this.lastMessage = '',
    this.lastMessageTime = 0,
  });

  factory GroupModel.fromMap(Map<dynamic, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      adminId: map['adminId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'groupId': groupId,
    'name': name,
    'description': description,
    'adminId': adminId,
    'members': members,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime,
  };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'G';
  }
}

// models/channel_model.dart
class ChannelModel {
  final String channelId;
  final String name;
  final String description;
  final String adminId;
  final List<String> subscribers;
  final String lastMessage;
  final int lastMessageTime;

  ChannelModel({
    required this.channelId,
    required this.name,
    this.description = '',
    required this.adminId,
    required this.subscribers,
    this.lastMessage = '',
    this.lastMessageTime = 0,
  });

  factory ChannelModel.fromMap(Map<dynamic, dynamic> map) {
    return ChannelModel(
      channelId: map['channelId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      adminId: map['adminId'] ?? '',
      subscribers: List<String>.from(map['subscribers'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'channelId': channelId,
    'name': name,
    'description': description,
    'adminId': adminId,
    'subscribers': subscribers,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime,
  };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'C';
  }
}
