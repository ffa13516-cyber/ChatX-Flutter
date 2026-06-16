import 'package:flutter_bloc/flutter_bloc.dart';

// -----------------------------------------
// 1. Home State
// -----------------------------------------
class HomeState {
  final int currentIndex;
  final String searchQuery;

  HomeState({
    this.currentIndex = 0,
    this.searchQuery = '',
  });

  HomeState copyWith({
    int? currentIndex,
    String? searchQuery,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// -----------------------------------------
// 2. Home Cubit
// -----------------------------------------
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  // تغيير التاب في البار السفلي
  void changeTab(int index) {
    emit(state.copyWith(currentIndex: index));
  }

  // تحديث نص البحث
  void search(String query) {
    emit(state.copyWith(searchQuery: query));
    // هنا ممكن تضيف لوجيك الفلترة أو تبعت الـ query للـ Cubit بتاع الشات
  }

  // لوجيك إنشاء قناة
  void createChannel() {
    print('Navigate to Create Channel Screen');
    // Navigation logic goes here
  }

  // لوجيك إنشاء مجموعة
  void createGroup() {
    print('Navigate to Create Group Screen');
    // Navigation logic goes here
  }
}
