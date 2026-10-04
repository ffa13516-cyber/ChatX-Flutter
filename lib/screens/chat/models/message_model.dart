// ============================================================
// message_model.dart — ChatX Core Data Model
// ✅ Fully null-safe | ✅ copyWith | ✅ replyTo.senderId
// ✅ Firebase-safe serialization | ✅ وقت السيرفر (timestamp) أولاً
// ✅ مقارنة reactions بالقيمة (mapEquals)
// ============================================================

import 'package:flutter/foundation.dart' show mapEquals;

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

  /// reactions: Map<uid, emoji> — كل يوزر له reaction واحدة بس
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

  /// Factory مع قيم افتراضية ذكية — لتسهيل الإنشاء
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

  /// copyWith — للتعديل الجزئي بدون إنشاء object جديد من الصفر
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

  // ─────────────────────────────────────────────
  // toMap — Firebase Serialization
  // ─────────────────────────────────────────────
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
      // senderId جوه replyTo عشان isMe يتحسب صح عند القراءة
      if (replyTo != null)
        'replyTo': {
          'id': replyTo!.id,
          'text': replyTo!.text,
          'senderId': replyTo!.senderId,
          'senderName': replyTo!.senderName,
          'type': replyTo!.type.name,
          if (replyTo!.imageUrl != null) 'imageUrl': replyTo!.imageUrl,
        },
      if (voiceDuration != null) 'voiceDuration': voiceDuration,
      'isEdited': isEdited,
      if (reactions != null && reactions!.isNotEmpty) 'reactions': reactions,
    };
  }

  // ─────────────────────────────────────────────
  // fromMap — Firebase Deserialization
  // ─────────────────────────────────────────────
  factory Message.fromMap(Map<dynamic, dynamic> map, String myUid, {String? id}) {
    // ── Parse Time ──────────────────────────────
    // الأولوية لـ `timestamp` (وقت السيرفر اللي الـ repo بيكتبه) عشان الترتيب
    // يبقى ثابت على كل الأجهزة، وبعدها `time` (ساعة الموبايل) للرسايل القديمة.
    // لو القيمة لسه placeholder (Map) بنكمل للتالي، وآخر حاجة الوقت الحالي.
    DateTime? readMillis(dynamic raw) =>
        raw is num ? DateTime.fromMillisecondsSinceEpoch(raw.toInt()) : null;

    final DateTime parsedTime =
        readMillis(map['timestamp']) ?? readMillis(map['time']) ?? DateTime.now();

    // ── Parse Reactions ─────────────────────────
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

    // ── Parse MessageType ───────────────────────
    MessageType parseType(dynamic raw) => MessageType.values.firstWhere(
          (e) => e.name == raw,
          orElse: () => MessageType.text,
        );

    // ── Parse MessageStatus ─────────────────────
    MessageStatus parseStatus(dynamic raw) => MessageStatus.values.firstWhere(
          (e) => e.name == raw,
          orElse: () => MessageStatus.sent,
        );

    // ── Parse ReplyTo ───────────────────────────
    Message? parsedReplyTo;
    final rawReply = map['replyTo'];
    if (rawReply is Map) {
      try {
        parsedReplyTo = Message(
          id: rawReply['id']?.toString(),
          text: rawReply['text']?.toString() ?? '',
          // senderId موجود في الـ map فـ isMe بيتحسب صح
          isMe: rawReply['senderId']?.toString() == myUid,
          senderId: rawReply['senderId']?.toString(),
          senderName: rawReply['senderName']?.toString(),
          type: parseType(rawReply['type']),
          imageUrl: rawReply['imageUrl']?.toString(),
          time: DateTime.now(), // replyTo ملهاش وقت محفوظ، أي قيمة كافية
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

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  /// هل للرسالة دي reactions؟
  bool get hasReactions => reactions != null && reactions!.isNotEmpty;

  /// عدد التفاعلات الكلي
  int get reactionCount => reactions?.length ?? 0;

  /// تجميع التفاعلات: Map<emoji, count>
  Map<String, int> get groupedReactions {
    final result = <String, int>{};
    reactions?.forEach((_, emoji) {
      result[emoji] = (result[emoji] ?? 0) + 1;
    });
    return result;
  }

  /// هل الرسالة قابلة للتعديل؟ (text only)
  bool get isEditable => type == MessageType.text;

  /// هل الرسالة فيها رد؟
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
          mapEquals(reactions, other.reactions);

  @override
  int get hashCode =>
      id.hashCode ^ text.hashCode ^ status.hashCode ^ isEdited.hashCode;

  @override
  String toString() =>
      'Message(id: $id, type: ${type.name}, status: ${status.name}, isMe: $isMe)';
}
