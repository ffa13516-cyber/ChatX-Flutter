import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatx/screens/chat/models/message_model.dart';
import '../../../repositories/firebase_repo.dart'; // 🚀 تأكد من مسار الـ Repo بتاعك

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
  Message? replyingTo; // متغير متاح للـ UI للوصول السريع

  ChatCubit({required this.chatId, required this.myUid}) : super(ChatInitial()) {
    _initChat();
  }

  // 🚀 تهيئة الشات وجلب الرسائل
  void _initChat() {
    // 1. علّم الرسايل إنها اتقرت أول ما تفتح الشاشة
    FirebaseRepo.markAsSeen(chatId, myUid);

    // 2. استمع للرسايل من فايربيز (Real-time)
    _messagesSubscription = FirebaseRepo.observeMessages(chatId, myUid).listen(
      (messages) {
        final reversedMessages = messages.reversed.toList();
        
        emit(ChatLoaded(
          messages: reversedMessages,
          replyingTo: replyingTo,
        ));
      },
      onError: (error) {
        emit(ChatError("حدث خطأ أثناء جلب الرسائل: ${error.toString()}"));
      },
    );
  }

  // 🔄 تفعيل أو إلغاء الرد على رسالة
  void setReply(Message? message) {
    replyingTo = message;
    
    if (state is ChatLoaded) {
      final currentMessages = (state as ChatLoaded).messages;
      emit(ChatLoaded(messages: currentMessages, replyingTo: replyingTo));
    }
  }

  // 📤 إرسال رسالة جديدة
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
      print("Error sending message: $e");
    }
  }

  // 🗑️ دالة حذف الرسالة
  Future<void> deleteMessage(String messageId) async {
    try {
      // بنباصي الـ chatId والـ messageId للـ Firebase
      await FirebaseRepo.deleteMessage(chatId, messageId);
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  // ✏️ دالة تعديل الرسالة
  Future<void> editMessage(String messageId, String newText) async {
    if (newText.trim().isEmpty) return;
    try {
      // بنباصي الـ chatId والـ messageId والنص الجديد للـ Firebase
      await FirebaseRepo.updateMessage(chatId, messageId, newText);
    } catch (e) {
      print("Error editing message: $e");
    }
  }

  // 🧹 تنظيف الذاكرة
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
