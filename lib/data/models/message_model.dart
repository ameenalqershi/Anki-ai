// lib/data/models/message_model.dart

class MessageModel {
  final String id;
  final String chatId;
  final String text;
  final bool isMe;
  final String time;
  final DateTime timestamp;
  final bool isImage;
  final bool isFile;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.text,
    required this.isMe,
    required this.time,
    required this.timestamp,
    this.isImage = false,
    this.isFile = false,
  });

  // ← إضافة:
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      text: json['text'] as String,
      isMe: json['isMe'] as bool,
      time: json['time'] as String,
      timestamp: json['timestamp'] as DateTime,
      isImage: json['isImage'] as bool? ?? false,
      isFile: json['isFile'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'text': text,
    'isMe': isMe,
    'time': time,
    'timestamp': timestamp,
    'isImage': isImage,
    'isFile': isFile,
  };
}
