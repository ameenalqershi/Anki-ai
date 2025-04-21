import 'package:flutter/material.dart';
import 'package:english_mentor_ai2/data/local_data_source.dart';
import 'audio_player_widget.dart';
import 'media_viewer.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage msg;
  // final LocalChatDataSource dataSource;
  const ChatMessageBubble({
    super.key,
    required this.msg,
    // required this.dataSource,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe;
    final color = isMe ? const Color(0xff63aee1) : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    Widget content;
    if (msg.type == MessageType.text) {
      content = Text(
        msg.text,
        style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
      );
    } else if (msg.type == MessageType.voice) {
      content = AudioPlayerWidget(url: msg.mediaUrl!);
    } else if (msg.type == MessageType.video) {
      content = GestureDetector(
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => MediaViewer(
                      items: [
                        MediaItem(
                          url: msg.mediaUrl!,
                          type:
                              msg.type == MessageType.video
                                  ? MediaType.video
                                  : MediaType.image,
                        ),
                      ],
                      initialIndex: 0,
                    ),
              ),
            ),
        child: Container(
          width: 180,
          height: 120,
          color: Colors.black12,
          child: const Center(
            child: Icon(
              Icons.play_circle_fill,
              size: 48,
              color: Colors.deepPurple,
            ),
          ),
        ),
      );
    } else if (msg.type == MessageType.file) {
      content = Row(
        children: [
          const Icon(Icons.description, color: Colors.orange, size: 24),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              msg.fileName ?? "ملف",
              style: TextStyle(fontSize: 15, color: textColor),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            msg.fileSize?.toString() ?? "",
            style: TextStyle(color: textColor, fontSize: 13),
          ),
        ],
      );
    } else {
      content = const SizedBox.shrink();
    }
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.only(
              top: 8,
              left: isMe ? 60 : 8,
              right: isMe ? 8 : 60,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ],
    );
  }
}
