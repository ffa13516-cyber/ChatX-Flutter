enum MessageType { text, image, voice }

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
  final int? voiceDuration;
  final bool isEdited;

  // âœ… reactions: Map<uid, emoji> â€” ÙƒÙ„ ÙŠÙˆØ²Ø± Ù„Ù‡ reaction ÙˆØ§Ø­Ø¯Ø© Ø¨Ø³
  final Map<String, String>? reactions;

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
    this.voiceDuration,
    this.isEdited = false,
    this.reactions,
  })  : type = type ?? MessageType.text,
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
              'type': replyTo!.type.name,
            },
      if (voiceDuration != null) 'voiceDuration': voiceDuration,
      'isEdited': isEdited,
      // âœ… reactions: Ø¨Ù†Ø­Ø·Ù‡Ø§ Ù„Ùˆ Ù…ÙˆØ¬ÙˆØ¯Ø© Ø¨Ø³
      if (reactions != null && reactions!.isNotEmpty) 'reactions': reactions,
    };
  }

  factory Message.fromMap(Map map, String myUid, {String? id}) {
    DateTime parsedTime;
    final rawTime = map['time'];
    if (rawTime is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTime);
    } else if (rawTime is Map) {
      parsedTime = DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    // âœ… Ù‚Ø±Ø§Ø¡Ø© Ø§Ù„Ù€ reactions Ù…Ù† Firebase Ø¨Ø£Ù…Ø§Ù†
    Map<String, String>? parsedReactions;
    final rawReactions = map['reactions'];
    if (rawReactions is Map) {
      try {
        parsedReactions = Map<String, String>.from(
          rawReactions.map((k, v) => MapEntry(k.toString(), v.toString())),
        );
      } catch (_) {
        parsedReactions = null;
      }
    }

    return Message(
      id: id,
      text: map['text'] ?? '',
      isMe: map['senderId'] == myUid,
      senderId: map['senderId'],
      senderName: map['senderName'],
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      imageUrl: map['imageUrl'],
      time: parsedTime,
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
              isMe: map['replyTo']['senderId'] == myUid,
              senderName: map['replyTo']['senderName'],
              type: MessageType.values.firstWhere(
                (e) => e.name == map['replyTo']['type'],
                orElse: () => MessageType.text,
              ),
            ),
      voiceDuration: map['voiceDuration'] as int?,
      isEdited: map['isEdited'] == true,
      reactions: parsedReactions,
    );
  }
}
