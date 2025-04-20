// lib/data/datasources/local/shared_prefs_local_datasource.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/message_model.dart';

abstract class LocalDataSource {
  Future<List<MessageModel>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, MessageModel message);
}

class SharedPrefsLocalDataSource implements LocalDataSource {
  static const _keyPrefix = 'chat_messages_';

  @override
  Future<List<MessageModel>> getMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_keyPrefix$chatId');
    if (jsonString == null) return [];
    final List list = json.decode(jsonString);
    return list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> sendMessage(String chatId, MessageModel message) async {
    final prefs = await SharedPreferences.getInstance();
    final msgs = await getMessages(chatId);
    msgs.insert(0, message);
    final encoded = json.encode(msgs.map((m) => m.toJson()).toList());
    await prefs.setString('$_keyPrefix$chatId', encoded);
  }
}
