// ============================================================
// message_model.dart â€” ChatX Core Data Model
// âœ… Fully null-safe | âœ… copyWith | âœ… replyTo.senderId fixed
// âœ… Firebase-safe serialization | âœ… Deep equality
// ============================================================

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

  /// reactions: Map<uid, emoji> â€” ÙƒÙ„ ÙŠÙˆØ²Ø± Ù„Ù‡ reaction ÙˆØ§Ø­Ø¯Ø© Ø¨Ø³
  final Map<String, String>? reactions;

  const Message({
    this.id,
    required this.text,
    required this.isMe,
    this.type = MessageType.text,
    this.imageUrl,
    required this.time,
    this.status = MessageStatus.sent,
    this.replyTo,
    this.replyToId,
    this.senderName,
    this.senderId,
    this.voiceDuration,
    this.isEdited = false,
    this.reactions,
  });

  /// Factory Ù…Ø¹ Ù‚ÙŠÙ… Ø§ÙØªØ±Ø§Ø¶ÙŠØ© Ø°ÙƒÙŠØ© â€” Ù„ØªØ³Ù‡ÙŠÙ„ Ø§Ù„Ø¥Ù†Ø´Ø§Ø¡
  factory Message.create({
    String? id,
    required String text,
    required bool isMe,
    MessageType type = MessageType.text,
    String? imageUrl,
    DateTime? time,
    MessageStatus status = MessageStatus.sent,
    Message? replyTo,
    String? replyToId,
    String? senderName,
    String? senderId,
    int? voiceDuration,
    bool isEdited = false,
    Map<String, String>? reactions,
  }) {
    return Message(
      id: id,
      text: text,
      isMe: isMe,
      type: type,
      imageUrl: imageUrl,
      time: time ?? DateTime.now(),
      status: status,
      replyTo: replyTo,
      replyToId: replyToId,
      senderName: senderName,
      senderId: senderId,
      voiceDuration: voiceDuration,
      isEdited: isEdited,
      reactions: reactions,
    );
  }

  /// âœ… copyWith â€” Ù„Ù„ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø¬Ø²Ø¦ÙŠ Ø¨Ø¯ÙˆÙ† Ø¥Ù†Ø´Ø§Ø¡ object Ø¬Ø¯ÙŠØ¯ Ù…Ù† Ø§Ù„ØµÙØ±
  Message copyWith({
    String? id,
    String? text,
    bool? isMe,
    MessageType? type,
    String? imageUrl,
    DateTime? time,
    MessageStatus? status,
    Message? replyTo,
    String? replyToId,
    String? senderName,
    String? senderId,
    int? voiceDuration,
    bool? isEdited,
    Map<String, String>? reactions,
    bool clearReactions = false,
    bool clearReplyTo = false,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      time: time ?? this.time,
      status: status ?? this.status,
      replyTo: clearReplyTo ? null : (replyTo ?? this.replyTo),
      replyToId: clearReplyTo ? null : (replyToId ?? this.replyToId),
      senderName: senderName ?? this.senderName,
      senderId: senderId ?? this.senderId,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      isEdited: isEdited ?? this.isEdited,
      reactions: clearReactions ? null : (reactions ?? this.reactions),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // toMap â€” Firebase Serialization
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'type': type.name,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'time': time.millisecondsSinceEpoch,
      'status': status.name,
      if (replyToId != null) 'replyToId': replyToId,
      // âœ… FIX: Ø£Ø¶ÙÙ†Ø§ senderId Ø¬ÙˆØ§ replyTo Ø¹Ø´Ø§Ù† isMe ÙŠØªØ­Ø³Ø¨ ØµØ­ Ø¹Ù†Ø¯ Ø§Ù„Ù‚Ø±Ø§Ø¡Ø©
      if (replyTo != null)
        'replyTo': {
          'id': replyTo!.id,
          'text': replyTo!.text,
          'senderId': replyTo!.senderId, // â† ÙƒØ§Ù†Øª Ù†Ø§Ù‚ØµØ© ÙˆÙ‡ÙŠ Ø§Ù„Ù…Ø´ÙƒÙ„Ø© Ø§Ù„Ø£Ø³Ø§Ø³ÙŠØ©
          'senderName': replyTo!.senderName,
          'type': replyTo!.type.name,
          if (replyTo!.imageUrl != null) 'imageUrl': replyTo!.imageUrl,
        },
      if (voiceDuration != null) 'voiceDuration': voiceDuration,
      'isEdited': isEdited,
      if (reactions != null && reactions!.isNotEmpty) 'reactions': reactions,
    };
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // fromMap â€” Firebase Deserialization
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  factory Message.fromMap(Map<dynamic, dynamic> map, String myUid, {String? id}) {
    // â”€â”€ Parse Time â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    final DateTime parsedTime;
    final rawTime = map['time'];
    if (rawTime is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTime);
    } else {
      // Firebase ServerValue.TIMESTAMP Ù…Ù…ÙƒÙ† ÙŠÙƒÙˆÙ† Map Ù…Ø¤Ù‚ØªØ§Ù‹ØŒ Ù†Ø³ØªØ®Ø¯Ù… Ø§Ù„ÙˆÙ‚Øª Ø§Ù„Ø­Ø§Ù„ÙŠ
      parsedTime = DateTime.now();
    }

    // â”€â”€ Parse Reactions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    Map<String, String>? parsedReactions;
    final rawReactions = map['reactions'];
    if (rawReactions is Map && rawReactions.isNotEmpty) {
      try {
        parsedReactions = Map<String, String>.from(
          rawReactions.map((k, v) => MapEntry(k.toString(), v.toString())),
        );
      } catch (_) {
        parsedReactions = null;
      }
    }

    // â”€â”€ Parse MessageType â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    MessageType parseType(dynamic raw) => MessageType.values.firstWhere(
          (e) => e.name == raw,
          orElse: () => MessageType.text,
        );

    // â”€â”€ Parse MessageStatus â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    MessageStatus parseStatus(dynamic raw) => MessageStatus.values.firstWhere(
          (e) => e.name == raw,
          orElse: () => MessageStatus.sent,
        );

    // â”€â”€ Parse ReplyTo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    Message? parsedReplyTo;
    final rawReply = map['replyTo'];
    if (rawReply is Map) {
      try {
        parsedReplyTo = Message(
          id: rawReply['id']?.toString(),
          text: rawReply['text']?.toString() ?? '',
          // âœ… FIX: senderId Ù…ÙˆØ¬ÙˆØ¯ Ø¯Ù„ÙˆÙ‚ØªÙŠ ÙÙŠ Ø§Ù„Ù€ map ÙÙ€ isMe Ø¨ÙŠØªØ­Ø³Ø¨ ØµØ­
          isMe: rawReply['senderId']?.toString() == myUid,
          senderId: rawReply['senderId']?.toString(),
          senderName: rawReply['senderName']?.toString(),
          type: parseType(rawReply['type']),
          imageUrl: rawReply['imageUrl']?.toString(),
          time: DateTime.now(), // replyTo Ù…Ù„Ù‡Ø§Ø´ ÙˆÙ‚Øª Ù…Ø­ÙÙˆØ¸ØŒ Ø§ÙŠ Ù‚ÙŠÙ…Ø© ÙƒØ§ÙÙŠØ©
        );
      } catch (_) {
        parsedReplyTo = null;
      }
    }

    return Message(
      id: id,
      text: map['text']?.toString() ?? '',
      isMe: map['senderId']?.toString() == myUid,
      senderId: map['senderId']?.toString(),
      senderName: map['senderName']?.toString(),
      type: parseType(map['type']),
      imageUrl: map['imageUrl']?.toString(),
      time: parsedTime,
      status: parseStatus(map['status']),
      replyToId: map['replyToId']?.toString(),
      replyTo: parsedReplyTo,
      voiceDuration: map['voiceDuration'] is int ? map['voiceDuration'] as int : null,
      isEdited: map['isEdited'] == true,
      reactions: parsedReactions,
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Helpers
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Ù‡Ù„ Ù„Ù„Ø±Ø³Ø§Ù„Ø© Ø¯ÙŠ reactionsØŸ
  bool get hasReactions => reactions != null && reactions!.isNotEmpty;

  /// Ø¹Ø¯Ø¯ Ø§Ù„ØªÙØ§Ø¹Ù„Ø§Øª Ø§Ù„ÙƒÙ„ÙŠ
  int get reactionCount => reactions?.length ?? 0;

  /// ØªØ¬Ù…ÙŠØ¹ Ø§Ù„ØªÙØ§Ø¹Ù„Ø§Øª: Map<emoji, count>
  Map<String, int> get groupedReactions {
    final result = <String, int>{};
    reactions?.forEach((_, emoji) {
      result[emoji] = (result[emoji] ?? 0) + 1;
    });
    return result;
  }

  /// Ù‡Ù„ Ø§Ù„Ø±Ø³Ø§Ù„Ø© Ù‚Ø§Ø¨Ù„Ø© Ù„Ù„ØªØ¹Ø¯ÙŠÙ„ØŸ (text only)
  bool get isEditable => type == MessageType.text;

  /// Ù‡Ù„ Ø§Ù„Ø±Ø³Ø§Ù„Ø© ÙÙŠÙ‡Ø§ Ø±Ø¯ØŸ
  bool get hasReply => replyTo != null || replyToId != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          status == other.status &&
          isEdited == other.isEdited &&
          reactions == other.reactions;

  @override
  int get hashCode =>
      id.hashCode ^ text.hashCode ^ status.hashCode ^ isEdited.hashCode;

  @override
  String toString() =>
      'Message(id: $id, type: ${type.name}, status: ${status.name}, isMe: $isMe)';
}
