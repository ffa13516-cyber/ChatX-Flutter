// ============================================================
// chat_cubit.dart — ChatX Business Logic
// ✅ الإرسال مش بيضيع بصمت (sendMessage بترجع bool)
// ✅ الأخطاء بتعدّي على قناة منفصلة (errors) ومبتكتبش فوق حالة الـ fatal
// ✅ retry تلقائي بـ backoff + timeout للتحميل الأول
// ✅ طابور تفاعلات لكل رسالة + rollback مع إشعار
// ✅ مسودة لكل شات + إلغاء الرد لو الرسالة اتحذفت
// ============================================================

import 'dart:async';
import 'dart:math' as math;
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

/// بقت بتتبعت **بس** لما الـ stream نفسه يفشل (isFatal = true).
/// أخطاء العمليات (إرسال/حذف/تعديل/تفاعل) بتعدّي على [ChatCubit.errors].
class ChatError extends ChatState {
  final String errorMessage;

  /// آخر رسائل معروفة — عشان الشاشة تفضل تعرضها وقت الخطأ.
  final List<Message>? lastKnownMessages;

  /// true لما الـ stream نفسه يفشل.
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

  /// الرسالة اللي بيتم الرد عليها حالياً.
  Message? _replyingTo;

  /// IDs الرسائل اللي اتعملها mark كـ delivered عشان منعملهاش تاني.
  final Set<String> _deliveredIds = {};

  // ── Retry / timeout ───────────────────────────
  Timer? _retryTimer;
  Timer? _loadTimeout;
  int _retryCount = 0;

  // ── قناة أخطاء العمليات (للـ snackbar) ─────────
  final StreamController<String> _errorsController =
      StreamController<String>.broadcast();

  /// أخطاء العمليات (مش أخطاء الـ stream). الشاشة بتسمعها وتعرض snackbar.
  Stream<String> get errors => _errorsController.stream;

  // ── طابور التفاعلات لكل رسالة ──────────────────
  final Map<String, Future<void>> _reactionQueue = {};

  // ── المسودات (in-memory، بتعيش طول عمر التطبيق) ──
  static final Map<String, String> _drafts = {};

  /// المسودة المحفوظة للشات ده.
  String get draft => _drafts[chatId] ?? '';

  void saveDraft(String text) {
    if (text.trim().isEmpty) {
      _drafts.remove(chatId);
    } else {
      _drafts[chatId] = text;
    }
  }

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
    _retryTimer?.cancel();
    _loadTimeout?.cancel();

    if (!_hasData) {
      // أول تحميل بس: لو عندنا رسائل ماتمسحهاش بـ spinner.
      _safeEmit(const ChatLoading());
      _loadTimeout = Timer(const Duration(seconds: 15), () {
        if (!_hasData) {
          _safeEmit(const ChatError(
            'الاتصال بطيء أو مقطوع',
            lastKnownMessages: [],
            isFatal: true,
          ));
        }
      });
    }

    _fireAndForget(FirebaseRepo.markAsSeen(chatId, myUid), 'markAsSeen');

