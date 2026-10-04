// ============================================================
// chat_cubit.dart — ChatX Business Logic
// ✅ Reaction toggle-off بيتحفظ فعلاً | ✅ Rollback على آخر state
// ✅ retry() لما الـ stream يفشل    | ✅ No unhandled async errors
// ============================================================

import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatx/screens/chat/models/message_model.dart';
import '../../../repositories/firebase_repo.dart';

// ─────────────────────────────────────────────
// States
// ─────────────────────────────────────────────

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final Message? replyingTo;

  const ChatLoaded({
    required this.messages,
    this.replyingTo,
  });

  ChatLoaded copyWith({
    List<Message>? messages,
    Message? replyingTo,
    bool clearReply = false,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      replyingTo: clearReply ? null : (replyingTo ?? this.replyingTo),
    );
  }
}

class ChatError extends ChatState {
  final String errorMessage;

  /// آخر رسائل معروفة — عشان الشاشة تفضل تعرضها وقت الخطأ.
  final List<Message>? lastKnownMessages;

  /// true لما الـ stream نفسه يفشل (مش مجرد عملية واحدة زي إرسال/حذف).
  /// الشاشة بتعرض زرار "إعادة المحاولة" في الحالة دي.
  final bool isFatal;

  const ChatError(
    this.errorMessage, {
    this.lastKnownMessages,
    this.isFatal = false,
  });
}

// ─────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────

class ChatCubit extends Cubit<ChatState> {
  final String chatId;
  final String myUid;
  final String myName;

  StreamSubscription<List<Message>>? _messagesSubscription;

  /// آخر قايمة رسائل وصلت من الـ stream — للـ recovery.
  List<Message> _lastKnownMessages = [];

  /// وصلتنا بيانات من الـ stream ولا لسه؟
  bool _hasData = false;

  /// الرسالة اللي بيتم الرد عليها حالياً (محفوظة هنا عشان تفضل مع أي emit).
  Message? _replyingTo;

  /// IDs الرسائل اللي اتعملها mark كـ delivered عشان منعملهاش تاني.
  final Set<String> _deliveredIds = {};

  ChatCubit({
    required this.chatId,
    required this.myUid,
    required this.myName,
  }) : super(const ChatInitial()) {
    _initChat();
  }

  // ─────────────────────────────────────────────
  // Init / Retry
  // ─────────────────────────────────────────────

  void _initChat() {
    _safeEmit(const ChatLoading());

    _fireAndForget(FirebaseRepo.markAsSeen(chatId, myUid), 'markAsSeen');

    _messagesSubscription = FirebaseRepo.observeMessages(chatId, myUid).listen(
      (messages) {
        // الرسائل جاية descending من FirebaseRepo (الأحدث أولاً):
        // index 0 = أحدث رسالة، ومطابق للـ ListView (reverse: true).
        _hasData = true;
        _lastKnownMessages = messages;

        _safeEmit(ChatLoaded(
          messages: messages,
          replyingTo: _replyingTo,
        ));

        _handleDelivery(messages);
      },
      onError: (Object error) {
        debugPrint('observeMessages error: $error');
        _safeEmit(ChatError(
          'حدث خطأ أثناء جلب الرسائل',
          lastKnownMessages: _lastKnownMessages,
          isFatal: true,
        ));
      },
    );
  }

