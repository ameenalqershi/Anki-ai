class Message {
  final String text;
  final bool isMe;
  final String time;
  final bool isImage;
  final bool isFile;

  Message({
    required this.text,
    required this.isMe,
    required this.time,
    this.isImage = false,
    this.isFile = false,
  });
}