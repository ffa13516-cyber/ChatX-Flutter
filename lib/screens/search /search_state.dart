part of 'search_cubit.dart';

abstract class SearchState {}

/// الحالة الافتراضية — لم يبدأ المستخدم البحث بعد
class SearchInitial extends SearchState {}

/// جاري البحث
class SearchLoading extends SearchState {}

/// تم إيجاد مستخدم
class SearchSuccess extends SearchState {
  final UserModel user;
  SearchSuccess(this.user);
}

/// لم يُوجد مستخدم بهذا الـ username
class SearchEmpty extends SearchState {}

/// حدث خطأ أثناء البحث أو فتح الشات
class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

/// جاري إنشاء/جلب الشات قبل الانتقال إليه
class SearchOpeningChat extends SearchState {}

/// الشات جاهز — يحمل بيانات الانتقال
class SearchChatReady extends SearchState {
  final String chatId;
  SearchChatReady(this.chatId);
}
