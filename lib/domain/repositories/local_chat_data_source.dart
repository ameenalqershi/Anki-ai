import 'package:english_mentor_ai2/data/models/chat_model.dart';
import 'package:english_mentor_ai2/data/models/message_model.dart';

abstract class LocalChatDataSource {
  Future<List<MessageModel>> loadMessages({
    required String chatId,
    required int page,
  });

  Future<void> saveMessage({required MessageModel message});

  Future<void> deleteChat(String chatId);
}
