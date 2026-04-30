enum MessageType { text, image, voice, sticker }

enum MessageStatus { sent, delivered, seen }

class Message {
  final String? id;

  final String text;
  final bool isMe;

  final MessageType type;
  final String? imageUrl;

  final DateTime time;
  final MessageStatus status;

  final Message? replyTo;
  final String? replyToId;

  final String? senderName;
  final String? senderId;

  final String? stickerPath;
  final String? rawText;

  Message({
    this.id,
    required this.text,
    required this.isMe,
    MessageType? type,
    this.imageUrl,
    DateTime? time,
    this.status = MessageStatus.sent,
    this.replyTo,
    this.replyToId,
    this.senderName,
    this.senderId,
    this.stickerPath,
    this.rawText,
  })  : type = stickerPath != null
            ? MessageType.sticker
            : (type ?? MessageType.text),
        time = time ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.name,
      'imageUrl': imageUrl,
      'time': time.millisecondsSinceEpoch,
      'status': status.name,

      'replyToId': replyToId,

      'replyTo': replyTo == null
          ? null
          : {
              'id': replyTo!.id,
              'text': replyTo!.text,
              'senderName': replyTo!.senderName,
            },

      'stickerPath': stickerPath,
      'rawText': rawText,
    };
  }

  factory Message.fromMap(Map map, String myUid, {String? id}) {
    final stickerPath = map['stickerPath'];

    return Message(
      id: id,

      text: map['text'] ?? '',
      isMe: map['senderId'] == myUid,

      senderId: map['senderId'],
      senderName: map['senderName'],

      // 🔥 أهم تعديل هنا
      type: stickerPath != null
          ? MessageType.sticker
          : MessageType.values.firstWhere(
              (e) => e.name == map['type'],
              orElse: () => MessageType.text,
            ),

      imageUrl: map['imageUrl'],

      time: DateTime.fromMillisecondsSinceEpoch(map['time'] ?? 0),

      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),

      replyToId: map['replyToId'],

      replyTo: map['replyTo'] == null
          ? null
          : Message(
              id: map['replyTo']['id'],
              text: map['replyTo']['text'] ?? '',
              isMe: false,
              senderName: map['replyTo']['senderName'],
              senderId: null,
            ),

      stickerPath: stickerPath,
      rawText: map['rawText'],
    );
  }
}
