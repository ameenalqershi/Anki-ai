class ChatModel {
  final String name;
  final String lastMessage;
  final String imageUrl;
  final int unreadCount;
  final bool isOnline;

  ChatModel({
    required this.name,
    required this.lastMessage,
    required this.imageUrl,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}
