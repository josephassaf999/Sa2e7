import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Message model for type-safe chat data
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  // Create from Firestore document
  factory ChatMessage.fromMap(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }
}

/// Chat conversation model
class ChatConversation {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatConversation.fromMap(String id, Map<String, dynamic> data) {
    return ChatConversation(
      id: id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(
        data['participantNames'] ?? {},
      ),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }
}

/// Centralized messaging service for all Firestore chat operations
class MessagingService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static const String _chatsCollection = 'chats';
  static const String _messagesSubcollection = 'messages';

  /// Generate unique chat ID from two user IDs (ensures consistency)
  static String generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Create or get existing chat between two users
  static Future<String> getOrCreateChat({
    required String otherUserId,
    required String otherUserName,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final chatId = generateChatId(currentUser.uid, otherUserId);
    final chatRef = _firestore.collection(_chatsCollection).doc(chatId);

    // Check if chat exists
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      // Create new chat
      final currentUserName =
          currentUser.displayName ?? currentUser.email ?? 'User';

      await chatRef.set({
        'participantIds': [currentUser.uid, otherUserId],
        'participantNames': {
          currentUser.uid: currentUserName,
          otherUserId: otherUserName,
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  /// Send a message in a chat
  static Future<void> sendMessage({
    required String chatId,
    required String message,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    if (message.trim().isEmpty) {
      throw Exception('Message cannot be empty');
    }

    final senderName = currentUser.displayName ?? currentUser.email ?? 'User';
    final timestamp = DateTime.now();

    // Add message to subcollection
    await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesSubcollection)
        .add({
          'senderId': currentUser.uid,
          'senderName': senderName,
          'text': message,
          'timestamp': timestamp,
          'isRead': false,
        });

    // Update chat's last message
    await _firestore.collection(_chatsCollection).doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': timestamp,
    });
  }

  /// Get messages stream for a chat
  static Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    return _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesSubcollection)
        .orderBy('timestamp', descending: true)
        .limit(50) // Load latest 50 messages
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// Get all conversations for current user
  static Stream<List<ChatConversation>> getConversationsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.empty();
    }

    return _firestore
        .collection(_chatsCollection)
        .where('participantIds', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatConversation.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// Mark message as read
  static Future<void> markMessageAsRead(String chatId, String messageId) async {
    try {
      await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .collection(_messagesSubcollection)
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      // Silently fail - not critical
    }
  }

  /// Delete a message (only by sender)
  static Future<void> deleteMessage(
    String chatId,
    String messageId,
    String senderId,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != senderId) {
      throw Exception('Only message sender can delete');
    }

    await _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesSubcollection)
        .doc(messageId)
        .delete();
  }

  /// Get unread message count for current user across all chats
  static Future<int> getUnreadCount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return 0;

    try {
      final chats =
          await _firestore
              .collection(_chatsCollection)
              .where('participantIds', arrayContains: currentUser.uid)
              .get();

      int totalUnread = 0;

      for (final chatDoc in chats.docs) {
        final unreadMessages =
            await _firestore
                .collection(_chatsCollection)
                .doc(chatDoc.id)
                .collection(_messagesSubcollection)
                .where('senderId', isNotEqualTo: currentUser.uid)
                .where('isRead', isEqualTo: false)
                .count()
                .get();

        totalUnread += unreadMessages.count!;
      }

      return totalUnread;
    } catch (e) {
      return 0;
    }
  }

  /// Block a user (prevents them from messaging you)
  static Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('Users').doc(currentUser.uid).update({
      'blockedUsers': FieldValue.arrayUnion([userId]),
    });
  }

  /// Unblock a user
  static Future<void> unblockUser(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('Users').doc(currentUser.uid).update({
      'blockedUsers': FieldValue.arrayRemove([userId]),
    });
  }

  /// Check if user is blocked
  static Future<bool> isUserBlocked(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final doc =
          await _firestore.collection('Users').doc(currentUser.uid).get();

      final blockedUsers = List<String>.from(doc.data()?['blockedUsers'] ?? []);
      return blockedUsers.contains(userId);
    } catch (e) {
      return false;
    }
  }
}
