import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MediaViewer extends StatefulWidget {
  final List<MediaItem> items;
  final int initialIndex;
  const MediaViewer({required this.items, this.initialIndex = 0, Key? key})
    : super(key: key);

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  late int _current;
  VideoPlayerController? _videoController;
  final mediaStore = MediaStore();

  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    if (_isVideo(widget.items[_current])) {
      _initVideo(widget.items[_current].url);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  bool _isVideo(MediaItem item) => item.type == MediaType.video;

  Future<void> _initVideo(String url) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(url);
    await _videoController!.initialize();
    setState(() {});
  }

  void _onPageChanged(int idx) async {
    setState(() => _current = idx);
    if (_isVideo(widget.items[idx])) {
      await _initVideo(widget.items[idx].url);
    } else {
      _videoController?.dispose();
      _videoController = null;
    }
  }

  Future<void> _saveMedia() async {
    final item = widget.items[_current];
    if (_isVideo(item)) {
      // حفظ الفيديو (يمكنك تنفيذ منطق مشابه لحفظ الفيديو)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حفظ الفيديو غير مدعوم حاليًا")),
      );
    } else {
      try {
        // 1. تنزيل الصورة من الإنترنت
        final response = await http.get(Uri.parse(item.url));
        if (response.statusCode == 200) {
          // 2. حفظ الصورة في ملف مؤقت
          final tempDir = await getTemporaryDirectory();
          final fileName = "image_${DateTime.now().millisecondsSinceEpoch}.jpg";
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);

          // 3. حفظ الصورة في المعرض باستخدام media_store_plus
          final result = await mediaStore.saveFile(
            tempFilePath: file.path,
            dirType: DirType.photo,
            relativePath: "Pictures/MyApp",
            dirName: DirName.pictures,
          );
          if (result?.isSuccessful ?? false) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("تم حفظ الصورة!")));
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("فشل حفظ الصورة!")));
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("فشل تحميل الصورة!")));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطأ: $e")));
      }
    }
  }

  void _shareMedia() async {
    final item = widget.items[_current];
    await Share.share(item.url, subject: "مشاركة وسائط");
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_current];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "${_current + 1}/${widget.items.length}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _saveMedia),
          IconButton(icon: const Icon(Icons.share), onPressed: _shareMedia),
        ],
      ),
      body: PageView.builder(
        key: const PageStorageKey('media_viewer_pageview'),
        itemCount: widget.items.length,
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (ctx, idx) {
          final media = widget.items[idx];
          if (_isVideo(media)) {
            if (_videoController == null ||
                !_videoController!.value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_videoController!),
                    if (!_videoController!.value.isPlaying)
                      IconButton(
                        icon: const Icon(
                          Icons.play_circle,
                          color: Colors.white,
                          size: 64,
                        ),
                        onPressed:
                            () => setState(() => _videoController!.play()),
                      ),
                    if (_videoController!.value.isPlaying)
                      IconButton(
                        icon: const Icon(
                          Icons.pause_circle,
                          color: Colors.white,
                          size: 64,
                        ),
                        onPressed:
                            () => setState(() => _videoController!.pause()),
                      ),
                  ],
                ),
              ),
            );
          } else {
            // عارض صور بالسحب (PhotoView)
            return PhotoViewGallery(
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: _pageController,
              onPageChanged: _onPageChanged,
              pageOptions:
                  widget.items
                      .where((el) => el.type == MediaType.image)
                      .map(
                        (img) => PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(img.url),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                          // استخدام مفتاح فريد لتقليل إعادة البناء
                          heroAttributes: PhotoViewHeroAttributes(
                            tag: 'image_${img.url}',
                          ),
                        ),
                      )
                      .toList(),
              loadingBuilder:
                  (ctx, event) =>
                      const Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

enum MediaType { image, video }

class MediaItem {
  final String url;
  final MediaType type;
  MediaItem({required this.url, required this.type});
}
