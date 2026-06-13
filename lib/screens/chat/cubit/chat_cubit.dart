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
        // 🔥 التريكاية: بنعكس الرسايل هنا عشان الـ ListView (reverse: true) تشتغل بأداء خيالي وتبدأ من تحت
        final reversedMessages = messages.reversed.toList();
        
        emit(ChatLoaded(
          messages: reversedMessages,
          replyingTo: replyingTo,
        ));
      },
      onError: (error) {
        emit(ChatError("حدث خطأ أثناء جلب الرسائل: \${error.toString()}"));
      },
    );
  }

  // 🔄 تفعيل أو إلغاء الرد على رسالة
  void setReply(Message? message) {
    replyingTo = message;
    
    // تحديث الـ UI فورا لو إحنا في حالة الـ Loaded
    if (state is ChatLoaded) {
      final currentMessages = (state as ChatLoaded).messages;
      emit(ChatLoaded(messages: currentMessages, replyingTo: replyingTo));
    }
  }

  // 📤 إرسال رسالة جديدة
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // حفظ بيانات الرد قبل مسحها
    final replyId = replyingTo?.id;
    final replyMsg = replyingTo;

    // مسح الرد فوراً من الـ UI عشان تجربة المستخدم تكون أسرع
    setReply(null);

    // تجهيز موديل الرسالة (بدون ستيكرز زي ما طلبت)
    final newMessage = Message(
      text: text,
      isMe: true,
      senderId: myUid,
      senderName: 'Me',
      replyToId: replyId,
      replyTo: replyMsg,
      // ضيف هنا أي حقول تانية مطلوبة في الـ Model زي type أو غيره
    );

    try {
      await FirebaseRepo.sendMessage(chatId, newMessage);
    } catch (e) {
      // لو حصل مشكلة في الإرسال ممكن نطبعها أو نظهر Snackbar
      print("Error sending message: \$e");
    }
  }

  // 🧹 تنظيف الذاكرة لما اليوزر يخرج من الشات
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
