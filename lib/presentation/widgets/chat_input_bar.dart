import 'package:flutter/material.dart';
import 'package:english_mentor_ai2/data/local_data_source.dart';

class ChatInputBar extends StatelessWidget {
  final LocalChatDataSource dataSource;
  final VoidCallback? onSend;
  const ChatInputBar({Key? key, required this.dataSource, this.onSend})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
            onPressed: () {
              dataSource.sendInputMessage();
              if (onSend != null) onSend!();
            },
          ),
          Expanded(
            child: TextField(
              controller: dataSource.inputController,
              minLines: 1,
              maxLines: 4,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: "اكتب رسالة...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (_) => dataSource.sendInputMessage(),
            ),
          ),
          GestureDetector(
            onTap: dataSource.sendInputMessage,
            child: CircleAvatar(
              backgroundColor: const Color(0xff63aee1),
              radius: 22,
              child: const Icon(Icons.send, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
