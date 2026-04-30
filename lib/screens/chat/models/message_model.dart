enum MessageType { text, image, voice, sticker }

enum MessageStatus { sent, delivered, seen }

class Message {
  final String? id; // 🔥 مهم للـ scroll

  final String text;
  final bool isMe;

  final MessageType type;
  final String? imageUrl;

  final DateTime time;
  final MessageStatus status;

  /// 🔥 Preview فقط
  final Message? replyTo;

  /// 🔥 الأساس
  final String? replyToId;

  final String? senderName;
  final String? senderId;

  Message({
    this.id,
    required this.text,
    required this.isMe,
    this.type = MessageType.text,
    this.imageUrl,
    DateTime? time,
    this.status = MessageStatus.sent,
    this.replyTo,
    this.replyToId,
    this.senderName,
    this.senderId,
  }) : time = time ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.name,
      'imageUrl': imageUrl,
      'time': time.millisecondsSinceEpoch,
      'status': status.name,

      // 🔥 المهم
      'replyToId': replyToId,

      // 🔥 preview خفيف
      'replyTo': replyTo == null
          ? null
          : {
              'id': replyTo!.id,
              'text': replyTo!.text,
              'senderName': replyTo!.senderName,
            },
    };
  }

  factory Message.fromMap(Map map, String myUid, {String? id}) {
    return Message(
      id: id, // 🔥 مهم جدًا

      text: map['text'] ?? '',
      isMe: map['senderId'] == myUid,

      senderId: map['senderId'],
      senderName: map['senderName'],

      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),

      imageUrl: map['imageUrl'],

      time: DateTime.fromMillisecondsSinceEpoch(map['time'] ?? 0),

      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),

      /// 🔥 الأساس
      replyToId: map['replyToId'],

      /// 🔥 preview
      replyTo: map['replyTo'] == null
          ? null
          : Message(
              id: map['replyTo']['id'],
              text: map['replyTo']['text'] ?? '',
              isMe: false,
              senderName: map['replyTo']['senderName'],
              senderId: null,
            ),
    );
  }
}
