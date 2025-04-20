// lib/data/datasources/local/message_local_data_source.dart
import 'package:hive/hive.dart';
import '../../models/message_model.dart';

abstract class MessageLocalDataSource {
  List<MessageModel> getMessages(String chatId);
  Future<void> sendMessage(MessageModel message);
}

class MessageLocalDataSourceImpl implements MessageLocalDataSource {
  final Box<MessageModel> _messagesBox;

  MessageLocalDataSourceImpl(this._messagesBox);

  @override
  List<MessageModel> getMessages(String chatId) => 
      _messagesBox.values.where((msg) => msg.chatId == chatId).toList();

  @override
  Future<void> sendMessage(MessageModel message) => _messagesBox.add(message);
}