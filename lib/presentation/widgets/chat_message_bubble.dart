import 'package:english_mentor_ai2/data/local_data_source.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'telegram_image_viewer.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final ChatMessage? repliedMsg;
  final VoidCallback? onLongPress;
  final Function(ChatMessage)? onReply;
  final Widget? reactionBar;

  const ChatMessageBubble({
    super.key,
    required this.msg,
    this.repliedMsg,
    this.onLongPress,
    this.onReply,
    this.reactionBar,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe;

    EdgeInsets bubbleMargin = EdgeInsets.only(
      top: 4,
      bottom: 4,
      left: isMe ? 40 : 8,
      right: isMe ? 8 : 40,
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: bubbleMargin,
        child: RepaintBoundary(
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onLongPress: onLongPress,
                child: _buildByType(context),
              ),
              if (reactionBar != null)
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child:
                      null, // سيتم استبدال null بـ reactionBar! في السطر التالي
                ),
              if (reactionBar != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: reactionBar!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildByType(BuildContext context) {
    switch (msg.type) {
      case MessageType.text:
        return _buildTelegramTextBubble(context);
      case MessageType.image:
        if (msg.mediaUrl != null && msg.mediaUrl!.isNotEmpty) {
          return _buildTelegramImageBubble(context);
        }
        return _buildTelegramTextBubble(context); // fallback if no URL
      case MessageType.voice:
        return _buildVoiceBubble(context);
      case MessageType.video:
        return _buildVideoBubble(context);
      case MessageType.file:
        return _buildFileBubble(context);
      default:
        return _buildTelegramTextBubble(context);
    }
  }

  /// =========== TEXT BUBBLE (TELEGRAM STYLE) ===========
  Widget _buildTelegramTextBubble(BuildContext context) {
    final isMe = msg.isMe;
    final bubbleColor = isMe ? const Color(0xffe0f6fd) : Colors.white;

    BorderRadius bubbleRadius = BorderRadius.only(
      topLeft: isMe ? const Radius.circular(12) : const Radius.circular(18),
      topRight: isMe ? const Radius.circular(18) : const Radius.circular(12),
      bottomLeft: const Radius.circular(18),
      bottomRight: const Radius.circular(18),
    );

    return Container(
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: bubbleRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (repliedMsg != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _buildReplySnippet(context),
            ),
          Text(
            msg.text,
            style: const TextStyle(fontSize: 16, height: 1.4),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 6),
          _buildBubbleMeta(),
        ],
      ),
    );
  }

  /// =========== SINGLE IMAGE BUBBLE (TELEGRAM STYLE) ===========
  Widget _buildTelegramImageBubble(BuildContext context) {
    return Column(
      crossAxisAlignment:
          msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => TelegramImageViewer(
                      imageUrl: msg.mediaUrl!,
                      senderName: msg.isMe ? "You" : msg.sender ?? "",
                      sentAt: _formatSentAt(msg.createdAt),
                    ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 270,
                maxHeight: 340,
                minWidth: 120,
                minHeight: 120,
              ),
              child: CachedNetworkImage(
                imageUrl: msg.mediaUrl!,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      color: Colors.grey[200],
                      height: 180,
                      width: 240,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 1),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey,
                      height: 180,
                      width: 240,
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _buildBubbleMeta(isImage: true),
      ],
    );
  }

  /// =========== VOICE BUBBLE ===========
  Widget _buildVoiceBubble(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: msg.isMe ? const Color(0xffe0f6fd) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow, color: Colors.blue[400]),
          const SizedBox(width: 8),
          const Text("Voice message", style: TextStyle(fontSize: 15)),
          const SizedBox(width: 10),
          Text(
            _formatDuration(const Duration(seconds: 8)),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// =========== VIDEO BUBBLE ===========
  Widget _buildVideoBubble(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: msg.isMe ? const Color(0xffe0f6fd) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam, color: Colors.blue[400]),
          const SizedBox(width: 8),
          const Text("Video message", style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  /// =========== FILE BUBBLE ===========
  Widget _buildFileBubble(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: msg.isMe ? const Color(0xffe0f6fd) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file, color: Colors.blue[400]),
          const SizedBox(width: 10),
          Text(msg.fileName ?? "File", style: const TextStyle(fontSize: 15)),
          if (msg.fileSize != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                _formatFileSize(msg.fileSize!),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  /// =========== REPLY SNIPPET ===========
  Widget _buildReplySnippet(BuildContext context) {
    final replyColor = Colors.grey[200];
    return Container(
      decoration: BoxDecoration(
        color: replyColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        repliedMsg?.text ?? "",
        style: const TextStyle(fontSize: 13, color: Colors.black87),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// =========== BUBBLE META (TIME, STATUS) ===========
  Widget _buildBubbleMeta({bool isImage = false}) {
    final metaStyle = TextStyle(fontSize: 12, color: Colors.grey[600]);
    final time =
        "${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}";
    return Padding(
      padding: EdgeInsets.only(
        top: isImage ? 0 : 1,
        right: msg.isMe ? 2 : 0,
        left: msg.isMe ? 0 : 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(time, style: metaStyle),
          if (msg.isMe) ...[
            const SizedBox(width: 4),
            Icon(Icons.done_all, size: 15, color: Colors.blue[400]),
          ],
        ],
      ),
    );
  }

  /// =========== HELPERS ===========
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final min = twoDigits(duration.inMinutes.remainder(60));
    final sec = twoDigits(duration.inSeconds.remainder(60));
    return "$min:$sec";
  }

  String _formatSentAt(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} at "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
