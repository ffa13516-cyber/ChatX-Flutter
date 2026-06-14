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

  // ✅ FIX #9: مدة رسالة الصوت بالثواني
  final int? voiceDuration;

  // ✅ FIX: علامة إن الرسالة اتعدلت
  final bool isEdited;

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
  })  : type = type ?? MessageType.text,
        // ✅ FIX #8: لو مفيش time بنستخدم DateTime.now() كـ fallback بس
        // الـ server timestamp هو المصدر الحقيقي عند القراءة من Firebase
        time = time ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.name,
      'imageUrl': imageUrl,
      // ✅ FIX #8: الـ time بيتبعت كـ milliseconds لكن Firebase بيـ override بـ ServerValue.timestamp
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
    };
  }

  factory Message.fromMap(Map map, String myUid, {String? id}) {
    // ✅ FIX #8: بنقرا الـ timestamp من Firebase كـ int أو String
    // لأن ServerValue.timestamp ممكن يرجع int أو Map
    DateTime parsedTime;
    final rawTime = map['time'];
    if (rawTime is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTime);
    } else if (rawTime is Map) {
      // ServerValue.timestamp رجع Map<'.sv', 'timestamp'> — fallback
      parsedTime = DateTime.now();
    } else {
      parsedTime = DateTime.now();
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
    );
  }
}
