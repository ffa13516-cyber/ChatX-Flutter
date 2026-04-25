class Message {
  final String text;
  final bool isMe;
  final String? avatar;

  Message({
    required this.text,
    required this.isMe,
    this.avatar,
  });
}
