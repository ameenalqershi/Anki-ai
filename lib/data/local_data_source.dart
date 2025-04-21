import 'package:flutter/material.dart';

enum MessageType { text, image, video, audio, file, voice }

class ChatMessage {
  final String id;
  final String text;
  final String? mediaUrl;
  final MessageType type;
  final bool isMe;
  final DateTime createdAt;
  final bool isDeleted;
  final bool isEdited;
  final bool isPinned;
  final String? replyToMessageId;
  final String? fileName;
  final int? fileSize;

  ChatMessage({
    required this.id,
    required this.text,
    this.mediaUrl,
    this.type = MessageType.text,
    this.isMe = false,
    required this.createdAt,
    this.isDeleted = false,
    this.isEdited = false,
    this.isPinned = false,
    this.replyToMessageId,
    this.fileName,
    this.fileSize,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    String? mediaUrl,
    MessageType? type,
    bool? isMe,
    DateTime? createdAt,
    bool? isDeleted,
    bool? isEdited,
    bool? isPinned,
    String? replyToMessageId,
    String? fileName,
    int? fileSize,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      isMe: isMe ?? this.isMe,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      isPinned: isPinned ?? this.isPinned,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}

class LocalChatDataSource extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  ChatMessage? _pinnedMessage;
  String? _typingUser;
  String? _onlineStatus;
  int? _searchIndex;
  List<int> _searchResults = [];

  bool _hasMore = true;
  bool get hasMore => _hasMore;
  bool _isLoading = false;

  final TextEditingController inputController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  ChatMessage? get pinnedMessage => _pinnedMessage;
  String? get typingUser => _typingUser;
  String? get onlineStatus => _onlineStatus;
  int? get searchIndex => _searchIndex;
  List<int> get searchResults => List.unmodifiable(_searchResults);
  String get statusText => _onlineStatus ?? "";
  bool get isSearching => searchController.text.isNotEmpty;

  void addMessage(ChatMessage msg) {
    _messages.add(msg);
    notifyListeners();
  }

  void deleteMessage(String id) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _messages[idx] = _messages[idx].copyWith(isDeleted: true, text: "");
      notifyListeners();
    }
  }

  void editMessage(String id, String newText) {
    final idx = _messages.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _messages[idx] = _messages[idx].copyWith(text: newText, isEdited: true);
      notifyListeners();
    }
  }

  void pinMessage(String id) {
    final msg = _messages.firstWhere(
      (m) => m.id == id,
      orElse: () => throw Exception("Message not found"),
    );
    _pinnedMessage = msg.copyWith(isPinned: true);
    notifyListeners();
  }

  void unpinMessage() {
    _pinnedMessage = null;
    notifyListeners();
  }

  void setTypingUser(String? user) {
    _typingUser = user;
    notifyListeners();
  }

  void setOnlineStatus(String? status) {
    _onlineStatus = status;
    notifyListeners();
  }

  List<int> searchMessages(String query) {
    _searchResults = [];
    if (query.trim().isEmpty) {
      _searchIndex = null;
      notifyListeners();
      return _searchResults;
    }
    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      if (!msg.isDeleted &&
          ((msg.text.toLowerCase().contains(query.toLowerCase())) ||
              (msg.mediaUrl != null &&
                  msg.mediaUrl!.toLowerCase().contains(query.toLowerCase())) ||
              (msg.fileName != null &&
                  msg.fileName!.toLowerCase().contains(query.toLowerCase())))) {
        _searchResults.add(i);
      }
    }
    _searchIndex = _searchResults.isNotEmpty ? _searchResults.first : null;
    notifyListeners();
    return _searchResults;
  }

  void onSearchTextChanged(String query) {
    searchMessages(query);
  }

  void onSearchPressed() {
    searchMessages(searchController.text);
  }

  void goToNextSearchResult() {
    if (_searchResults.isEmpty) return;
    if (_searchIndex == null) {
      _searchIndex = _searchResults.first;
    } else {
      int pos = _searchResults.indexOf(_searchIndex!);
      pos = (pos + 1) % _searchResults.length;
      _searchIndex = _searchResults[pos];
    }
    notifyListeners();
  }

  void goToPreviousSearchResult() {
    if (_searchResults.isEmpty) return;
    if (_searchIndex == null) {
      _searchIndex = _searchResults.first;
    } else {
      int pos = _searchResults.indexOf(_searchIndex!);
      pos = (pos - 1 + _searchResults.length) % _searchResults.length;
      _searchIndex = _searchResults[pos];
    }
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _searchIndex = null;
    _searchResults = [];
    notifyListeners();
  }

  List<ChatMessage> messagesOfDay(DateTime day) {
    return _messages
        .where(
          (msg) =>
              msg.createdAt.year == day.year &&
              msg.createdAt.month == day.month &&
              msg.createdAt.day == day.day,
        )
        .toList();
  }

  void sendInputMessage({bool isMe = true, VoidCallback? onSend}) {
    final text = inputController.text.trim();
    if (text.isEmpty) return;
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isMe: isMe,
      createdAt: DateTime.now(),
      type: MessageType.text,
    );
    addMessage(msg);
    inputController.clear();
    if (onSend != null) onSend();
  }

  void sendFileMessage({
    required String fileName,
    required int fileSize,
    required String fileUrl,
    bool isMe = true,
  }) {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: fileName,
      fileName: fileName,
      fileSize: fileSize,
      mediaUrl: fileUrl,
      isMe: isMe,
      createdAt: DateTime.now(),
      type: MessageType.file,
    );
    addMessage(msg);
  }

  void sendVoiceMessage({
    required String voiceUrl,
    required int durationMs,
    bool isMe = true,
  }) {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "${(durationMs / 1000).toStringAsFixed(1)} sec",
      mediaUrl: voiceUrl,
      isMe: isMe,
      createdAt: DateTime.now(),
      type: MessageType.voice,
    );
    addMessage(msg);
  }

  /// تحميل أول دفعة: الأقدم في الأعلى، الأحدث في الأسفل
  Future<void> loadInitialMessages() async {
    if (_isLoading) return;
    _isLoading = true;
    await Future.delayed(const Duration(milliseconds: 800));
    _messages.clear();

    final now = DateTime.now();
    for (int i = 0; i < 20; i++) {
      _messages.add(
        ChatMessage(
          id: (1000 + i).toString(),
          text: "رسالة رقم ${i + 1}",
          isMe: i % 2 == 0,
          createdAt: now.subtract(Duration(minutes: (19 - i) * 3)),
          type: MessageType.text,
        ),
      );
    }
    _isLoading = false;
    _hasMore = true;
    notifyListeners();
  }

  /// تحميل المزيد عند السحب للأعلى: أضف الرسائل الأقدم في الأعلى (index 0)
  Future<void> loadMoreMessages() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    await Future.delayed(const Duration(milliseconds: 800));

    final oldest =
        _messages.isNotEmpty ? _messages.first.createdAt : DateTime.now();
    final currentCount = _messages.length;
    List<ChatMessage> older = [];
    for (int i = 0; i < 20; i++) {
      older.add(
        ChatMessage(
          id: (2000 + currentCount + i).toString(),
          text: "رسالة قديمة رقم ${currentCount + i + 1}",
          isMe: (currentCount + i) % 2 == 0,
          createdAt: oldest.subtract(Duration(minutes: (20 - i) * 3)),
          type: MessageType.text,
        ),
      );
    }
    _messages.insertAll(0, older);
    if (_messages.length >= 100) _hasMore = false;
    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _messages.clear();
    _pinnedMessage = null;
    _typingUser = null;
    _onlineStatus = null;
    _searchIndex = null;
    _searchResults = [];
    inputController.clear();
    searchController.clear();
    _hasMore = true;
    _isLoading = false;
    notifyListeners();
  }
}
