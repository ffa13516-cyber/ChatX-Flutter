import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_cubit.dart';
import 'home_screen_ui.dart';

class HomeScreen extends StatelessWidget {
  final String myUid;
  final String myName;

  const HomeScreen({
    super.key,
    required this.myUid,
    required this.myName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final cubit = context.read<HomeCubit>();

          return HomeScreenUI(
            currentIndex: state.currentIndex,
            onTabSelected: cubit.changeTab,
            onCreateChannel: cubit.createChannel,
            onCreateGroup: cubit.createGroup,
            onSearch: cubit.search,
            myUid: myUid,
            myName: myName,
          );
        },
      ),
    );
  }
}
