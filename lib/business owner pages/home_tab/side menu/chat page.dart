import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String senderUserId; // Current user ID
  final String recipientUserId; // ID of the user you're chatting with
  final Map<String, dynamic> recipientUserData;

  const ChatPage({
    Key? key,
    required this.senderUserId,
    required this.recipientUserId,
    required this.recipientUserData,
    required Map<String, dynamic> userData,
    required String conversationId,
    required String userId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.recipientUserData['username'] ?? 'Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(widget.recipientUserId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> messageData =
                          document.data() as Map<String, dynamic>;
                      return MessageBubble(messageData: messageData);
                    }).toList(),
                  );
                }
              },
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    // Send message logic
                    String message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      // Add message to the recipient user's document under 'messages' subcollection
                      FirebaseFirestore.instance
                          .collection('User')
                          .doc(widget.recipientUserId) // Recipient user ID
                          .collection('messages')
                          .add({
                        'text': message,
                        'senderId': widget.senderUserId, // Sender user ID
                        'timestamp': DateTime.now(),
                      });
                      // Clear the input field
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> messageData;

  const MessageBubble({Key? key, required this.messageData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCurrentUser =
        messageData['senderId'] == FirebaseAuth.instance.currentUser?.uid;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            messageData['text'],
            style: TextStyle(
              color: isCurrentUser ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

// Generate a unique conversation ID using UUID
String generateConversationId(String userId1, String userId2) {
  // Sort user IDs alphabetically to ensure consistency
  List<String> sortedUserIds = [userId1, userId2]..sort();
  // Concatenate sorted user IDs to generate a unique conversation ID
  String conversationId = sortedUserIds.join('_');
  // Generate a UUID to make the conversation ID unique
  String uuid = Uuid().v4();
  return '$conversationId' + '_$uuid'; // Add underscore before uuid
}