  /// بيعيد الاشتراك في الـ stream (بيتنادى من زرار "إعادة المحاولة").
  void retry() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _initChat();
  }

  // ─────────────────────────────────────────────
  // Delivery Marking
  // ─────────────────────────────────────────────

  void _handleDelivery(List<Message> messages) {
    for (final msg in messages) {
      final id = msg.id;
      if (id == null || _deliveredIds.contains(id)) continue; // skip بسرعة
      if (!msg.isMe && msg.status == MessageStatus.sent) {
        _deliveredIds.add(id);
        _fireAndForget(
          FirebaseRepo.markAsDelivered(chatId, id),
          'markAsDelivered',
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // Reply Management
  // ─────────────────────────────────────────────

  void setReply(Message? message) {
    _replyingTo = message;
    final current = state;
    if (current is ChatLoaded) {
      _safeEmit(current.copyWith(
        replyingTo: message,
        clearReply: message == null,
      ));
    }
  }

  // ─────────────────────────────────────────────
  // Send Message
  // ─────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (state is! ChatLoaded) return;

    final replyMsg = _replyingTo;

    // امسح الـ reply فوراً من الـ UI قبل ما نبعت.
    setReply(null);

    final newMessage = Message.create(
      text: trimmed,
      isMe: true,
      senderId: myUid,
      senderName: myName,
      replyToId: replyMsg?.id,
      replyTo: replyMsg,
      status: MessageStatus.sent,
    );

    try {
      await FirebaseRepo.sendMessage(chatId, newMessage);
      // الـ stream هيجيب الرسالة الجديدة تلقائياً — مفيش حاجة تانية.
    } catch (e) {
      debugPrint('sendMessage error: $e');
      // رجّع الـ reply عشان ميتفقدش لو الإرسال فشل.
      _replyingTo = replyMsg;
      _emitActionError('فشل إرسال الرسالة، حاول مرة أخرى.');
    }
  }

  // ─────────────────────────────────────────────
  // Delete Message
  // ─────────────────────────────────────────────

  Future<void> deleteMessage(String? messageId) async {
    if (messageId == null || messageId.isEmpty) return;

    try {
      await FirebaseRepo.deleteMessage(chatId, messageId, myUid);
    } catch (e) {
      debugPrint('deleteMessage error: $e');
      _emitActionError('فشل حذف الرسالة.');
    }
  }

  // ─────────────────────────────────────────────
  // Edit Message
  // ─────────────────────────────────────────────

  Future<void> editMessage(String? messageId, String newText) async {
    final trimmed = newText.trim();
    if (messageId == null || messageId.isEmpty || trimmed.isEmpty) return;

    try {
      await FirebaseRepo.updateMessage(chatId, messageId, trimmed, myUid);
    } catch (e) {
      debugPrint('editMessage error: $e');
      _emitActionError('فشل تعديل الرسالة.');
    }
  }

  // ─────────────────────────────────────────────
  // Reaction (add / change / toggle-off)
  // ─────────────────────────────────────────────

  Future<void> addReaction(String? messageId, String emoji) async {
    if (messageId == null || messageId.isEmpty || emoji.isEmpty) return;

    final current = state;
    if (current is! ChatLoaded) return;

    final targetIndex = current.messages.indexWhere((m) => m.id == messageId);
    if (targetIndex == -1) return; // الرسالة مش موجودة

    final originalMsg = current.messages[targetIndex];
    final originalReactions = originalMsg.reactions;

    final newReactions =
        Map<String, String>.from(originalReactions ?? const <String, String>{});

    // نفس الإيموجي تاني = شيل الـ reaction، غير كده ضيف/غيّر.
    final bool removing = newReactions[myUid] == emoji;
    if (removing) {
      newReactions.remove(myUid);
    } else {
      newReactions[myUid] = emoji;
    }

    final updatedMsg = originalMsg.copyWith(
      reactions: newReactions.isEmpty ? null : newReactions,
      clearReactions: newReactions.isEmpty,
    );

    final updatedMessages = List<Message>.of(current.messages);
    updatedMessages[targetIndex] = updatedMsg;
    _safeEmit(current.copyWith(messages: updatedMessages));

    try {
      if (removing) {
        await FirebaseRepo.removeReaction(chatId, messageId, myUid);
      } else {
        await FirebaseRepo.addReaction(chatId, messageId, emoji, myUid);
      }
    } catch (e) {
      debugPrint('addReaction error: $e');
      _rollbackReactions(messageId, originalReactions);
    }
  }

  /// بيرجّع الـ reactions بتاعة رسالة واحدة على آخر state (مش state قديم)،
  /// فمفيش رسايل جديدة بتختفي لو الـ reaction فشل.
  void _rollbackReactions(
    String messageId,
    Map<String, String>? originalReactions,
  ) {
    final current = state;
    if (current is! ChatLoaded) return;

    final index = current.messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final bool clear = originalReactions == null || originalReactions.isEmpty;
    final list = List<Message>.of(current.messages);
    list[index] = list[index].copyWith(
      reactions: clear ? null : originalReactions,
      clearReactions: clear,
    );
    _safeEmit(current.copyWith(messages: list));
  }

  // ─────────────────────────────────────────────
  // Error handling helpers
  // ─────────────────────────────────────────────

  /// بيبعت ChatError (للـ snackbar) وبعدها يرجّع الحالة الطبيعية فوراً.
  void _emitActionError(String message) {
    _safeEmit(ChatError(message, lastKnownMessages: _lastKnownMessages));
    _restoreLoadedState();
  }

  void _restoreLoadedState() {
    if (isClosed) return;
    final current = state;
    // الـ fatal error بيفضل لحد ما المستخدم يعمل retry().
    if (current is! ChatError || current.isFatal) return;

    if (_hasData) {
      _safeEmit(ChatLoaded(
        messages: _lastKnownMessages,
        replyingTo: _replyingTo,
      ));
    } else {
      // لسه البيانات الأولى ما وصلتش — الـ subscription شغال وهيكمل لوحده.
      _safeEmit(const ChatLoading());
    }
  }

  /// بينفذ عملية async من غير await، من غير ما أي exception يطلع unhandled.
  void _fireAndForget(Future<void> future, String label) {
    unawaited(future.catchError((Object e) {
      debugPrint('$label error: $e');
    }));
  }

  // ─────────────────────────────────────────────
  // Safe Emit — منع crash بعد close()
  // ─────────────────────────────────────────────

  void _safeEmit(ChatState newState) {
    if (!isClosed) emit(newState);
  }

  // ─────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
