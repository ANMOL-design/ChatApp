import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (ctx, snapshot) {
          // Loading Data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // App has no Data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No Messages Found.'),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Oops! Something went wrong.'),
            );
          }

          final messages = snapshot.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 32,
                left: 12,
                right: 12,
              ),
              reverse: true, // its like flex-wrap: 'wrap-reverse'
              itemCount: messages.length,
              itemBuilder: (ctx, index) {
                final chatMessage = messages[index].data();
                final nextChatMessage = index + 1 < messages.length
                    ? messages[index + 1].data()
                    : null;

                final currentMessageUserId = chatMessage['userId'];
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;

                final nextUserIsSame =
                    nextMessageUserId == currentMessageUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                    message: chatMessage['message'],
                    isMe: authUser.uid == currentMessageUserId,
                  );
                } else {
                  return MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['userName'],
                    message: chatMessage['message'],
                    isMe: authUser.uid == currentMessageUserId,
                  );
                }
              });
        });
  }
}
