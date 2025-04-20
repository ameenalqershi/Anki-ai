// lib/data/repositories/chat_repository_impl.dart

import '../../domain/repositories/chat_repository.dart';
import '../../data/models/message_model.dart';
import '../datasources/local/shared_prefs_local_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final LocalDataSource localDataSource;
  ChatRepositoryImpl(this.localDataSource);

  @override
  Future<List<MessageModel>> getMessages(String chatId) =>
      localDataSource.getMessages(chatId);

  @override
  Future<void> sendMessage(String chatId, MessageModel message) =>
      localDataSource.sendMessage(chatId, message);
}
