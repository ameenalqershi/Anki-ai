import 'package:flutter/material.dart';

class TelegramImageViewer extends StatelessWidget {
  final String imageUrl;
  final String senderName;
  final String sentAt; // formatted date/time

  const TelegramImageViewer({
    super.key,
    required this.imageUrl,
    required this.senderName,
    required this.sentAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // الصورة مع إمكانية التكبير والسحب
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stack) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 56,
                    ),
                  );
                },
              ),
            ),
          ),
          // الشريط العلوي العائم
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // زر الرجوع
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // تفاصيل المرسل والوقت
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          senderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black),
                            ],
                          ),
                        ),
                        Text(
                          sentAt,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // قائمة الخيارات
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    color: Colors.grey[900],
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.save_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Save to Gallery',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.collections,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Show All Media',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 3,
                            child: Row(
                              children: const [
                                Icon(Icons.chat, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Show in chat',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 4,
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.reply,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Reply',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      // نفذ العمليات حسب الاختيار (احفظ، اعرض جميع الوسائط، ...)
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
