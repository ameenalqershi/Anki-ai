import 'package:flutter/material.dart';

enum MessageType { text, image, video, audio, file, voice, code, system }

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
  final String? replyTo;

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
    this.replyTo,
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
    String? replyTo,
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
      replyTo: replyTo ?? this.replyTo,
    );
  }
}

class LocalChatDataSource extends ChangeNotifier {
  final List<ChatMessage> messages;
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

  ChatMessage? get pinnedMessage => _pinnedMessage;
  String? get typingUser => _typingUser;
  String? get onlineStatus => _onlineStatus;
  int? get searchIndex => _searchIndex;
  List<int> get searchResults => List.unmodifiable(_searchResults);
  String get statusText => _onlineStatus ?? "متصل الآن";
  bool get isSearching => searchController.text.isNotEmpty;

  LocalChatDataSource._(this.messages);

  factory LocalChatDataSource.demo() {
    final now = DateTime.now();
    return LocalChatDataSource._([
      ChatMessage(
        id: "sys1",
        text: "تم تفعيل ميزة إرسال الصور والصوتيات!",
        isMe: false,
        createdAt: now.subtract(const Duration(minutes: 30)),
        type: MessageType.system,
      ),
      ChatMessage(
        id: "msg1",
        text: "مرحباً بك في محادثة العينة 🎉",
        isMe: false,
        createdAt: now.subtract(const Duration(minutes: 28)),
        type: MessageType.text,
      ),
      // صور مجمعة لمستخدم واحد
      ChatMessage(
        id: "img1",
        text: "",
        mediaUrl:
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
        isMe: true,
        createdAt: now.subtract(const Duration(minutes: 27)),
        type: MessageType.image,
      ),
      ChatMessage(
        id: "img2",
        text: "",
        mediaUrl:
            "https://images.unsplash.com/photo-1519125323398-675f0ddb6308",
        isMe: true,
        createdAt: now.subtract(const Duration(minutes: 27)),
        type: MessageType.image,
      ),
      ChatMessage(
        id: "img3",
        text: "",
        mediaUrl:
            "https://images.unsplash.com/photo-1465101046530-73398c7f28ca",
        isMe: true,
        createdAt: now.subtract(const Duration(minutes: 27)),
        type: MessageType.image,
      ),
      // صورة منفصلة
      ChatMessage(
        id: "img4",
        text: "",
        mediaUrl:
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
        isMe: false,
        createdAt: now.subtract(const Duration(minutes: 25)),
        type: MessageType.image,
      ),
      // رسالة صوتية
      ChatMessage(
        id: "voice1",
        text: "",
        mediaUrl:
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        isMe: false,
        createdAt: now.subtract(const Duration(minutes: 24)),
        type: MessageType.voice,
      ),
      // رسالة فيديو
      ChatMessage(
        id: "vid1",
        text: "",
        mediaUrl:
            "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
        isMe: true,
        createdAt: now.subtract(const Duration(minutes: 23)),
        type: MessageType.video,
      ),
      // رسالة ملف
      ChatMessage(
        id: "file1",
        text: "",
        fileName: "وثيقة.pdf",
        fileSize: 204800,
        isMe: false,
        createdAt: now.subtract(const Duration(minutes: 22)),
        type: MessageType.file,
      ),
      // رسالة كود برمجي
      ChatMessage(
        id: "code1",
        text: "```dart\nvoid main() {\n  print('Hello, World!');\n}\n```",
        isMe: false,
        createdAt: now.subtract(const Duration(minutes: 21)),
        type: MessageType.code,
      ),
      // رسالة نصية طويلة
      ChatMessage(
        id: "longtext",
        text:
            "هذه رسالة نصية طويلة للاختبار. الهدف منها التأكد من عرض الرسائل الطويلة بشكل صحيح دون مشاكل.",
        isMe: true,
        createdAt: now.subtract(const Duration(minutes: 20)),
        type: MessageType.text,
      ),
      // رسالة رد
      ChatMessage(
        id: "reply1",
        text: "👍 شكراً على الرسالة السابقة!",
        isMe: false,
        createdAt: now.subtract(const Duration(minutes: 19)),
        type: MessageType.text,
        replyTo: "longtext",
      ),
    ]);
  }

  void addMessage(ChatMessage msg) {
    messages.add(msg);
    notifyListeners();
  }

  void deleteMessage(String id) {
    final idx = messages.indexWhere((m) => m.id == id);
    if (idx != -1) {
      messages[idx] = messages[idx].copyWith(isDeleted: true, text: "");
      notifyListeners();
    }
  }

  void editMessage(String id, String newText) {
    final idx = messages.indexWhere((m) => m.id == id);
    if (idx != -1) {
      messages[idx] = messages[idx].copyWith(text: newText, isEdited: true);
      notifyListeners();
    }
  }

  void pinMessage(String id) {
    final msg = messages.firstWhere(
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
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
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
    return messages
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
    messages.clear();

    final now = DateTime.now();
    for (int i = 0; i < 20; i++) {
      messages.add(
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
        messages.isNotEmpty ? messages.first.createdAt : DateTime.now();
    final currentCount = messages.length;
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
    messages.insertAll(0, older);
    if (messages.length >= 100) _hasMore = false;
    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    messages.clear();
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
