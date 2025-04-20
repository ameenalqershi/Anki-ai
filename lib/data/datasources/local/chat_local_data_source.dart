// lib/data/datasources/local/chat_local_data_source.dart
import 'package:hive/hive.dart';
import '../../models/chat_model.dart';

abstract class ChatLocalDataSource {
  List<ChatModel> getChats();
  Future<void> saveChat(ChatModel chat);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final Box<ChatModel> _chatsBox;

  ChatLocalDataSourceImpl(this._chatsBox);

  @override
  List<ChatModel> getChats() => _chatsBox.values.toList();

  @override
  Future<void> saveChat(ChatModel chat) => _chatsBox.add(chat);
}