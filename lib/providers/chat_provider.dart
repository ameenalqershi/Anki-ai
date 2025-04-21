// import 'package:flutter/material.dart';
// import '../data/sqlite_data_source.dart';
// import '../data/local_data_source.dart';

// class ChatProvider with ChangeNotifier {
//   List<ChatMessage> _messages = [];
//   final SqliteDataSource _db = SqliteDataSource();

//   List<ChatMessage> get messages => _messages;

//   Future<void> loadMessages() async {
//     _messages = await _db.getAllMessages();
//     notifyListeners();
//   }

//   Future<void> sendMessage(ChatMessage msg) async {
//     await _db.upsertMessage(msg);
//     await loadMessages();
//   }

//   Future<void> deleteMessage(String id) async {
//     await _db.deleteMessageById(id);
//     await loadMessages();
//   }

//   void addReaction(String msgId, String reaction, String userId) {
//     _db.addReaction(msgId, reaction, userId);
//     loadMessages();
//   }

//   void removeReaction(String msgId, String reaction, String userId) {
//     _db.removeReaction(msgId, reaction, userId);
//     loadMessages();
//   }

//   // يمكنك إضافة دوال إضافية حسب الحاجة
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sqlite_data_source.dart';
import '../data/local_data_source.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(SqliteDataSource()),
);

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool hasMore;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.hasMore = true,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? hasMore,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final SqliteDataSource _db;
  static const int _pageSize = 30;

  ChatNotifier(this._db) : super(ChatState(messages: [])) {
    loadInitialMessages();
  }

  Future<void> loadInitialMessages() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    final msgs = await _db.getMessages(limit: _pageSize, beforeId: null);
    state = state.copyWith(
      messages: msgs,
      isLoading: false,
      hasMore: msgs.length == _pageSize,
    );
  }

  Future<void> loadMoreMessages() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    final oldestId = state.messages.isNotEmpty ? state.messages.first.id : null;
    final older = await _db.getMessages(limit: _pageSize, beforeId: oldestId);
    state = state.copyWith(
      messages: [...older, ...state.messages],
      isLoading: false,
      hasMore: older.length == _pageSize,
    );
  }

  Future<void> sendMessage(ChatMessage msg) async {
    // إضافة الرسالة مباشرة للواجهة
    state = state.copyWith(messages: [...state.messages, msg]);
    // الحفظ في القاعدة (بدون انتظار)
    _db.upsertMessage(msg);
  }

  Future<void> editMessage(ChatMessage msg) async {
    final idx = state.messages.indexWhere((m) => m.id == msg.id);
    if (idx == -1) return;
    final updated = [...state.messages];
    updated[idx] = msg;
    state = state.copyWith(messages: updated);
    _db.upsertMessage(msg);
  }

  Future<void> deleteMessage(String id) async {
    final idx = state.messages.indexWhere((m) => m.id == id);
    if (idx == -1) return;
    final updated = [...state.messages];
    updated[idx] = updated[idx].copyWith(isDeleted: true, text: "");
    state = state.copyWith(messages: updated);
    _db.deleteMessageById(id);
  }

  Future<void> addReaction(String msgId, String emoji, String userId) async {
    final idx = state.messages.indexWhere((m) => m.id == msgId);
    if (idx == -1) return;
    final msg = state.messages[idx];
    final reactions = Map<String, List<String>>.from(msg.reactions);
    reactions.putIfAbsent(emoji, () => []);
    if (!reactions[emoji]!.contains(userId)) {
      reactions[emoji]!.add(userId);
      final updatedMsg = msg.copyWith(reactions: reactions);
      final updated = [...state.messages];
      updated[idx] = updatedMsg;
      state = state.copyWith(messages: updated);
      _db.upsertMessage(updatedMsg);
    }
  }

  Future<void> removeReaction(String msgId, String emoji, String userId) async {
    final idx = state.messages.indexWhere((m) => m.id == msgId);
    if (idx == -1) return;
    final msg = state.messages[idx];
    if (!msg.reactions.containsKey(emoji)) return;
    final reactions = Map<String, List<String>>.from(msg.reactions);
    reactions[emoji]!.remove(userId);
    if (reactions[emoji]!.isEmpty) reactions.remove(emoji);
    final updatedMsg = msg.copyWith(reactions: reactions);
    final updated = [...state.messages];
    updated[idx] = updatedMsg;
    state = state.copyWith(messages: updated);
    _db.upsertMessage(updatedMsg);
  }
}
