// class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
//   @override
//   final int typeId = 0;

//   @override
//   ChatMessage read(BinaryReader reader) {
//     return ChatMessage(
//       id: reader.read(),
//       chatId: reader.read(),
//       text: reader.read(),
//       isMe: reader.read(),
//       timestamp: reader.read(),
//       attachmentPath: reader.read(),
//     );
//   }

//   @override
//   void write(BinaryWriter writer, ChatMessage obj) {
//     writer.write(obj.id);
//     writer.write(obj.chatId);
//     writer.write(obj.text);
//     writer.write(obj.isMe);
//     writer.write(obj.timestamp);
//     writer.write(obj.attachmentPath);
//   }
// }