    _messagesSubscription?.cancel();
    _messagesSubscription = FirebaseRepo.observeMessages(chatId, myUid).listen(
      (messages) {
        // الرسائل جاية descending (الأحدث أولاً): index 0 = أحدث رسالة.
        _retryCount = 0;
        _loadTimeout?.cancel();
        _hasData = true;
        _lastKnownMessages = messages;

        // لو الرسالة اللي بتردّ عليها اتحذفت، الغي الرد.
        final reply = _replyingTo;
        if (reply != null &&
            reply.id != null &&
            !messages.any((m) => m.id == reply.id)) {
          _replyingTo = null;
        }

        _safeEmit(ChatLoaded(
          messages: messages,
          replyingTo: _replyingTo,
        ));

        _handleDelivery(messages);
      },
      onError: (Object error) {
        debugPrint('observeMessages error: $error');
        _loadTimeout?.cancel();
        _safeEmit(ChatError(
          'حدث خطأ أثناء جلب الرسائل',
          lastKnownMessages: _lastKnownMessages,
          isFatal: true,
        ));
        _scheduleRetry();
      },
    );
  }

  /// إعادة محاولة تلقائية بـ backoff: 2، 4، 8، 16، 30 ثانية.
  void _scheduleRetry() {
    _retryTimer?.cancel();
    final seconds = math.min(30, 2 << _retryCount++);
    _retryTimer = Timer(Duration(seconds: seconds), retry);
  }

  /// بيعيد الاشتراك في الـ stream (زرار/Banner "إعادة المحاولة" + التلقائي).
  void retry() {
    if (isClosed) return;
    _retryTimer?.cancel();
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
      if (id == null || _deliveredIds.contains(id)) continue;
      if (!msg.isMe && msg.status == MessageStatus.sent) {
        _deliveredIds.add(id);
        unawaited(
          FirebaseRepo.markAsDelivered(chatId, id).catchError((Object e) {
            debugPrint('markAsDelivered error: $e');
            // اشيله من الـ set عشان يتعاد مع أول emit جاي.
            _deliveredIds.remove(id);
          }),
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

  /// بترجع true لو الإرسال نجح، false لو فشل (الـ ChatInput بيرجّع النص).
  Future<bool> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    // ملحوظة: شيلنا شرط (state is ChatLoaded) — الإرسال مش معتمد على القايمة،
    // وكان بيضيّع الرسالة بصمت وقت التحميل الأول أو بعد خطأ الـ stream.

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
      // الـ stream هيجيب الرسالة الجديدة تلقائياً.
      return true;
    } catch (e) {
      debugPrint('sendMessage error: $e');
      setReply(replyMsg); // رجّع الـ reply في الـ state كمان
      _emitActionError('فشل إرسال الرسالة، حاول مرة أخرى.');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Delete Message
  // ─────────────────────────────────────────────

  Future<void> deleteMessage(String? messageId) async {
    if (messageId == null || messageId.isEmpty) {
      _emitActionError('الرسالة لسه بتتبعت، حاول بعد لحظة.');
      return;
    }

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
    if (trimmed.isEmpty) return;
    if (messageId == null || messageId.isEmpty) {
      _emitActionError('الرسالة لسه بتتبعت، حاول بعد لحظة.');
      return;
    }

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
    if (emoji.isEmpty) return;
    if (messageId == null || messageId.isEmpty) {
      _emitActionError('الرسالة لسه بتتبعت، حاول بعد لحظة.');
      return;
    }

    final current = state;
    if (current is! ChatLoaded) {
      _emitActionError('مش ممكن تتفاعل دلوقتي، الاتصال مقطوع.');
      return;
    }

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

    // طابور لكل رسالة: العمليات بتتنفذ بنفس ترتيب الضغطات،
    // فمفيش add/remove بيتسابقوا على السيرفر.
    final previous = _reactionQueue[messageId] ?? Future<void>.value();
    final op = previous.then((_) async {
      try {
        if (removing) {
          await FirebaseRepo.removeReaction(chatId, messageId, myUid);
        } else {
          await FirebaseRepo.addReaction(chatId, messageId, emoji, myUid);
        }
      } catch (e) {
        debugPrint('addReaction error: $e');
        _rollbackReactions(messageId, originalReactions);
        _emitActionError('تعذّر تحديث التفاعل.');
      }
    });
    _reactionQueue[messageId] = op;
    await op;
    if (identical(_reactionQueue[messageId], op)) {
      _reactionQueue.remove(messageId);
    }
  }

  /// بيرجّع الـ reactions بتاعة رسالة واحدة على آخر state (مش state قديم).
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

  /// أخطاء العمليات بتعدّي على قناة منفصلة — مبتغيّرش الـ state خالص،
  /// فمبتكتبش فوق ChatError(isFatal) ومفيش flicker.
  void _emitActionError(String message) {
    if (!_errorsController.isClosed) _errorsController.add(message);
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
    _retryTimer?.cancel();
    _loadTimeout?.cancel();
    _errorsController.close();
    return super.close();
  }
}
