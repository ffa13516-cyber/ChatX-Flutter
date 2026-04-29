enum MessageType { text, image, voice, sticker } // 🆕 ضفنا sticker

enum MessageStatus { sent, delivered, seen }

class Message {
  final String text;
  final bool isMe;
  final MessageType type;
  final String? imageUrl;
  final DateTime time;
  final MessageStatus status;

  // 🆕 الجديد
  final Message? replyTo;

  // 🆕 NEW (اسم المرسل)
  final String? senderName;

  // 🆕 NEW (مهم للفirebase)
  final String? senderId;

  Message({
    required this.text,
    required this.isMe,
    this.type = MessageType.text,
    this.imageUrl,
    DateTime? time,
    this.status = MessageStatus.sent,
    this.replyTo,
    this.senderName,
    this.senderId, // 🆕
  }) : time = time ?? DateTime.now();

  // 🆕 تحويل لـ Map (للفirebase)
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.name,
      'imageUrl': imageUrl,
      'time': time.millisecondsSinceEpoch,
      'status': status.name,
      'replyTo': replyTo?.text, // مبدئيًا بنخزن النص بس
    };
  }

  // 🆕 من Map
  factory Message.fromMap(Map map, String myUid) {
    return Message(
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
    );
  }
}
