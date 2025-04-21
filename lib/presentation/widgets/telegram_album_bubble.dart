import 'package:flutter/material.dart';

// استورد العارض الخاص بك
import 'telegram_image_viewer.dart';

class TelegramAlbumBubble extends StatelessWidget {
  final List<String> imageUrls;
  final bool isMe;
  final Widget? bottomWidget;

  const TelegramAlbumBubble({
    super.key,
    required this.imageUrls,
    required this.isMe,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls.take(4).toList();
    const double albumSize = 206;
    const double gap = 1.5;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          gradient:
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
                  ),
          borderRadius: BorderRadius.only(
            topLeft:
                isMe ? const Radius.circular(18) : const Radius.circular(4),
            topRight:
                isMe ? const Radius.circular(4) : const Radius.circular(18),
            bottomLeft: const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 13,
              offset: const Offset(1, 5),
            ),
          ],
        ),
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          right: isMe ? 8 : 48,
          left: isMe ? 48 : 8,
        ),
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: albumSize,
              width: albumSize,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildImage(
                      context,
                      urls[0],
                      radius: BorderRadius.only(
                        topLeft:
                            isMe
                                ? const Radius.circular(13)
                                : const Radius.circular(18),
                        bottomLeft: const Radius.circular(18),
                        topRight: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                      imageIndex: 0,
                      allUrls: urls,
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: List.generate(3, (i) {
                        if (urls.length <= i + 1) return const SizedBox();
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: i != 2 ? gap : 0),
                            child: _buildImage(
                              context,
                              urls[i + 1],
                              radius: BorderRadius.only(
                                topRight:
                                    isMe
                                        ? const Radius.circular(4)
                                        : const Radius.circular(18),
                                topLeft: Radius.zero,
                                bottomLeft: Radius.zero,
                                bottomRight:
                                    i == 2
                                        ? (isMe
                                            ? const Radius.circular(7)
                                            : const Radius.circular(18))
                                        : Radius.zero,
                              ),
                              imageIndex: i + 1,
                              allUrls: urls,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            if (bottomWidget != null) ...[
              const SizedBox(height: 5),
              bottomWidget!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImage(
    BuildContext context,
    String url, {
    BorderRadius? radius,
    required int imageIndex,
    required List<String> allUrls,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => TelegramImageViewer(
                  imageUrl: url,
                  senderName: '', // يمكنك تمرير اسم المرسل هنا إذا توفّر
                  sentAt: '', // ويمكنك تمرير الوقت إذا توفّر
                  // لمزيد من التطوير: يمكنك تمرير قائمة الصور وأندكس الحالي لدعم ألبوم الصور
                ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 1),
              ),
            );
          },
          errorBuilder:
              (context, error, stackTrace) => Container(
                color: Colors.grey,
                child: const Icon(Icons.broken_image),
              ),
        ),
      ),
    );
  }
}
