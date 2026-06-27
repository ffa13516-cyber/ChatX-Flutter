// ============================================================
// group_chat_cubit.dart â€” ChatX Group Chat Logic
// âœ… Ù†ÙØ³ patterns Ø§Ù„Ù€ ChatCubit Ø¨Ø§Ù„Ø¸Ø¨Ø·
// âœ… ÙŠØ³ØªØ®Ø¯Ù… groupMsgsRef Ù…Ø´ messagesRef
// âœ… Optimistic UI Ù„Ù„Ù€ reactions
// âœ… Error recovery + safe emit
// ============================================================

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatx/screens/chat/models/message_model.dart';
import '../../../repositories/firebase_repo.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// States â€” Ù†ÙØ³ ChatState Ø¨Ø§Ù„Ø¸Ø¨Ø· Ø¹Ø´Ø§Ù† Ù†Ø´Ø§Ø±Ùƒ Ø§Ù„Ù€ UI widgets
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  const ChatError(this.errorMessage, {this.lastKnownMessages});
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// GroupChatCubit
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class GroupChatCubit extends Cubit<ChatState> {
  final String groupId;
  final String myUid;
  final String myName;

  StreamSubscription<List<Message>>? _messagesSubscription;
  List<Message> _lastKnownMessages = [];

  GroupChatCubit({
    required this.groupId,
    required this.myUid,
    required this.myName,
  }) : super(const ChatInitial()) {
    _initChat();
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Init
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _initChat() {
    _safeEmit(const ChatLoading());

    _messagesSubscription =
        FirebaseRepo.observeGroupMessagesNew(groupId, myUid).listen(
      (messages) {
        _lastKnownMessages = messages;

        final currentReply =
            state is ChatLoaded ? (state as ChatLoaded).replyingTo : null;

        _safeEmit(ChatLoaded(
          messages: messages, // descending â€” index 0 = Ø£Ø­Ø¯Ø« Ø±Ø³Ø§Ù„Ø©
          replyingTo: currentReply,
        ));
      },
      onError: (Object error) {
        _safeEmit(ChatError(
          'Ø­Ø¯Ø« Ø®Ø·Ø£ Ø£Ø«Ù†Ø§Ø¡ Ø¬Ù„Ø¨ Ø§Ù„Ø±Ø³Ø§Ø¦Ù„: ${error.toString()}',
          lastKnownMessages: _lastKnownMessages,
        ));
      },
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Reply
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void setReply(Message? message) {
    if (state is ChatLoaded) {
      _safeEmit((state as ChatLoaded).copyWith(
        replyingTo: message,
        clearReply: message == null,
      ));
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Send Message
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final replyMsg = currentState.replyingTo;

    setReply(null); // Ø§Ù…Ø³Ø­ Ø§Ù„Ù€ reply Ù…Ù† Ø§Ù„Ù€ UI ÙÙˆØ±Ø§Ù‹

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
      await FirebaseRepo.sendGroupMessageNew(groupId, newMessage);
      // Ø§Ù„Ù€ stream Ù‡ÙŠØ¬ÙŠØ¨ Ø§Ù„Ø±Ø³Ø§Ù„Ø© ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹
    } catch (e) {
      _safeEmit(ChatError(
        'ÙØ´Ù„ Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„Ø±Ø³Ø§Ù„Ø©ØŒ Ø­Ø§ÙˆÙ„ Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.',
        lastKnownMessages: _lastKnownMessages,
      ));
      if (!isClosed) _restoreLoadedState();
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Delete Message
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> deleteMessage(String? messageId) async {
    if (messageId == null || messageId.isEmpty) return;

    try {
      await FirebaseRepo.deleteGroupMessage(groupId, messageId, myUid);
    } catch (e) {
      _safeEmit(ChatError(
        'ÙØ´Ù„ Ø­Ø°Ù Ø§Ù„Ø±Ø³Ø§Ù„Ø©.',
        lastKnownMessages: _lastKnownMessages,
      ));
      if (!isClosed) _restoreLoadedState();
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Edit Message
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> editMessage(String? messageId, String newText) async {
    final trimmed = newText.trim();
    if (messageId == null || messageId.isEmpty || trimmed.isEmpty) return;

    try {
      await FirebaseRepo.updateGroupMessage(groupId, messageId, trimmed, myUid);
    } catch (e) {
      _safeEmit(ChatError(
        'ÙØ´Ù„ ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø±Ø³Ø§Ù„Ø©.',
        lastKnownMessages: _lastKnownMessages,
      ));
      if (!isClosed) _restoreLoadedState();
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Add Reaction â€” Optimistic UI
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> addReaction(String? messageId, String emoji) async {
    if (messageId == null || messageId.isEmpty || emoji.isEmpty) return;
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;

    final targetIndex =
        currentState.messages.indexWhere((m) => m.id == messageId);
    if (targetIndex == -1) return;

    final originalMsg = currentState.messages[targetIndex];
    final newReactions =
        Map<String, String>.from(originalMsg.reactions ?? {});

    // toggle: Ù„Ùˆ Ù†ÙØ³ Ø§Ù„Ù€ emoji Ø§Ù…Ø³Ø­Ù‡ØŒ ØºÙŠØ± ÙƒØ¯Ù‡ Ø§Ø¶ÙŠÙÙ‡
    if (newReactions[myUid] == emoji) {
      newReactions.remove(myUid);
    } else {
      newReactions[myUid] = emoji;
    }

    final updatedMsg = originalMsg.copyWith(
      reactions: newReactions.isEmpty ? null : newReactions,
      clearReactions: newReactions.isEmpty,
    );

    final updatedMessages = List<Message>.of(currentState.messages);
    updatedMessages[targetIndex] = updatedMsg;

    _safeEmit(currentState.copyWith(messages: updatedMessages));

    try {
      await FirebaseRepo.addGroupReaction(groupId, messageId, emoji, myUid);
    } catch (e) {
      // Rollback
      updatedMessages[targetIndex] = originalMsg;
      _safeEmit(currentState.copyWith(messages: updatedMessages));
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // State Recovery
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _restoreLoadedState() {
    if (state is! ChatError) return;

    if (_lastKnownMessages.isNotEmpty) {
      _safeEmit(ChatLoaded(messages: _lastKnownMessages));
    } else {
      _safeEmit(const ChatLoading());
      _messagesSubscription?.cancel();
      _initChat();
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Safe Emit
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _safeEmit(ChatState newState) {
    if (!isClosed) emit(newState);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Cleanup
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
