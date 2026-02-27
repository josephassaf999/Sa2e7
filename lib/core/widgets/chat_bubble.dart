import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sa2e7/core/themes/design_tokens.dart';

/// Reusable chat message bubble widget
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByCurrentUser;
  final DateTime timestamp;
  final bool isRead;
  final VoidCallback? onDelete;
  final String senderName;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isSentByCurrentUser,
    required this.timestamp,
    required this.senderName,
    this.isRead = false,
    this.onDelete,
  }) : super(key: key);

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return intl.DateFormat('MMM dd, yyyy').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing16,
        vertical: DesignTokens.spacing8,
      ),
      child: Row(
        mainAxisAlignment:
            isSentByCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        children: [
          if (!isSentByCurrentUser)
            Padding(
              padding: const EdgeInsets.only(right: DesignTokens.spacing8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          Flexible(
            child: GestureDetector(
              onLongPress:
                  isSentByCurrentUser ? () => _showMessageMenu(context) : null,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isSentByCurrentUser
                          ? Theme.of(context).colorScheme.primary
                          : (isDarkMode
                              ? DesignTokens.surfaceVariantDark
                              : DesignTokens.surfaceVariantLight),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(DesignTokens.radiusLarge),
                    topRight: const Radius.circular(DesignTokens.radiusLarge),
                    bottomLeft: Radius.circular(
                      isSentByCurrentUser ? DesignTokens.radiusLarge : 0,
                    ),
                    bottomRight: Radius.circular(
                      isSentByCurrentUser ? 0 : DesignTokens.radiusLarge,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing12,
                  vertical: DesignTokens.spacing12,
                ),
                child: Column(
                  crossAxisAlignment:
                      isSentByCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    if (!isSentByCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: DesignTokens.spacing4,
                        ),
                        child: Text(
                          senderName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            isSentByCurrentUser
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.3,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: DesignTokens.spacing4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  isSentByCurrentUser
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.onPrimary.withOpacity(0.7)
                                      : Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.6),
                            ),
                          ),
                          if (isSentByCurrentUser) ...[
                            const SizedBox(width: 4),
                            Icon(
                              isRead ? Icons.done_all : Icons.done,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withOpacity(0.7),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isSentByCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: DesignTokens.spacing8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: 12,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showMessageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(
              vertical: DesignTokens.spacing16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  child: ListTile(
                    leading: const Icon(Icons.copy),
                    title: const Text('Copy'),
                    onTap: () {
                      // TODO: Implement copy to clipboard
                      Navigator.pop(context);
                    },
                  ),
                ),
                Material(
                  child: ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      onDelete?.call();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
