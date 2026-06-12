import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/firebase_repo.dart';
import 'models/message_model.dart';

// حالات الشاشة
abstract class ChatState {}
class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatLoaded extends ChatState {
  final List<Message> messages;
  ChatLoaded(this.messages);
}

// متحكم الشات (Clean Architecture)
class ChatCubit extends Cubit<ChatState> {
  final String chatId;
  final String myUid;
  
  Message? replyingTo;

  ChatCubit({required this.chatId, required this.myUid}) : super(ChatInitial()) {
    _initChat();
  }

  void _initChat() {
    FirebaseRepo.markAsSeen(chatId, myUid);
    // مراقبة الرسائل وعكس الترتيب ليتوافق مع أداء الـ UI الجديد
    FirebaseRepo.observeMessages(chatId, myUid).listen((messages) {
      // عكس المصفوفة لتتناسب مع reverse: true في واجهة المستخدم
      emit(ChatLoaded(messages.reversed.toList()));
    });
  }

  void setReply(Message? message) {
    replyingTo = message;
    emit(state); // تحديث الـ UI
  }

  Future<void> sendMessage(String text) async {
    final msg = Message(
      text: text,
      isMe: true,
      senderId: myUid,
      senderName: 'Me',
      replyToId: replyingTo?.id,
      replyTo: replyingTo,
      // تم إزالة أي متغيرات خاصة بالاستيكرز من هنا
    );

    await FirebaseRepo.sendMessage(chatId, msg);
    setReply(null); // إلغاء الرد بعد الإرسال
  }
}
