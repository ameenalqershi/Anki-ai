class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String imageUrl;
  final int unreadCount;
  final bool isOnline;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.imageUrl,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:grouped_list/grouped_list.dart';
// import 'package:intl/intl.dart';
// import 'package:swipe_to/swipe_to.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';

// import '../../data/models/message_model.dart';
// import '../../data/models/chat_model.dart';
// import '../../injector.dart';
// import '../../domain/repositories/chat_repository.dart';

// class ChatDetailScreen extends StatefulWidget {
//   final ChatModel chat;
//   const ChatDetailScreen(this.chat, {Key? key}) : super(key: key);

//   @override
//   _ChatDetailScreenState createState() => _ChatDetailScreenState();
// }

// class _ChatDetailScreenState extends State<ChatDetailScreen> {
//   final List<MessageModel> _messages = [];
//   late List<MessageModel> _allMessageModels;
//   final TextEditingController _controller = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   bool _showAttachments = false;
//   late ScrollController _scrollController;

//   // Pagination variables
//   final int _pageSize = 20;
//   int _currentPage = 0;
//   bool _isLoadingMore = false;

//   // Repository
//   final ChatRepository _chatRepo = getIt<ChatRepository>();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _scrollController.addListener(_onScroll);
//     _loadMessageModels();
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (!_isLoadingMore &&
//         _scrollController.position.extentAfter < 200 &&
//         _allMessageModels.length > _messages.length) {
//       _loadMoreMessageModels();
//     }
//   }

//   Future<void> _loadMessageModels() async {
//     final msgs = await _chatRepo.getMessages(widget.chat.name);
//     setState(() {
//       _allMessageModels = msgs;
//       _messages.clear();
//       _currentPage = 0;
//       _messages.addAll(_allMessageModels.take(_pageSize));
//     });
//   }

//   void _loadMoreMessageModels() {
//     _isLoadingMore = true;
//     final start = (_currentPage + 1) * _pageSize;
//     final additional = _allMessageModels.skip(start).take(_pageSize).toList();
//     if (additional.isNotEmpty) {
//       setState(() {
//         _messages.addAll(additional);
//         _currentPage++;
//       });
//     }
//     _isLoadingMore = false;
//   }

//   Future<void> _sendMessageModel(String text,
//       {bool isImage = false, bool isFile = false}) async {
//     final now = DateTime.now().toLocal();
//     final formattedTime = DateFormat('h:mm a').format(now);
//     final msg = MessageModel(
//       text: text,
//       isMe: true,
//       time: formattedTime,
//       isImage: isImage,
//       isFile: isFile,
//     );
//     await _chatRepo.sendMessage(widget.chat.name, msg);
//     setState(() {
//       _allMessageModels.insert(0, msg);
//       _messages.insert(0, msg);
//     });
//     _controller.clear();
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final XFile? image = await _picker.pickImage(source: source);
//     if (image != null) {
//       _sendMessageModel(image.path, isImage: true);
//     }
//   }

//   Future<void> _pickFile() async {
//     final result = await FilePicker.platform.pickFiles();
//     if (result != null && result.files.single.path != null) {
//       _sendMessageModel(result.files.single.path!, isFile: true);
//     }
//   }

//   Widget _buildMessageModel(MessageModel message) {
//     return SwipeTo(
//       onRightSwipe: (details) => _showMessageModelOptions(message),
//       child: Align(
//         alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: message.isMe ? Colors.blue.shade100 : Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (message.isImage)
//                 Image.file(File(message.text), width: 200, height: 150)
//               else if (message.isFile)
//                 _buildFileMessageModel(message.text)
//               else
//                 Text(message.text),
//               const SizedBox(height: 4),
//               Text(
//                 message.time,
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontSize: 10,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFileMessageModel(String path) {
//     return Row(
//       children: [
//         const Icon(Icons.insert_drive_file, color: Colors.blue),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('ملف مرفق', style: TextStyle(color: Colors.blue.shade800)),
//               Text(path.split('/').last, style: const TextStyle(fontSize: 12)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   void _showMessageModelOptions(MessageModel message) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.reply),
//             title: const Text('رد'),
//             onTap: () => Navigator.pop(context),
//           ),
//           ListTile(
//             leading: const Icon(Icons.forward),
//             title: const Text('إعادة توجيه'),
//             onTap: () => Navigator.pop(context),
//           ),
//           ListTile(
//             leading: const Icon(Icons.delete, color: Colors.red),
//             title: const Text('حذف', style: TextStyle(color: Colors.red)),
//             onTap: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageModelInput() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           if (_showAttachments) _buildAttachmentsMenu(),
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(
//                   _showAttachments ? Icons.close : Icons.add_circle_outline,
//                   color: Colors.blue,
//                 ),
//                 onPressed: () => setState(() => _showAttachments = !_showAttachments),
//               ),
//               Expanded(
//                 child: TextField(
//                   controller: _controller,
//                   decoration: InputDecoration(
//                     hintText: 'اكتب رسالة...',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(24),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                   ),
//                   maxLines: 5,
//                   minLines: 1,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.send, color: Colors.blue),
//                 onPressed: () {
//                   if (_controller.text.isNotEmpty) {
//                     _sendMessageModel(_controller.text);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttachmentsMenu() {
//     return Container(
//       height: 100,
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         children: [
//           _buildAttachmentOption(
//             icon: Icons.photo_library,
//             label: 'المعرض',
//             onTap: () => _pickImage(ImageSource.gallery),
//           ),
//           _buildAttachmentOption(
//             icon: Icons.camera_alt,
//             label: 'الكاميرا',
//             onTap: () => _pickImage(ImageSource.camera),
//           ),
//           _buildAttachmentOption(
//             icon: Icons.attach_file,
//             label: 'ملف',
//             onTap: _pickFile,
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: CachedNetworkImageProvider(widget.chat.imageUrl),
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.chat.name),
//                 Text(
//                   'متصل الآن',
//                   style: TextStyle(fontSize: 12, color: Colors.green),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
//           IconButton(icon: const Icon(Icons.call), onPressed: () {}),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GroupedListView<MessageModel, String>(
//               elements: _messages,
//               groupBy: (message) {
//                 DateTime dateTime;
//                 try {
//                   dateTime = DateFormat('h:mm a').parse(message.time);
//                 } catch (_) {
//                   dateTime = DateTime.parse(message.time);
//                 }
//                 return DateFormat('yyyy-MM-dd').format(dateTime);
//               },
//               groupSeparatorBuilder: (String date) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Center(
//                   child: Text(
//                     DateFormat.yMMMd().format(DateTime.parse(date)),
//                     style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//               itemBuilder: (context, message) => _buildMessageModel(message),
//               order: GroupedListOrder.DESC,
//               useStickyGroupSeparators: true,
//               floatingHeader: false,
//               reverse: true,
//               controller: _scrollController,
//             ),
//           ),
//           _buildMessageModelInput(),
//         ],
//       ),
//     );
//   }
// }
