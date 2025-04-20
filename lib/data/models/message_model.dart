// lib/data/models/message_model.dart

class MessageModel {
  final String text;
  final bool isMe;
  final String time;
  final bool isImage;
  final bool isFile;

  MessageModel({
    required this.text,
    required this.isMe,
    required this.time,
    this.isImage = false,
    this.isFile = false,
  });

  // ← إضافة:
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      text: json['text'] as String,
      isMe: json['isMe'] as bool,
      time: json['time'] as String,
      isImage: json['isImage'] as bool? ?? false,
      isFile: json['isFile'] as bool? ?? false,
    );
  }

  get chatId => null;

  Map<String, dynamic> toJson() => {
        'text': text,
        'isMe': isMe,
        'time': time,
        'isImage': isImage,
        'isFile': isFile,
      };
}
