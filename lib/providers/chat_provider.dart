import 'package:flutter/material.dart';
import '../data/sqlite_data_source.dart';
import '../data/local_data_source.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  final SqliteDataSource _db = SqliteDataSource();

  List<ChatMessage> get messages => _messages;

  Future<void> loadMessages() async {
    _messages = await _db.getAllMessages();
    notifyListeners();
  }

  Future<void> sendMessage(ChatMessage msg) async {
    await _db.upsertMessage(msg);
    await loadMessages();
  }

  Future<void> deleteMessage(String id) async {
    await _db.deleteMessageById(id);
    await loadMessages();
  }

  void addReaction(String msgId, String reaction, String userId) {
    _db.addReaction(msgId, reaction, userId);
    loadMessages();
  }

  void removeReaction(String msgId, String reaction, String userId) {
    _db.removeReaction(msgId, reaction, userId);
    loadMessages();
  }

  // يمكنك إضافة دوال إضافية حسب الحاجة
}
