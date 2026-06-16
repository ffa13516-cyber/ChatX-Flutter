import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_cubit.dart';
import 'home_screen_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بنوفر الـ Cubit للشاشة دي
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          // بنجيب نسخة من الـ Cubit عشان نستخدم الـ Functions بتاعته
          final cubit = context.read<HomeCubit>();

          // بنرجع الـ UI اللي فصلناه، وبنبعتله الداتا واللوجيك
          return HomeScreenUI(
            currentIndex: state.currentIndex,
            onTabSelected: cubit.changeTab,
            onCreateChannel: cubit.createChannel,
            onCreateGroup: cubit.createGroup,
            onSearch: cubit.search,
          );
        },
      ),
    );
  }
}
