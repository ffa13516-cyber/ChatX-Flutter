enum MessageType { text, image, voice }

class Message {
  final String text;
  final bool isMe;
  final MessageType type;
  final String? imageUrl;

  Message({
    required this.text,
    required this.isMe,
    this.type = MessageType.text,
    this.imageUrl,
  });
}
