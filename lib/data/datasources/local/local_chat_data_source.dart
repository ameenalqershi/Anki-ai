// lib/data/datasources/local_chat_data_source.dart
import 'package:english_mentor_ai2/data/models/chat_model.dart';
import 'package:english_mentor_ai2/data/models/message_model.dart';
import 'package:english_mentor_ai2/domain/repositories/local_chat_data_source.dart';

class LocalChatDataSourceImpl implements LocalChatDataSource {
  final List<MessageModel> _messages = [
    MessageModel(
      id: '1',
      chatId: '55',
      text: 'how are you',
      isMe: false,
      time: '10:25 AM',
      timestamp: DateTime.now(),
    ),
    MessageModel(
      id: '2',
      chatId: '55',
      text: 'am good',
      isMe: true,
      time: '10:25 AM',
      timestamp: DateTime.now(),
    ),
    MessageModel(
      id: '3',
      chatId: '55',
      text: 'what are you doing',
      isMe: false,
      time: '10:26 AM',
      timestamp: DateTime.now(),
    ),
  ];

  @override
  Future<List<MessageModel>> loadMessages({
    required String chatId,
    required int page,
  }) async {
    const pageSize = 20;
    final start = page * pageSize;
    final end = start + pageSize;

    return _messages
        .where((m) => m.chatId == chatId)
        .toList()
        .sublist(start, end > _messages.length ? _messages.length : end);
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
