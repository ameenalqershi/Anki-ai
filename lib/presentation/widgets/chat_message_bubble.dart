import 'package:flutter/material.dart';
import '../../data/local_data_source.dart';
import 'audio_player_widget.dart';
import 'gallery_grid.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final ChatMessage? repliedMsg;
  final VoidCallback? onLongPress;
  final Function(ChatMessage)? onReply;

  const ChatMessageBubble({
    super.key,
    required this.msg,
    this.repliedMsg,
    this.onLongPress,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMe = msg.isMe; // عرّفه هنا فقط
    // تلجرام: حواف الفقاعة وتدرج اللون
    final Gradient gradient =
        isMe
            ? const LinearGradient(
              colors: [Color(0xff6ec6ff), Color(0xff2196f3)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            )
            : const LinearGradient(
              colors: [Colors.white, Color(0xfff1f1f1)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            );

    final textColor = isMe ? Colors.white : Colors.black87;

    BorderRadius borderRadius = BorderRadius.only(
      topLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
      topRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
      bottomLeft: const Radius.circular(18),
      bottomRight: const Radius.circular(18),
    );

    // --- محتوى الفقاعة حسب النوع ---
    Widget content;
    if (msg.type == MessageType.text) {
      content = Text(
        msg.text,
        style: TextStyle(fontSize: 16, color: textColor),
      );
    } else if (msg.type == MessageType.image &&
        msg.mediaUrl != null &&
        msg.mediaUrl!.contains(',')) {
      // مجموعة صور (ألبوم)
      final images = msg.mediaUrl!.split(',');
      content = GalleryGrid(images: images);
    } else if (msg.type == MessageType.image && msg.mediaUrl != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          msg.mediaUrl!,
          width: 210,
          height: 210,
          fit: BoxFit.cover,
        ),
      );
    } else if (msg.type == MessageType.voice && msg.mediaUrl != null) {
      content = AudioPlayerWidget(url: msg.mediaUrl!);
    } else if (msg.type == MessageType.file) {
      content = Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.blue),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              msg.fileName ?? "ملف",
              style: TextStyle(color: textColor),
            ),
          ),
          if (msg.fileSize != null)
            Text(
              " ${(msg.fileSize! / 1024).toStringAsFixed(1)} KB",
              style: TextStyle(color: textColor, fontSize: 12),
            ),
        ],
      );
    } else if (msg.type == MessageType.code) {
      content = Container(
        color: Colors.black.withOpacity(0.07),
        padding: const EdgeInsets.all(7),
        margin: const EdgeInsets.only(top: 3),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            msg.text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13.5),
          ),
        ),
      );
    } else {
      content = Text(
        msg.text,
        style: TextStyle(fontSize: 16, color: textColor),
      );
    }

    // --- عرض الرد (reply) تلجرام ستايل ---
    Widget? replyWidget;
    if (repliedMsg != null && repliedMsg!.id.isNotEmpty) {
      replyWidget = GestureDetector(
        onTap: () => onReply?.call(repliedMsg!),
        child: Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[100] : Colors.grey[200],
            border: Border(
              right: BorderSide(
                color: isMe ? Colors.blue : Colors.green,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  repliedMsg!.text.isNotEmpty
                      ? repliedMsg!.text.length > 40
                          ? repliedMsg!.text.substring(0, 37) + "..."
                          : repliedMsg!.text
                      : "<${_typeLabel(repliedMsg!.type)}>",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- التفاعلات (ردود أفعال) على الرسالة ---
    Widget reactions =
        msg.reactions != null && msg.reactions!.isNotEmpty
            ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                children:
                    msg.reactions!
                        .map(
                          (e) => Text(e, style: const TextStyle(fontSize: 18)),
                        )
                        .toList(),
              ),
            )
            : const SizedBox.shrink();

    // --- الهيكل النهائي للفقاعة ---
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: EdgeInsets.only(
              top: 10,
              left: isMe ? 54 : 10,
              right: isMe ? 10 : 54,
            ),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 13,
                  offset: const Offset(1, 5),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: borderRadius,
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (replyWidget != null) replyWidget,
                    content,
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 11.5,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.done_all, size: 15, color: Colors.white70),
                        ],
                      ],
                    ),
                    reactions,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _typeLabel(MessageType type) {
    switch (type) {
      case MessageType.voice:
        return "صوت";
      case MessageType.image:
        return "صورة";
      case MessageType.video:
        return "فيديو";
      case MessageType.file:
        return "ملف";
      case MessageType.code:
        return "كود";
      case MessageType.system:
        return "نظام";
      default:
        return "";
    }
  }
}
