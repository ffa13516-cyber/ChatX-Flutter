  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_cubit.dart';
import 'home_screen_ui.dart';
import '../groups/groups_tab.dart'; // âœ… Ø¹Ø´Ø§Ù† CreateGroupSheet

class HomeScreen extends StatelessWidget {
  final String myUid;
  final String myName;

  const HomeScreen({
    super.key,
    required this.myUid,
    required this.myName,
  });

  // âœ… ÙØªØ­ CreateGroupSheet Ù…Ø¨Ø§Ø´Ø±Ø©Ù‹ Ù…Ù† Ù‡Ù†Ø§ Ø¨Ø¯Ù„ Ù…Ø§ ØªÙ…Ø± Ø¨Ø§Ù„Ù€ Cubit
  void _openCreateGroup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CreateGroupSheet(myUid: myUid),
    );
  }

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
            onCreateGroup: () => _openCreateGroup(context), // âœ… Ø±Ø¨Ø· Ø­Ù‚ÙŠÙ‚ÙŠ
            onSearch: cubit.search,
            myUid: myUid,
            myName: myName,
          );
        },
      ),
    );
  }
}
