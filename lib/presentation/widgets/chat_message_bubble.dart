import 'package:flutter/material.dart';
import 'package:english_mentor_ai2/data/local_data_source.dart';
import 'audio_player_widget.dart';
import 'media_viewer.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final ChatMessage? replyTo;
  const ChatMessageBubble({super.key, required this.msg, this.replyTo});

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe;
    final color = isMe ? const Color(0xff63aee1) : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    Widget content;

    if (msg.type == MessageType.text || msg.type == MessageType.code) {
      content = Text(
        msg.text,
        style: TextStyle(
          fontSize: msg.type == MessageType.code ? 15 : 16,
          color: textColor,
          fontFamily: msg.type == MessageType.code ? 'monospace' : null,
          backgroundColor:
              msg.type == MessageType.code
                  ? (isMe ? Colors.blue[700] : Colors.grey[200])
                  : null,
          height: 1.5,
        ),
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
                        MediaItem(url: msg.mediaUrl!, type: MediaType.video),
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
            msg.fileSize != null
                ? "${(msg.fileSize! / 1024).toStringAsFixed(1)} KB"
                : "",
            style: TextStyle(color: textColor, fontSize: 13),
          ),
        ],
      );
    } else {
      content = const SizedBox.shrink();
    }

    Widget? replyWidget;
    if (replyTo != null) {
      replyWidget = Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isMe ? Colors.white24 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: isMe ? Colors.white : Colors.blue,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.reply, size: 16, color: Colors.blueGrey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                replyTo!.text.isNotEmpty
                    ? replyTo!.text
                    : replyTo!.type == MessageType.image
                    ? "📷 صورة"
                    : replyTo!.type == MessageType.voice
                    ? "🔊 رسالة صوتية"
                    : replyTo!.type == MessageType.file
                    ? "📎 ملف"
                    : replyTo!.type == MessageType.code
                    ? "كود برمجي"
                    : "رد",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isMe ? Colors.white70 : Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
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
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [if (replyWidget != null) replyWidget, content],
            ),
          ),
        ),
      ],
    );
  }
}
