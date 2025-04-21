import 'package:english_mentor_ai2/presentation/widgets/reaction_bar.dart';
import 'package:english_mentor_ai2/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_data_source.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/telegram_album_bubble.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  ChatMessage? _replyTo;
  bool _showJumpToBottom = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // تحميل أول دفعة عند الدخول
    Future.microtask(
      () => ref.read(chatProvider.notifier).loadInitialMessages(),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final threshold = 260.0;
    if (_scrollController.offset > threshold && !_showJumpToBottom) {
      setState(() => _showJumpToBottom = true);
    } else if (_scrollController.offset <= threshold && _showJumpToBottom) {
      setState(() => _showJumpToBottom = false);
    }

    // Paging: عند السحب لأعلى
    if (_scrollController.position.pixels <=
            _scrollController.position.minScrollExtent + 40 &&
        !_isLoadingMore &&
        ref.read(chatProvider).hasMore) {
      _isLoadingMore = true;
      ref.read(chatProvider.notifier).loadMoreMessages().then((_) {
        _isLoadingMore = false;
      });
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _onSend(
    String text,
    MessageType type,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    String? replyToId,
    // لن يتم استخدامه مع Riverpod لكن متوافق مع ChatInputBar الحالي
  ) {
    final newMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isMe: true,
      createdAt: DateTime.now(),
      type: type,
      mediaUrl: mediaUrl,
      fileName: fileName,
      fileSize: fileSize,
      replyToMessageId: replyToId,
    );
    ref.read(chatProvider.notifier).sendMessage(newMsg);
    setState(() {
      _replyTo = null;
    });
    Future.delayed(const Duration(milliseconds: 120), _scrollToBottom);
  }

  /// تحليل وتجميع رسائل الصور المتتالية كـBubble واحدة
  List<_BubbleData> buildChatBubbles(List<ChatMessage> messages) {
    final List<_BubbleData> bubbles = [];
    int i = 0;

    while (i < messages.length) {
      final msg = messages[i];

      // إذا كانت رسالة صورة، ابحث عن صور متتالية من نفس المرسل بفارق زمني صغير (60 ثانية)
      if (msg.type == MessageType.image) {
        List<String> albumUrls = [msg.mediaUrl ?? ""];
        int j = i + 1;
        while (j < messages.length &&
            messages[j].type == MessageType.image &&
            messages[j].isMe == msg.isMe &&
            messages[j].createdAt.difference(msg.createdAt).inSeconds.abs() <
                60) {
          albumUrls.add(messages[j].mediaUrl ?? "");
          j++;
        }
        // إذا أكثر من صورة، استخدم TelegramAlbumBubble
        if (albumUrls.length > 1) {
          bubbles.add(
            _BubbleData(
              key: ValueKey('album_${msg.id}'),
              widget: TelegramAlbumBubble(
                imageUrls: albumUrls,
                isMe: msg.isMe,
                bottomWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: msg.isMe ? Colors.white : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    if (msg.isMe)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.done_all,
                          size: 15,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              onSwipe: () => setState(() => _replyTo = msg),
            ),
          );
          i = j;
          continue;
        }
      }

      // الرسائل العادية
      final repliedMsg =
          msg.replyToMessageId != null
              ? messages.firstWhere(
                (m) => m.id == msg.replyToMessageId,
                orElse:
                    () => ChatMessage(
                      id: '',
                      text: '',
                      isMe: false,
                      createdAt: DateTime.now(),
                      type: MessageType.text,
                    ),
              )
              : null;

      bubbles.add(
        _BubbleData(
          key: ValueKey(msg.id),
          widget: ChatMessageBubble(
            msg: msg,
            repliedMsg: repliedMsg,
            onLongPress: () => setState(() => _replyTo = msg),
            onReply: (replyMsg) => setState(() => _replyTo = replyMsg),
            reactionBar: ReactionBar(
              message: msg,
              onAddReaction: (reaction) {
                final userId = "me"; // استبدلها بمعرف المستخدم الحقيقي لديك
                ref
                    .read(chatProvider.notifier)
                    .addReaction(msg.id, reaction, userId);
              },
              onRemoveReaction: (reaction) {
                final userId = "me"; // استبدلها بمعرف المستخدم الحقيقي لديك
                ref
                    .read(chatProvider.notifier)
                    .removeReaction(msg.id, reaction, userId);
              },
            ),
          ),
          onSwipe: () => setState(() => _replyTo = msg),
        ),
      );
      i++;
    }

    return bubbles.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages;
    final bubbles = buildChatBubbles(messages);

    return Scaffold(
      backgroundColor: const Color(0xffe5ebee),
      appBar: AppBar(
        backgroundColor: const Color(0xff63aee1),
        elevation: 1.5,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                "https://i.ibb.co/9tBv1z9/telegram-avatar.png",
              ),
              radius: 18,
            ),
            const SizedBox(width: 12),
            const Text("Alice", style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    key: const PageStorageKey('chat_list'),
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: bubbles.length,
                    itemBuilder: (context, index) {
                      final bubble = bubbles[index];
                      return SwipeTo(
                        onRightSwipe: (details) => bubble.onSwipe(),
                        animationDuration: const Duration(milliseconds: 350),
                        swipeSensitivity: 5,
                        child: bubble.widget,
                      );
                    },
                  ),
                ),
                ChatInputBar(
                  onSend: _onSend,
                  replyTo: _replyTo,
                  onCancelReply: () => setState(() => _replyTo = null),
                ),
              ],
            ),
          ),
          if (_showJumpToBottom)
            Positioned(
              right: 18,
              bottom: 88,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.blueAccent,
                onPressed: _scrollToBottom,
                child: const Icon(Icons.arrow_downward, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// كلاس مساعد لجمع بيانات الفقاعة
class _BubbleData {
  final Key key;
  final Widget widget;
  final VoidCallback onSwipe;
  _BubbleData({required this.key, required this.widget, required this.onSwipe});
}
