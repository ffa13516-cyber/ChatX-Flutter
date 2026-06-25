import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/models.dart';
import '../../../repositories/firebase_repo.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final String myUid;

  Timer? _debounce;

  SearchCubit({required this.myUid}) : super(SearchInitial());

  /// يُستدعى عند تغيُّر نص البحث — مع Debounce 500ms
  void onQueryChanged(String query) {
    _debounce?.cancel();

    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    _debounce = Timer(const Duration(milliseconds: 500), () => _search(trimmed));
  }

  Future<void> _search(String username) async {
    try {
      final user = await FirebaseRepo.getUserByUsername(username);
      if (isClosed) return;

      if (user == null) {
        emit(SearchEmpty());
      } else {
        emit(SearchSuccess(user));
      }
    } catch (_) {
      if (!isClosed) emit(SearchError('Something went wrong. Please try again.'));
    }
  }

  /// يُستدعى عند الضغط على نتيجة البحث لفتح/إنشاء شات
  Future<void> openChat(UserModel user) async {
    emit(SearchOpeningChat());
    try {
      final chat = await FirebaseRepo.getOrCreateChat(myUid, user.uid);
      if (!isClosed) emit(SearchChatReady(chat.chatId));
    } catch (_) {
      if (!isClosed) emit(SearchError('Failed to open chat. Please try again.'));
    }
  }

  /// إعادة الحالة بعد الانتقال لشاشة الشات (لمنع إعادة التشغيل عند العودة)
  void resetAfterNavigation() => emit(SearchInitial());

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
