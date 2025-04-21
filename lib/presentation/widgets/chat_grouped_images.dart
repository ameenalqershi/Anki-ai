import 'package:flutter/material.dart';
import 'package:english_mentor_ai2/data/local_data_source.dart';
import 'media_viewer.dart';

// يمكنك نقل groupImageMessages إلى ملف مساعد
List<List<ChatMessage>> groupImageMessages(List<ChatMessage> messages) {
  List<List<ChatMessage>> grouped = [];
  List<ChatMessage> temp = [];
  for (var i = 0; i < messages.length; i++) {
    var m = messages[i];
    if (m.type == MessageType.image) {
      temp.add(m);
      bool isLast = i == messages.length - 1;
      var next = !isLast ? messages[i + 1] : null;
      bool nextImageSameSender =
          next != null &&
          next.type == MessageType.image &&
          next.isMe == m.isMe &&
          (next.createdAt.difference(m.createdAt).inMinutes).abs() < 7;
      if (!nextImageSameSender) {
        grouped.add(List.from(temp));
        temp.clear();
      }
    } else {
      if (temp.isNotEmpty) {
        grouped.add(List.from(temp));
        temp.clear();
      }
      grouped.add([m]);
    }
  }
  if (temp.isNotEmpty) grouped.add(List.from(temp));
  return grouped;
}

Widget _imageItem(BuildContext ctx, ChatMessage msg, List<ChatMessage> images) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: GestureDetector(
      onTap:
          () => Navigator.of(ctx).push(
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
      child: Image.network(
        msg.mediaUrl ?? "",
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    ),
  );
}

class ChatGroupedImagesBubble extends StatelessWidget {
  final List<ChatMessage> images;
  final bool isMe;
  const ChatGroupedImagesBubble({
    super.key,
    required this.images,
    required this.isMe,
  });
  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
    );
    Widget imageGrid;
    final count = images.length;
    if (count == 2) {
      imageGrid = Row(
        children: [
          Expanded(child: _imageItem(context, images[0], images)),
          const SizedBox(width: 2),
          Expanded(child: _imageItem(context, images[1], images)),
        ],
      );
    } else if (count == 3) {
      imageGrid = Row(
        children: [
          Expanded(child: _imageItem(context, images[0], images)),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _imageItem(context, images[1], images)),
                const SizedBox(height: 2),
                Expanded(child: _imageItem(context, images[2], images)),
              ],
            ),
          ),
        ],
      );
    } else if (count == 4) {
      imageGrid = Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(child: _imageItem(context, images[0], images)),
                const SizedBox(height: 2),
                Expanded(child: _imageItem(context, images[2], images)),
              ],
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _imageItem(context, images[1], images)),
                const SizedBox(height: 2),
                Expanded(child: _imageItem(context, images[3], images)),
              ],
            ),
          ),
        ],
      );
    } else if (count >= 5) {
      imageGrid = Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(child: _imageItem(context, images[0], images)),
                const SizedBox(height: 2),
                Expanded(child: _imageItem(context, images[3], images)),
              ],
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _imageItem(context, images[1], images)),
                      const SizedBox(width: 2),
                      Expanded(child: _imageItem(context, images[2], images)),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child:
                      count > 5
                          ? Stack(
                            children: [
                              _imageItem(context, images[4], images),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '+${count - 5}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : _imageItem(context, images[4], images),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      imageGrid = _imageItem(context, images[0], images);
    }
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        left: isMe ? 60 : 0,
        right: isMe ? 0 : 60,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xff63aee1) : Colors.white,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: SizedBox(height: 200, child: imageGrid),
    );
  }
}
