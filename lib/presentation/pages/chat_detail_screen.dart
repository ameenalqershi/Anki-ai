// lib/presentation/pages/chat_detail_screen.dart
import 'package:english_mentor_ai2/data/models/message_model.dart';
import 'package:english_mentor_ai2/domain/repositories/local_chat_data_source.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:english_mentor_ai2/data/datasources/local/local_chat_data_source.dart';
import 'package:english_mentor_ai2/data/models/chat_model.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final ChatModel chat;

  const ChatDetailScreen({super.key, required this.chatId, required this.chat});

  @override
  ChatDetailScreenState createState() => ChatDetailScreenState();
}

class ChatDetailScreenState extends State<ChatDetailScreen> {
  final LocalChatDataSource _dataSource = LocalChatDataSourceImpl();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  final Map<DateTime, List<MessageModel>> _groupedMessages = {};
  final List<DateTime> _dateSeparators = [];
  int _currentPage = 0;
  bool _hasMoreMessages = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await _loadMessages();
    _organizeMessages();
  }

  Future<void> _loadMessages() async {
    final newMessages = await _dataSource.loadMessages(
      chatId: widget.chat.id,
      page: _currentPage,
    );

    setState(() {
      _messages.addAll(newMessages);
      _hasMoreMessages = newMessages.isNotEmpty;
    });
  }

  void _organizeMessages() {
    _groupedMessages.clear();
    _dateSeparators.clear();

    DateTime? currentDate;
    List<MessageModel> currentGroup = [];

    for (final message in _messages.reversed) {
      final date = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );

      if (date != currentDate) {
        if (currentGroup.isNotEmpty) {
          _groupedMessages[date] = currentGroup;
          _dateSeparators.add(date);
        }
        currentGroup = [];
        currentDate = date;
      }

      if (currentGroup.isEmpty || currentGroup.last.isMe == message.isMe) {
        currentGroup.add(message);
      } else {
        _groupedMessages[date] = currentGroup;
        currentGroup = [message];
      }
    }

    if (currentGroup.isNotEmpty) {
      _groupedMessages[currentDate!] = currentGroup;
      _dateSeparators.add(currentDate);
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMoreMessages) {
      _currentPage++;
      _loadMessages();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now().toLocal();
    final formattedTime = DateFormat('h:mm a').format(now);

    final newMessage = MessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      text: text,
      isMe: true,
      time: formattedTime,
      timestamp: DateTime.now(),
    );

    setState(() => _messages.add(newMessage));
    _messageController.clear();
    _organizeMessages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    await _dataSource.saveMessage(message: newMessage);
  }

  Widget _buildDateDivider(DateTime date) {
    final formattedDate = DateFormat.yMMMd().format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            formattedDate,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageGroup(List<MessageModel> group) {
    final isMe = group.first.isMe;
    final showAvatar = !isMe && group.last == group.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (showAvatar)
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/default_avatar.png'),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children:
                  group.map((message) {
                    final isFirst = message == group.first;
                    final isLast = message == group.last;

                    return Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      margin: EdgeInsets.only(
                        left: isMe ? 40 : (showAvatar ? 8 : 40),
                        right: isMe ? 8 : 40,
                        bottom: 4,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blueAccent : Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isLast ? 16 : 4),
                          bottomRight: Radius.circular(isLast ? 16 : 4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.Hm().format(message.timestamp),
                            style: TextStyle(
                              color: isMe ? Colors.white70 : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _messages.isEmpty
                    ? const Center(child: Text('ابدأ المحادثة الآن'))
                    : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: _dateSeparators.length * 2,
                      itemBuilder: (context, index) {
                        if (index.isOdd) {
                          final dateIndex = index ~/ 2;
                          return _buildDateDivider(_dateSeparators[dateIndex]);
                        }
                        final groupIndex = index ~/ 2;
                        return _buildMessageGroup(
                          _groupedMessages[_dateSeparators[groupIndex]]!,
                        );
                      },
                    ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _handleAttachment,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('حذف المحادثة'),
                onTap: () => _deleteChat(context),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteChat(BuildContext context) async {
    // await _dataSource.deleteChat(widget.chatId);
    // Navigator.pop(context);
    // Navigator.pop(context);
  }

  void _handleAttachment() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('صورة'),
                onTap: () => _sendImage(),
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('ملف'),
                onTap: () => _sendFile(),
              ),
            ],
          ),
    );
  }

  Future<void> _sendImage() async {
    // إضافة منطق اختيار الصورة هنا
  }

  Future<void> _sendFile() async {
    // إضافة منطق اختيار الملف هنا
  }
}
