import 'package:english_mentor_ai2/presentation/widgets/chat_grouped_images.dart';
import 'package:flutter/material.dart';
import 'chat_message_bubble.dart';
// import 'chat_grouped_images.dart'; // غير مستخدم حالياً
import 'package:english_mentor_ai2/data/local_data_source.dart' as data;

class ChatMessagesList extends StatelessWidget {
  final data.LocalChatDataSource dataSource;
  const ChatMessagesList({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    // تقسيم الرسائل بحسب الصور أو نصوص (grouping)
    final grouped = groupImageMessages(dataSource.messages);

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: grouped.length,
      itemBuilder: (ctx, idx) {
        final group = grouped[grouped.length - 1 - idx];

        // رسائل نصية أو صوتية إلخ (فقاعة منفردة)
        if (group.length == 1 && group.first.type != data.MessageType.image) {
          return RepaintBoundary(
            key: ValueKey('msg_${group.first.id}'), // مفتاح فريد للرسالة
            child: ChatMessageBubble(msg: group.first),
          );
        }
        // مجموعة صور (ألبوم صور)
        else if (group.length >= 1 &&
            group.first.type == data.MessageType.image) {
          // مفتاح فريد للألبوم
          return RepaintBoundary(
            key: ValueKey('img_album_${group.first.id}'),
            // ملاحظة: ChatGroupedImagesBubble غير مستخدم حالياً حسب كلامك
            child: Column(
              children:
                  group.map((imgMsg) {
                    return ChatMessageBubble(
                      key: ValueKey('msg_${imgMsg.id}'),
                      msg: imgMsg,
                    );
                  }).toList(),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ========== ملاحظة =========
// إذا فعلاً لا تستخدم ChatGroupedImagesBubble، عُدّل أعلاه لعرض كل صورة كفقاعة مستقلة.
// لو كنت ستستخدم grouping مستقبلاً، أعِد تفعيل الكود الأصلي.
