// lib/data/datasources/local_chat_data_source.dart
import 'package:english_mentor_ai2/data/models/chat_model.dart';
import 'package:english_mentor_ai2/data/models/message_model.dart';
import 'package:english_mentor_ai2/domain/repositories/local_chat_data_source.dart';

class LocalChatDataSourceImpl implements LocalChatDataSource {
  final List<MessageModel> _messages = [];

  LocalChatDataSourceImpl() {
    // Generate dummy data
    final now = DateTime.now();
    for (int i = 0; i < 50; i++) {
      _messages.add(
        MessageModel(
          id: i.toString(),
          text: 'how are you ${i + 1}',
          isMe: i % 3 == 0,
          timestamp: now.subtract(Duration(hours: i)),
          chatId: '55',
          time: '10:20 AM',
        ),
      );
    }
  }

  @override
  Future<List<MessageModel>> loadMessages({
    required String chatId,
    required int page,
  }) async {
    const pageSize = 20;
    final start = page * pageSize;
    final end = start + pageSize;

    final filtered =
        _messages
            .where((m) => m.chatId == chatId)
            .toList()
            .reversed // ترتيب من الأحدث إلى الأقدم
            .toList();

    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  @override
  Future<void> saveMessage({required MessageModel message}) async {
    _messages.add(message);
  }

  @override
  Future<void> deleteChat(String chatId) async {
    _messages.removeWhere((m) => m.chatId == chatId);
  }
}
  // Future<List<Map<String, dynamic>>> loadMoreMessages({
  //   required String chatId,
  //   required int offset,
  // }) async {
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   return List.generate(10, (index) => _createDummyMessage(offset + index));
  // }

  // Future<void> sendMessage({
  //   required String chatId,
  //   required String text,
  // }) async {
  //   await Future.delayed(const Duration(milliseconds: 300));
  //   _messages.add({
  //     'id': DateTime.now().millisecondsSinceEpoch.toString(),
  //     'text': text,
  //     'isMe': true,
  //     'timestamp': DateTime.now(),
  //   });
  // }

  // Map<String, dynamic> _createDummyMessage(int index) {
  //   return {
  //     'id': index.toString(),
  //     'text': 'Message $index',
  //     'isMe': index % 2 == 0,
  //     'timestamp': DateTime.now().subtract(Duration(hours: index)),
  //   };
  // }
