import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// Avatar Widget
class AvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;
  final bool showOnline;

  const AvatarWidget({
    super.key,
    required this.name,
    this.size = 48,
    this.imageUrl,
    this.showOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.avatarColor(name),
            image: imageUrl != null && imageUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl == null || imageUrl!.isEmpty
              ? Center(
                  child: Text(
                    _initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
        if (showOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.online,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bgDark, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// Gradient Button
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

// Custom Text Field
class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textHint),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.textHint)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// Chat List Item
class ChatListItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String? avatarUrl;
  final bool isOnline;
  final VoidCallback onTap;
  final bool isSavedMessages;

  const ChatListItem({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.avatarUrl,
    this.isOnline = false,
    required this.onTap,
    this.isSavedMessages = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            isSavedMessages
                ? Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark, color: Colors.white, size: 24),
                  )
                : AvatarWidget(
                    name: name,
                    size: 52,
                    imageUrl: avatarUrl,
                    showOnline: isOnline,
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: unreadCount > 0 ? AppColors.primary : AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                          style: TextStyle(
                            color: unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Message Bubble
class MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isSent;
  final String senderName;
  final bool showSenderName;

  const MessageBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isSent,
    this.senderName = '',
    this.showSenderName = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isSent ? 60 : 12,
        right: isSent ? 12 : 60,
        top: 3,
        bottom: 3,
      ),
      child: Row(
        mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) ...[
            AvatarWidget(name: senderName, size: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSent ? AppColors.primaryGradient : null,
                color: isSent ? null : AppColors.bgCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isSent ? 18 : 4),
                  bottomRight: Radius.circular(isSent ? 4 : 18),
                ),
                boxShadow: isSent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSenderName && !isSent)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        senderName,
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    text,
                    style: TextStyle(
                      color: isSent ? Colors.white : AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: isSent ? Colors.white.withOpacity(0.7) : AppColors.textHint,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Message Input Bar
class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hint;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.hint = 'Message...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// Empty State
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
