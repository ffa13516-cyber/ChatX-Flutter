// ============================================================
// chat_cubit.dart — ChatX Business Logic
// ============================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
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
  final List<Message>? lastKnownMessages;
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

class ChatCubit extends Cubit<ChatState> with WidgetsBindingObserver {
  final String chatId;
  final String myUid;
  final String myName;

  StreamSubscription<List<Message>>? _messagesSubscription;

  List<Message> _lastKnownMessages = [];
  bool _hasData = false;
  Message? _replyingTo;
  final Set<String> _deliveredIds = {};

  /// تتبع حالة التطبيق (هل هو في الواجهة أم في الخلفية)
  bool _isAppInForeground = true;

  // ── Retry / timeout ───────────────────────────
  Timer? _retryTimer;
  Timer? _loadTimeout;
  int _retryCount = 0;

  // ── قناة أخطاء العمليات ─────────────────────────
  final StreamController<String> _errorsController = StreamController<String>.broadcast();
  Stream<String> get errors => _errorsController.stream;

  // ── طابور التفاعلات ───────────────────────────
  final Map<String, Future<void>> _reactionQueue = {};

  // ── المسودات ──────────────────────────────────
  static final Map<String, String> _drafts = {};
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
    // تسجيل مراقب دورة حياة التطبيق
    WidgetsBinding.instance.addObserver(this);
    _initChat();
  }

  // ─────────────────────────────────────────────
  // Lifecycle Management
  // ─────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = (state == AppLifecycleState.resumed);

    // عند عودة المستخدم للتطبيق والشات مفتوح، علم الرسائل كمقروءة
    if (_isAppInForeground) {
      markMessagesAsSeen();
    }
  }

  /// تحديث حالة القراءة بشرط وجود التطبيق في الواجهة
  void markMessagesAsSeen() {
    if (_isAppInForeground) {
      _fireAndForget(FirebaseRepo.markAsSeen(chatId, myUid), 'markAsSeen');
    }
  }

  // ─────────────────────────────────────────────
  // Init / Retry
  // ─────────────────────────────────────────────

  void _initChat() {
    _retryTimer?.cancel();
    _loadTimeout?.cancel();

    if (!_hasData) {
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

    markMessagesAsSeen();

    _messagesSubscription?.cancel();
    _messagesSubscription = FirebaseRepo.observeMessages(chatId, myUid).listen(
      (messages) {
        _retryCount = 0;
        _loadTimeout?.cancel();
        _hasData = true;
        _lastKnownMessages = messages;

        final reply = _replyingTo;
        if (reply != null && reply.id != null && !messages.any((m) => m.id == reply.id)) {
          _replyingTo = null;
        }

        _safeEmit(ChatLoaded(
          messages: messages,
          replyingTo: _replyingTo,
        ));

        // تعليم التسليم دائماً
        _handleDelivery(messages);

        // تعليم القراءة فقط إذا كان المستخدم ينظر للشاشة حالياً
        markMessagesAsSeen();
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

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final seconds = math.min(30, 2 << _retryCount++);
    _retryTimer = Timer(Duration(seconds: seconds), retry);
  }

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

  Future<bool> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final replyMsg = _replyingTo;
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
      return true;
    } catch (e) {
      debugPrint('sendMessage error: $e');
      setReply(replyMsg);
      _emitActionError('فشل إرسال الرسالة، حاول مرة أخرى.');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Delete / Edit / Reaction Actions
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
    if (targetIndex == -1) return;

    final originalMsg = current.messages[targetIndex];
    final originalReactions = originalMsg.reactions;
    final newReactions = Map<String, String>.from(originalReactions ?? const <String, String>{});

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
  // Helpers & Cleanup
  // ─────────────────────────────────────────────

  void _emitActionError(String message) {
    if (!_errorsController.isClosed) _errorsController.add(message);
  }

  void _fireAndForget(Future<void> future, String label) {
    unawaited(future.catchError((Object e) {
      debugPrint('$label error: $e');
    }));
  }

  void _safeEmit(ChatState newState) {
    if (!isClosed) emit(newState);
  }

  @override
  Future<void> close() {
    // إزالة المراقب عند إغلاق Cubit
    WidgetsBinding.instance.removeObserver(this);
    _messagesSubscription?.cancel();
    _retryTimer?.cancel();
    _loadTimeout?.cancel();
    _errorsController.close();
    return super.close();
  }
}
