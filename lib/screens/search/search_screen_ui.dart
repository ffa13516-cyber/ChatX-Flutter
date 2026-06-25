import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/models.dart';
import 'package:chatx/screens/chat/chat_screen.dart';
import 'search_cubit.dart';

class SearchScreen extends StatefulWidget {
  final String myUid;
  final String myName;

  const SearchScreen({
    Key? key,
    required this.myUid,
    required this.myName,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  static const _accent = Color(0xFF6C63FF);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(myUid: widget.myUid),
      child: BlocListener<SearchCubit, SearchState>(
        listener: _handleStateChanges,
        child: Scaffold(
          backgroundColor: const Color(0xFF0A0A0E),
          body: SafeArea(
            child: Column(
              children: [
                _SearchBar(controller: _controller),
                Divider(color: _accent.withOpacity(0.1), height: 1, thickness: 1),
                const Expanded(child: _SearchBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, SearchState state) {
    if (state is SearchChatReady) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: state.chatId,
            myUid: widget.myUid,
            myName: widget.myName,
          ),
        ),
      ).then((_) {
        if (context.mounted) {
          context.read<SearchCubit>().resetAfterNavigation();
        }
      });
    }

    if (state is SearchError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: const Color(0xFF2A1A2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Search Bar Widget
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  static const _accent = Color(0xFF6C63FF);

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A22).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _accent.withOpacity(0.15), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    selectionColor: _accent.withOpacity(0.3),
                    selectionHandleColor: _accent,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: _accent,
                  onChanged: (q) => context.read<SearchCubit>().onQueryChanged(q),
                  decoration: InputDecoration(
                    hintText: 'Search by username...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15),
                    prefixIcon: Icon(Icons.search_rounded, color: _accent.withOpacity(0.7), size: 22),
                    suffixIcon: ListenableBuilder(
                      listenable: controller,
                      builder: (_, __) => controller.text.isNotEmpty
                          ? IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _accent.withOpacity(0.15),
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                              ),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                controller.clear();
                                context.read<SearchCubit>().onQueryChanged('');
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Body â€” ÙŠØ¹Ø±Ø¶ Ø§Ù„Ø­Ø§Ù„Ø§Øª Ø§Ù„Ù…Ø®ØªÙ„ÙØ©
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SearchBody extends StatelessWidget {
  const _SearchBody();

  static const _accent = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading || state is SearchOpeningChat) {
          return Center(
            child: CircularProgressIndicator(color: _accent, strokeWidth: 2),
          );
        }

        if (state is SearchSuccess) {
          return _UserResultTile(
            user: state.user,
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<SearchCubit>().openChat(state.user);
            },
          );
        }

        if (state is SearchEmpty) {
          return _EmptyState(message: 'No user found with this username');
        }

        // SearchInitial Ø£Ùˆ Ø£ÙŠ Ø­Ø§Ù„Ø© Ø£Ø®Ø±Ù‰
        return _EmptyState(message: 'Type a username to start chatting');
      },
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// User Result Tile
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _UserResultTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  static const _accent = Color(0xFF6C63FF);

  const _UserResultTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          onTap: onTap,
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: _accent.withOpacity(0.1),
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Icon(Icons.person, color: _accent, size: 22)
                : null,
          ),
          title: Text(
            user.displayName,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '@${user.username}',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withOpacity(0.2),
            size: 14,
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Empty / Initial State
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EmptyState extends StatelessWidget {
  final String message;

  static const _accent = Color(0xFF6C63FF);

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.manage_search_rounded,
              size: 70,
              color: _accent.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
