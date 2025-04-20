// lib/domain/repositories/chat_repository.dart

import '../../data/models/message_model.dart';

abstract class ChatRepository {
  Future<List<MessageModel>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, MessageModel message);
}
