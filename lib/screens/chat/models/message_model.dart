enum MessageType { text, image, voice }

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

  Message({
    required this.text,
    required this.isMe,
    this.type = MessageType.text,
    this.imageUrl,
    DateTime? time,
    this.status = MessageStatus.sent,

    // 🆕 الجديد
    this.replyTo,
  }) : time = time ?? DateTime.now();
}
