import 'package:flutter/material.dart';
import 'chat_message_bubble.dart';
import 'chat_grouped_images.dart';
import 'package:english_mentor_ai2/data/local_data_source.dart' as data;
import 'package:english_mentor_ai2/presentation/widgets/chat_grouped_images.dart';

class ChatMessagesList extends StatelessWidget {
  final data.LocalChatDataSource dataSource;
  const ChatMessagesList({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    // استخدم AnimatedList أو أي Widget تريده
    final grouped = groupImageMessages(dataSource.messages);
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: grouped.length,
      itemBuilder: (ctx, idx) {
        final group = grouped[grouped.length - 1 - idx];
        if (group.length == 1 && group.first.type != data.MessageType.image) {
          return RepaintBoundary(
            key: ValueKey(group.first.id),
            child: ChatMessageBubble(msg: group.first),
          );
        } else if (group.length >= 1 &&
            group.first.type == data.MessageType.image) {
          // استخدم أول معرف صورة كمفتاح للمجموعة
          return RepaintBoundary(
            key: ValueKey('img_album_${group.first.id}'),
            child: ChatGroupedImagesBubble(
              images: group,
              isMe: group.first.isMe,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
