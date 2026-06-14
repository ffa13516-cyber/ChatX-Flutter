import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatx/screens/chat/models/message_model.dart';
import '../../../repositories/firebase_repo.dart';

// ==========================================
// 1. حالات الشاشة (States)
// ==========================================
abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final Message? replyingTo;

  ChatLoaded({required this.messages, this.replyingTo});
}

class ChatError extends ChatState {
  final String errorMessage;
  ChatError(this.errorMessage);
}

// ==========================================
// 2. اللوجيك الأساسي (Cubit)
// ==========================================
class ChatCubit extends Cubit<ChatState> {
  final String chatId;
  final String myUid;

  StreamSubscription? _messagesSubscription;
  Message? replyingTo;

  // ✅ FIX #3: بنتتبع الرسايل اللي عملنالها delivered عشان منعملهاش تاني
  final Set<String> _deliveredIds = {};

  ChatCubit({required this.chatId, required this.myUid}) : super(ChatInitial()) {
    _initChat();
  }

  void _initChat() {
    FirebaseRepo.markAsSeen(chatId, myUid);

    _messagesSubscription = FirebaseRepo.observeMessages(chatId, myUid).listen(
      (messages) {
        final reversedMessages = messages.reversed.toList();

        emit(ChatLoaded(
          messages: reversedMessages,
          replyingTo: replyingTo,
        ));

        // ✅ FIX #3: الـ markAsDelivered اتنقل من الـ Stream للـ Cubit
        // وبيشتغل بس لو الرسالة جديدة ومش اتعملتلها delivered قبل كده
        _handleDelivery(messages);
      },
      onError: (error) {
        emit(ChatError("حدث خطأ أثناء جلب الرسائل: ${error.toString()}"));
      },
    );
  }

  // ✅ بنعمل delivered بس للرسايل الجديدة اللي لسه ماتعملتلهاش
  void _handleDelivery(List<Message> messages) {
    for (final msg in messages) {
      if (!msg.isMe &&
          msg.status == MessageStatus.sent &&
          msg.id != null &&
          !_deliveredIds.contains(msg.id)) {
        _deliveredIds.add(msg.id!);
        FirebaseRepo.markAsDelivered(chatId, msg.id!);
      }
    }
  }

  void setReply(Message? message) {
    replyingTo = message;
    if (state is ChatLoaded) {
      final currentMessages = (state as ChatLoaded).messages;
      emit(ChatLoaded(messages: currentMessages, replyingTo: replyingTo));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final replyId = replyingTo?.id;
    final replyMsg = replyingTo;
    setReply(null);

    final newMessage = Message(
      text: text,
      isMe: true,
      senderId: myUid,
      senderName: 'Me',
      replyToId: replyId,
      replyTo: replyMsg,
    );

    try {
      await FirebaseRepo.sendMessage(chatId, newMessage);
    } catch (e) {
      // ✅ بنعمل emit بـ error بدل print عشان الـ UI يعرف
      emit(ChatError("فشل إرسال الرسالة، حاول مرة أخرى."));
      // نرجع للـ state القديم بعد ثانية عشان الـ UI ميتجمدش
      await Future.delayed(const Duration(seconds: 1));
      if (state is ChatError && state is ChatLoaded == false) {
        _restoreLoadedState();
      }
    }
  }

  // ✅ FIX #7: بنمرر myUid للـ repo عشان يتحقق من الـ ownership
  Future<void> deleteMessage(String messageId) async {
    try {
      await FirebaseRepo.deleteMessage(chatId, messageId, myUid);
    } catch (e) {
      emit(ChatError("فشل حذف الرسالة."));
      await Future.delayed(const Duration(seconds: 1));
      _restoreLoadedState();
    }
  }

  // ✅ FIX #7: بنمرر myUid للـ repo عشان يتحقق من الـ ownership
  Future<void> editMessage(String? messageId, String newText) async {
    if (messageId == null || newText.trim().isEmpty) return;
    try {
      await FirebaseRepo.updateMessage(chatId, messageId, newText, myUid);
    } catch (e) {
      emit(ChatError("فشل تعديل الرسالة."));
      await Future.delayed(const Duration(seconds: 1));
      _restoreLoadedState();
    }
  }

  // helper: نرجع للـ ChatLoaded لو عندنا رسايل محملة
  void _restoreLoadedState() {
    if (state is ChatLoaded) return;
    // الـ stream هيعمل emit تلقائياً بالـ state الصح
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
