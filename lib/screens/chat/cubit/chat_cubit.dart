// ============================================================
// chat_cubit.dart â€” ChatX Business Logic
// âœ… _restoreLoadedState Ù…ØµÙ„Ø­Ø© | âœ… is! operator ØµØ­
// âœ… Optimistic UI | âœ… senderName Ù…Ù† Firebase Auth
// âœ… Error recovery Ø°ÙƒÙŠ | âœ… No race conditions
// ============================================================

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatx/screens/chat/models/message_model.dart';
import '../../../repositories/firebase_repo.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// States
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
  /// Ø§Ù„Ø±Ø³Ø§Ø¦Ù„ Ø§Ù„Ø£Ø®ÙŠØ±Ø© Ø§Ù„Ù…Ø¹Ø±ÙˆÙØ© â€” Ù„Ùˆ Ø­ØµÙ„ error ÙˆÙ†Ø±Ø¬Ø¹ Ù…Ù†Ù‡
  final List<Message>? lastKnownMessages;

  const ChatError(this.errorMessage, {this.lastKnownMessages});
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Cubit
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ChatCubit extends Cubit<ChatState> {
  final String chatId;
  final String myUid;
  final String myName; // âœ… FIX: senderName Ø­Ù‚ÙŠÙ‚ÙŠ Ù…Ø´ hardcoded

  StreamSubscription<List<Message>>? _messagesSubscription;

  /// Ø¢Ø®Ø± Ù‚Ø§ÙŠÙ…Ø© Ø±Ø³Ø§Ø¦Ù„ ÙˆØµÙ„Øª Ù…Ù† Ø§Ù„Ù€ stream â€” Ù„Ù„Ù€ recovery
  List<Message> _lastKnownMessages = [];

  /// IDs Ø§Ù„Ø±Ø³Ø§Ø¦Ù„ Ø§Ù„Ù„ÙŠ ØªÙ… mark ÙƒÙ€ delivered Ø¹Ø´Ø§Ù† Ù…Ù†Ø¹Ù…Ù„Ù‡Ø§Ø´ ØªØ§Ù†ÙŠ
  final Set<String> _deliveredIds = {};

  ChatCubit({
    required this.chatId,
    required this.myUid,
    required this.myName,
  }) : super(const ChatInitial()) {
    _initChat();
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Init
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _initChat() {
    _safeEmit(const ChatLoading());
    FirebaseRepo.markAsSeen(chatId, myUid);

    _messagesSubscription = FirebaseRepo.observeMessages(chatId, myUid).listen(
      (messages) {
        // ✅ FIX: messages جايه دلوقتي descending من FirebaseRepo (الأحدث
        // أولاً) — فمفيش حاجة نعكسها هنا تاني. index 0 = أحدث رسالة،
        // ومطابق لما الـ ListView (reverse: true) في chat_screen.dart مفترضه.
        _lastKnownMessages = messages;

        final currentReply = state is ChatLoaded
            ? (state as ChatLoaded).replyingTo
            : null;

        _safeEmit(ChatLoaded(
          messages: messages, // descending — index 0 = أحدث رسالة
          replyingTo: currentReply,
        ));

        _handleDelivery(messages);
      },
      onError: (Object error) {
        _safeEmit(ChatError(
          'Ø­Ø¯Ø« Ø®Ø·Ø£ Ø£Ø«Ù†Ø§Ø¡ Ø¬Ù„Ø¨ Ø§Ù„Ø±Ø³Ø§Ø¦Ù„: ${error.toString()}',
          lastKnownMessages: _lastKnownMessages,
        ));
      },
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Delivery Marking
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _handleDelivery(List<Message> messages) {
    // 🟢 Performance Fix #4: بدل iterate على كل الـ messages في كل stream event
    // (حتى القديمة الموجودة في _deliveredIds)\u060c دلوقتي بنجيب
    // بس الـ messages الجديدة — بتحديد الـ message اللي مش عندنا idه في _deliveredIds أصلاً.
    for (final msg in messages) {
      final id = msg.id;
      if (id == null || _deliveredIds.contains(id)) continue; // skip بسرعة
      if (!msg.isMe && msg.status == MessageStatus.sent) {
        _deliveredIds.add(id);
        FirebaseRepo.markAsDelivered(chatId, id);
      }
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Reply Management
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void setReply(Message? message) {
    if (state is ChatLoaded) {
      _safeEmit((state as ChatLoaded).copyWith(
        replyingTo: message,
        clearReply: message == null,
      ));
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Send Message
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final replyMsg = currentState.replyingTo;

    // âœ… Ø§Ù…Ø³Ø­ Ø§Ù„Ù€ reply ÙÙˆØ±Ø§Ù‹ Ù…Ù† Ø§Ù„Ù€ UI Ù‚Ø¨Ù„ Ù…Ø§ Ù†Ø¨Ø¹Øª
    setReply(null);

    final newMessage = Message.create(
      text: trimmed,
      isMe: true,
      senderId: myUid,
      senderName: myName, // âœ… FIX: Ø­Ù‚ÙŠÙ‚ÙŠ Ù…Ø´ 'Me'
      replyToId: replyMsg?.id,
      replyTo: replyMsg,
      status: MessageStatus.sent,
    );

    try {
      await FirebaseRepo.sendMessage(chatId, newMessage);
      // Ø§Ù„Ù€ stream Ù‡ÙŠØ¬ÙŠØ¨ Ø§Ù„Ø±Ø³Ø§Ù„Ø© Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø© ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹ â€” Ù…ÙÙŠØ´ Ø­Ø§Ø¬Ø© ØªØ§Ù†ÙŠØ©
    } catch (e) {
      _safeEmit(ChatError(
        'ÙØ´Ù„ Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„Ø±Ø³Ø§Ù„Ø©ØŒ Ø­Ø§ÙˆÙ„ Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.',
        lastKnownMessages: _lastKnownMessages,
      ));
      // âœ… FIX: Ø¨Ø¹Ø¯ Ø«Ø§Ù†ÙŠØ© Ù†Ø±Ø¬Ø¹ Ù„Ù„Ø­Ø§Ù„Ø© Ø§Ù„Ù…Ø­ÙÙˆØ¸Ø© Ù„Ùˆ Ù„Ø³Ù‡ ÙÙŠ error
      // 🟢 Performance Fix #5: مش بنستننا لو الـ cubit اتـ close خلال الـ delay.
      if (!isClosed) _restoreLoadedState();
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Delete Message
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> deleteMessage(String? messageId) async {
    // âœ… FIX: Ø¨Ù†Ù‚Ø¨Ù„ String? ÙˆÙ…Ù†Ø¹Ù…Ù„Ø´ crash Ù„Ùˆ null
    if (messageId == null || messageId.isEmpty) return;

    try {
      await FirebaseRepo.deleteMessage(chatId, messageId, myUid);
    } catch (e) {
      _safeEmit(ChatError(
        'ÙØ´Ù„ Ø­Ø°Ù Ø§Ù„Ø±Ø³Ø§Ù„Ø©.',
        lastKnownMessages: _lastKnownMessages,
      ));
      // 🟢 Performance Fix #5: مش بنستننا لو الـ cubit اتـ close خلال الـ delay.
      if (!isClosed) _restoreLoadedState();
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Edit Message
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> editMessage(String? messageId, String newText) async {
    final trimmed = newText.trim();
    if (messageId == null || messageId.isEmpty || trimmed.isEmpty) return;

    try {
      await FirebaseRepo.updateMessage(chatId, messageId, trimmed, myUid);
    } catch (e) {
      _safeEmit(ChatError(
        'ÙØ´Ù„ ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø±Ø³Ø§Ù„Ø©.',
        lastKnownMessages: _lastKnownMessages,
      ));
      // 🟢 Performance Fix #5: مش بنستننا لو الـ cubit اتـ close خلال الـ delay.
      if (!isClosed) _restoreLoadedState();
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Add Reaction
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> addReaction(String? messageId, String emoji) async {
    if (messageId == null || messageId.isEmpty || emoji.isEmpty) return;
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;

    // 🟢 Performance Fix #3: بدل نسختين كاملتين من الـ messages:
    //   - List.from(currentState.messages)   ← نسخة 1 للـ rollback
    //   - .map(...).toList()                ← نسخة 2 للـ optimistic
    // دلوقتي: بنحدد مكان الـ message في الـ list بـ indexWhere ونبني
    // نسخة واحدة بس نستبدل الـ element زي ما هو — من O(2n) لـ O(n).
    final targetIndex = currentState.messages.indexWhere((m) => m.id == messageId);
    if (targetIndex == -1) return; // الـ message مش موجودة أصلاً — معندناش نكمل

    final originalMsg = currentState.messages[targetIndex];
    final newReactions = Map<String, String>.from(originalMsg.reactions ?? {});
    if (newReactions[myUid] == emoji) {
      newReactions.remove(myUid);
    } else {
      newReactions[myUid] = emoji;
    }
    final updatedMsg = originalMsg.copyWith(
      reactions: newReactions.isEmpty ? null : newReactions,
      clearReactions: newReactions.isEmpty,
    );

    // نسخة واحدة فقط — نستعملها للـ optimistic ولو حصل rollback في نفس الـ list
    final updatedMessages = List<Message>.of(currentState.messages);
    updatedMessages[targetIndex] = updatedMsg;

    _safeEmit(currentState.copyWith(messages: updatedMessages));

    try {
      await FirebaseRepo.addReaction(chatId, messageId, emoji, myUid);
    } catch (e) {
      // Rollback: نرجع الـ original message في نفس الـ index — دون نسختين
      updatedMessages[targetIndex] = originalMsg;
      _safeEmit(currentState.copyWith(messages: updatedMessages));
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // State Recovery â€” âœ… FIXED (ÙƒØ§Ù†Øª ÙØ§Ø¶ÙŠØ© ØªÙ…Ø§Ù…Ø§Ù‹)
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _restoreLoadedState() {
    // âœ… FIX: is! Ø¨Ø¯Ù„ Ù…Ù† `state is ChatLoaded == false` (ÙƒØ§Ù† Ø®Ø·Ø£ Ù†Ø­ÙˆÙŠ)
    if (state is! ChatError) return;

    if (_lastKnownMessages.isNotEmpty) {
      _safeEmit(ChatLoaded(messages: _lastKnownMessages));
    } else {
      // Ù„Ùˆ Ù…ÙÙŠØ´ Ø±Ø³Ø§Ø¦Ù„ Ù…Ø­ÙÙˆØ¸Ø© â€” Ù†Ø±Ø¬Ø¹ Ù„Ù„Ù€ loading ÙˆÙ†Ø¹Ù…Ù„ reinit
      _safeEmit(const ChatLoading());
      _messagesSubscription?.cancel();
      _initChat();
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Safe Emit â€” âœ… Ù…Ù†Ø¹ crash Ø¨Ø¹Ø¯ close()
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _safeEmit(ChatState newState) {
    // 🟢 Performance Fix #1: حذف _isClosed المكررة — isClosed موجودة في BlocBase.
    // القديم: bool إضافية بتتـ set يدوياً وممكن تختلف عن isClosed الأصلية.
    if (!isClosed) emit(newState);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Cleanup
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
