// import 'package:english_mentor_ai2/data/local_data_source.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart' as intl;
// import 'dart:async';

// // --------- شاشة دردشة تلجرام متقدمة بكل الميزات المطلوبة --------- //
// class TelegramChatScreen extends StatefulWidget {
//   const TelegramChatScreen({Key? key}) : super(key: key);

//   @override
//   State<TelegramChatScreen> createState() => _TelegramChatScreenState();
// }

// class _TelegramChatScreenState extends State<TelegramChatScreen> {
//   final LocalChatDataSource dataSource = LocalChatDataSource();
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _controller = TextEditingController();

//   MessageType _inputType = MessageType.text;
//   String? _inputMediaUrl;
//   String? _inputFileName;
//   String? _inputFileSize;
//   ChatMessage? _replyTo;
//   ChatMessage? _selectedMessage;
//   bool _showJumpToBottom = false;
//   bool _fetchingMore = false;
//   bool _firstLoad = true;

//   // رموز تفاعل افتراضية
//   final List<String> _reactions = [
//     '👍',
//     '😂',
//     '❤️',
//     '🔥',
//     '😮',
//     '😢',
//     '👏',
//     '🤔',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadFirstPage();
//     _scrollController.addListener(_onScroll);
//   }

//   Future<void> _loadFirstPage() async {
//     await dataSource.loadInitialMessages();
//     setState(() => _firstLoad = false);
//   }

//   void _onScroll() {
//     // تحميل تدريجي عند الاقتراب من الأعلى
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 120 &&
//         dataSource.hasMore &&
//         !_fetchingMore) {
//       _fetchingMore = true;
//       dataSource.loadMoreMessages().then((_) {
//         _fetchingMore = false;
//       });
//     }
//     // شارة "رسالة جديدة" عند التصفح للأعلى
//     if (_scrollController.position.pixels > 180) {
//       if (!_showJumpToBottom) setState(() => _showJumpToBottom = true);
//     } else {
//       if (_showJumpToBottom) setState(() => _showJumpToBottom = false);
//       dataSource.resetNewMessageIndicator();
//     }
//   }

//   void _jumpToBottom() {
//     _scrollController.animateTo(
//       0,
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeOut,
//     );
//     dataSource.resetNewMessageIndicator();
//   }

//   void _onSend() async {
//     if (_inputType == MessageType.text && _controller.text.trim().isEmpty)
//       return;
//     await dataSource.sendMessage(
//       text: _controller.text,
//       type: _inputType,
//       mediaUrl: _inputMediaUrl,
//       fileName: _inputFileName,
//       fileSize: _inputFileSize,
//       repliedToId: _replyTo?.id,
//     );
//     setState(() {
//       _controller.clear();
//       _inputType = MessageType.text;
//       _inputMediaUrl = null;
//       _inputFileName = null;
//       _inputFileSize = null;
//       _replyTo = null;
//     });
//     Future.delayed(const Duration(milliseconds: 100), _jumpToBottom);
//     Feedback.forTap(context);
//   }

//   void _onReply(ChatMessage msg) => setState(() => _replyTo = msg);

//   void _onForward(ChatMessage msg) async {
//     await dataSource.forwardMessage(msg.id);
//     _jumpToBottom();
//   }

//   void _onReaction(ChatMessage msg, String emoji) {
//     dataSource.addReaction(msg.id, emoji);
//   }

//   void _onDelete(ChatMessage msg) {
//     dataSource.removeMessage(msg.id);
//     if (_selectedMessage?.id == msg.id) setState(() => _selectedMessage = null);
//   }

//   void _onLongPress(ChatMessage msg) {
//     setState(() => _selectedMessage = msg);
//     showModalBottomSheet(
//       context: context,
//       builder:
//           (ctx) => SafeArea(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.reply),
//                   title: const Text('رد'),
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _onReply(msg);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.forward),
//                   title: const Text('إعادة توجيه'),
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _onForward(msg);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.emoji_emotions),
//                   title: const Text('تفاعل'),
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _showReactions(msg);
//                   },
//                 ),
//                 if (msg.isMe)
//                   ListTile(
//                     leading: const Icon(Icons.delete, color: Colors.red),
//                     title: const Text(
//                       'حذف',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                     onTap: () {
//                       Navigator.pop(ctx);
//                       _onDelete(msg);
//                     },
//                   ),
//                 ListTile(
//                   leading: const Icon(Icons.copy),
//                   title: const Text('نسخ النص'),
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     Clipboard.setData(ClipboardData(text: msg.text));
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('تم نسخ الرسالة!')),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   void _showReactions(ChatMessage msg) {
//     showDialog(
//       context: context,
//       builder:
//           (ctx) => AlertDialog(
//             title: const Text("اختر تفاعل"),
//             content: Wrap(
//               spacing: 12,
//               children:
//                   _reactions
//                       .map(
//                         (r) => GestureDetector(
//                           onTap: () {
//                             Navigator.pop(ctx);
//                             _onReaction(msg, r);
//                           },
//                           child: Text(r, style: const TextStyle(fontSize: 28)),
//                         ),
//                       )
//                       .toList(),
//             ),
//           ),
//     );
//   }

//   Widget _buildReplyBar() {
//     if (_replyTo == null) return const SizedBox.shrink();
//     return Container(
//       margin: const EdgeInsets.only(bottom: 6),
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//       decoration: BoxDecoration(
//         color: Colors.lightBlueAccent.withOpacity(0.09),
//         border: Border(
//           right: BorderSide(color: Colors.lightBlueAccent.shade700, width: 4),
//         ),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               _replyTo!.text.isNotEmpty
//                   ? (_replyTo!.text.length > 70
//                       ? _replyTo!.text.substring(0, 66) + "..."
//                       : _replyTo!.text)
//                   : _replyTo!.type == MessageType.voice
//                   ? "رسالة صوتية"
//                   : _replyTo!.type == MessageType.image
//                   ? "صورة"
//                   : _replyTo!.type == MessageType.video
//                   ? "فيديو"
//                   : _replyTo!.type == MessageType.file
//                   ? "ملف"
//                   : "",
//               style: const TextStyle(fontSize: 13, color: Colors.black87),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close, size: 20, color: Colors.red),
//             onPressed: () => setState(() => _replyTo = null),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputBar() {
//     bool canSend =
//         _inputType == MessageType.text
//             ? _controller.text.trim().isNotEmpty
//             : true;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       color: Colors.white,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildReplyBar(),
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(
//                   Icons.emoji_emotions_outlined,
//                   color: Colors.grey,
//                 ),
//                 onPressed: () {},
//               ),
//               Expanded(
//                 child:
//                     _inputType == MessageType.text
//                         ? TextField(
//                           controller: _controller,
//                           minLines: 1,
//                           maxLines: 4,
//                           textDirection: TextDirection.rtl,
//                           decoration: const InputDecoration(
//                             hintText: "اكتب رسالة...",
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.symmetric(vertical: 8),
//                           ),
//                           onSubmitted: (_) => _onSend(),
//                         )
//                         : _buildMediaPreview(),
//               ),
//               GestureDetector(
//                 onTap: canSend ? _onSend : null,
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   curve: Curves.easeIn,
//                   child: CircleAvatar(
//                     backgroundColor:
//                         canSend
//                             ? const Color(0xff63aee1)
//                             : Colors.grey.shade300,
//                     radius: 22,
//                     child: Icon(
//                       Icons.send,
//                       color: canSend ? Colors.white : Colors.grey,
//                       size: 22,
//                     ),
//                   ),
//                 ),
//               ),
//               PopupMenuButton(
//                 icon: const Icon(Icons.attach_file, color: Colors.blueAccent),
//                 itemBuilder:
//                     (context) => [
//                       PopupMenuItem(
//                         value: 'image',
//                         child: const Text('إرسال صورة'),
//                       ),
//                       PopupMenuItem(
//                         value: 'video',
//                         child: const Text('إرسال فيديو'),
//                       ),
//                       PopupMenuItem(
//                         value: 'voice',
//                         child: const Text('إرسال صوت'),
//                       ),
//                       PopupMenuItem(
//                         value: 'file',
//                         child: const Text('إرسال ملف'),
//                       ),
//                     ],
//                 onSelected: (v) async {
//                   // مثال توضيحي بسيط لمعاينة الوسائط
//                   if (v == 'image') {
//                     setState(() {
//                       _inputType = MessageType.image;
//                       _inputMediaUrl =
//                           "https://placehold.co/300x200?text=صورة+جديدة";
//                     });
//                   } else if (v == 'video') {
//                     setState(() {
//                       _inputType = MessageType.video;
//                       _inputMediaUrl =
//                           "https://sample-videos.com/video123/mp4/240/big_buck_bunny_240p_1mb.mp4";
//                     });
//                   } else if (v == 'voice') {
//                     setState(() {
//                       _inputType = MessageType.voice;
//                       _inputMediaUrl = "voice_sample.mp3";
//                     });
//                   } else if (v == 'file') {
//                     setState(() {
//                       _inputType = MessageType.file;
//                       _inputMediaUrl =
//                           "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
//                       _inputFileName = "ملف.pdf";
//                       _inputFileSize = "1MB";
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMediaPreview() {
//     // معاينة الوسائط قبل الإرسال
//     if (_inputType == MessageType.image) {
//       return Row(
//         children: [
//           Image.network(
//             _inputMediaUrl!,
//             width: 60,
//             height: 60,
//             fit: BoxFit.cover,
//           ),
//           const SizedBox(width: 6),
//           IconButton(
//             icon: const Icon(Icons.close, color: Colors.red),
//             onPressed:
//                 () => setState(() {
//                   _inputType = MessageType.text;
//                   _inputMediaUrl = null;
//                 }),
//           ),
//         ],
//       );
//     } else if (_inputType == MessageType.video) {
//       return Row(
//         children: [
//           Icon(Icons.videocam, color: Colors.deepPurple, size: 38),
//           const SizedBox(width: 5),
//           const Text("معاينة فيديو (تجريبي)"),
//           IconButton(
//             icon: const Icon(Icons.close, color: Colors.red),
//             onPressed:
//                 () => setState(() {
//                   _inputType = MessageType.text;
//                   _inputMediaUrl = null;
//                 }),
//           ),
//         ],
//       );
//     } else if (_inputType == MessageType.voice) {
//       return Row(
//         children: [
//           Icon(Icons.mic, color: Colors.teal, size: 32),
//           const SizedBox(width: 5),
//           const Text("معاينة صوت (تجريبي)"),
//           IconButton(
//             icon: const Icon(Icons.close, color: Colors.red),
//             onPressed:
//                 () => setState(() {
//                   _inputType = MessageType.text;
//                   _inputMediaUrl = null;
//                 }),
//           ),
//         ],
//       );
//     } else if (_inputType == MessageType.file) {
//       return Row(
//         children: [
//           Icon(Icons.description, color: Colors.orange, size: 32),
//           const SizedBox(width: 5),
//           Text(_inputFileName ?? "ملف"),
//           const SizedBox(width: 5),
//           Text(_inputFileSize ?? ""),
//           IconButton(
//             icon: const Icon(Icons.close, color: Colors.red),
//             onPressed:
//                 () => setState(() {
//                   _inputType = MessageType.text;
//                   _inputMediaUrl = null;
//                   _inputFileName = null;
//                   _inputFileSize = null;
//                 }),
//           ),
//         ],
//       );
//     }
//     return const SizedBox.shrink();
//   }

//   Widget _buildMessageBubble(
//     ChatMessage msg,
//     ChatMessage? prev,
//     ChatMessage? next,
//     int index,
//   ) {
//     final isMe = msg.isMe;
//     final groupedPrev =
//         prev != null &&
//         prev.sender == msg.sender &&
//         prev.timestamp.difference(msg.timestamp).inMinutes.abs() < 7;
//     final groupedNext =
//         next != null &&
//         next.sender == msg.sender &&
//         next.timestamp.difference(msg.timestamp).inMinutes.abs() < 7;
//     final showAvatar = !groupedNext;
//     final isSelected = _selectedMessage?.id == msg.id;
//     final isReply = msg.repliedToId != null;

//     BorderRadius borderRadius = BorderRadius.only(
//       topLeft: const Radius.circular(16),
//       topRight: const Radius.circular(16),
//       bottomLeft:
//           isMe
//               ? const Radius.circular(16)
//               : groupedNext
//               ? const Radius.circular(6)
//               : const Radius.circular(4),
//       bottomRight:
//           isMe
//               ? groupedNext
//                   ? const Radius.circular(6)
//                   : const Radius.circular(4)
//               : const Radius.circular(16),
//     );

//     Color bubbleColor = isMe ? const Color(0xff63aee1) : Colors.white;
//     Color textColor = isMe ? Colors.white : Colors.black87;
//     Color bubbleHighlight =
//         isSelected
//             ? (isMe
//                 ? Colors.lightBlueAccent.withOpacity(0.35)
//                 : Colors.orangeAccent.withOpacity(0.21))
//             : Colors.transparent;

//     // خط جانبي إذا كان رد
//     final replyColor = isMe ? Colors.lightGreen : Colors.blueAccent;

//     Widget content;
//     if (msg.type == MessageType.text) {
//       content = Text(
//         msg.text,
//         style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
//       );
//     } else if (msg.type == MessageType.image) {
//       content = ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Image.network(
//           msg.mediaUrl!,
//           width: 180,
//           height: 180,
//           fit: BoxFit.cover,
//         ),
//       );
//     } else if (msg.type == MessageType.video) {
//       content = Column(
//         children: [
//           Container(
//             width: 180,
//             height: 120,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.black12,
//             ),
//             child: Center(
//               child: Icon(
//                 Icons.play_circle_fill,
//                 size: 48,
//                 color: Colors.deepPurple,
//               ),
//             ),
//           ),
//           const SizedBox(height: 6),
//           const Text("معاينة فيديو تجريبية", style: TextStyle(fontSize: 13)),
//         ],
//       );
//     } else if (msg.type == MessageType.voice) {
//       content = Row(
//         children: [
//           Icon(
//             Icons.mic,
//             color: isMe ? Colors.white : Colors.lightBlue,
//             size: 20,
//           ),
//           const SizedBox(width: 5),
//           // شريط تقدم وهمي
//           Expanded(
//             child: Slider(
//               value: 0.3,
//               onChanged: (_) {},
//               min: 0,
//               max: 1,
//               activeColor: isMe ? Colors.white : Colors.lightBlue,
//               inactiveColor: Colors.grey.shade300,
//             ),
//           ),
//           const Text("0:12", style: TextStyle(fontSize: 12)),
//           IconButton(
//             icon: Icon(
//               Icons.play_arrow,
//               color: isMe ? Colors.white : Colors.lightBlue,
//             ),
//             onPressed: () {},
//             padding: EdgeInsets.zero,
//           ),
//         ],
//       );
//     } else if (msg.type == MessageType.file) {
//       content = Row(
//         children: [
//           Icon(Icons.description, color: Colors.orange, size: 24),
//           const SizedBox(width: 7),
//           Expanded(
//             child: Text(
//               msg.fileName ?? "ملف",
//               style: TextStyle(fontSize: 15, color: textColor),
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             msg.fileSize ?? "",
//             style: TextStyle(color: textColor, fontSize: 13),
//           ),
//         ],
//       );
//     } else {
//       content = const SizedBox.shrink();
//     }

//     // رد مقتبس أعلى الرسالة الجديدة
//     Widget? replyPreview;
//     if (isReply) {
//       final repliedMsg = dataSource.getMessageById(msg.repliedToId);
//       if (repliedMsg != null) {
//         replyPreview = Container(
//           margin: const EdgeInsets.only(bottom: 5),
//           padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
//           decoration: BoxDecoration(
//             color:
//                 isMe
//                     ? Colors.lightGreen.withOpacity(0.15)
//                     : Colors.blueAccent.withOpacity(0.09),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             repliedMsg.text.isNotEmpty
//                 ? (repliedMsg.text.length > 32
//                     ? repliedMsg.text.substring(0, 30) + "..."
//                     : repliedMsg.text)
//                 : repliedMsg.type == MessageType.voice
//                 ? "رسالة صوتية"
//                 : repliedMsg.type == MessageType.image
//                 ? "صورة"
//                 : repliedMsg.type == MessageType.video
//                 ? "فيديو"
//                 : repliedMsg.type == MessageType.file
//                 ? "ملف"
//                 : "",
//             style: TextStyle(
//               fontSize: 13,
//               color: isMe ? Colors.green[900] : Colors.blueAccent[700],
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         );
//       }
//     }

//     // فاصل التاريخ اليومي
//     Widget? daySeparator;
//     if (index == 0 ||
//         intl.DateFormat('yyyyMMdd').format(msg.timestamp) !=
//             intl.DateFormat(
//               'yyyyMMdd',
//             ).format(dataSource.messages[index - 1].timestamp)) {
//       daySeparator = Container(
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         child: Center(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Text(
//               intl.DateFormat('EEE, d MMM yyyy', 'ar').format(msg.timestamp),
//               style: const TextStyle(color: Colors.black54, fontSize: 13),
//             ),
//           ),
//         ),
//       );
//     }

//     // مؤشرات قراءة
//     Widget readStatus =
//         isMe
//             ? Icon(
//               msg.isRead ? Icons.done_all : Icons.done,
//               size: 15,
//               color: msg.isRead ? Colors.lightBlueAccent : Colors.white70,
//             )
//             : const SizedBox.shrink();

//     // التفاعلات
//     Widget reactions =
//         msg.reactions.isNotEmpty
//             ? Padding(
//               padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
//               child: Wrap(
//                 spacing: 4,
//                 children:
//                     msg.reactions
//                         .map(
//                           (e) => Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 5,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               e,
//                               style: const TextStyle(fontSize: 15),
//                             ),
//                           ),
//                         )
//                         .toList(),
//               ),
//             )
//             : const SizedBox.shrink();

//     Widget bubble = GestureDetector(
//       onLongPress: () => _onLongPress(msg),
//       onTap: () => setState(() => _selectedMessage = null),
//       child: Stack(
//         children: [
//           // تظليل عند التحديد
//           Positioned.fill(
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               decoration: BoxDecoration(
//                 color: bubbleHighlight,
//                 borderRadius: borderRadius,
//               ),
//             ),
//           ),
//           // خط جانبي ملون للرد
//           if (isReply)
//             Positioned(
//               top: 8,
//               left: isMe ? null : 0,
//               right: isMe ? 0 : null,
//               bottom: 8,
//               child: Container(
//                 width: 4,
//                 decoration: BoxDecoration(
//                   color: replyColor,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//             ),
//           Container(
//             padding: EdgeInsets.only(
//               left: isReply && !isMe ? 8 : 12,
//               right: isReply && isMe ? 8 : 12,
//               top: 8,
//               bottom: 8,
//             ),
//             child: Column(
//               crossAxisAlignment:
//                   isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 if (!isMe && showAvatar)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 2),
//                     child: Text(
//                       msg.sender,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: Colors.blueGrey[700],
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                 if (replyPreview != null) replyPreview,
//                 content,
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       intl.DateFormat('h:mm a', 'ar').format(msg.timestamp),
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: textColor.withOpacity(0.7),
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     readStatus,
//                   ],
//                 ),
//                 reactions,
//               ],
//             ),
//           ),
//         ],
//       ),
//     );

//     Widget row = Row(
//       mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         if (!isMe && showAvatar)
//           Padding(
//             padding: EdgeInsets.only(left: 8, right: 8, bottom: 2),
//             child: CircleAvatar(
//               backgroundImage: NetworkImage(msg.avatarUrl ?? ""),
//               radius: 18,
//             ),
//           ),
//         Flexible(
//           child: Container(
//             margin: EdgeInsets.only(
//               top: groupedPrev ? 2 : 10,
//               bottom: 2,
//               left: isMe ? 60 : 0,
//               right: isMe ? 0 : 60,
//             ),
//             decoration: BoxDecoration(
//               color: bubbleColor,
//               borderRadius: borderRadius,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 2,
//                   offset: const Offset(1, 1),
//                 ),
//               ],
//             ),
//             child: bubble,
//           ),
//         ),
//         if (isMe && showAvatar)
//           Padding(
//             padding: EdgeInsets.only(left: 8, right: 8, bottom: 2),
//             child: CircleAvatar(
//               backgroundImage: NetworkImage(msg.avatarUrl ?? ""),
//               radius: 18,
//             ),
//           ),
//       ],
//     );

//     return Column(children: [if (daySeparator != null) daySeparator, row]);
//   }

//   Widget _buildJumpToBottomBtn() {
//     if (!_showJumpToBottom && dataSource.newMessageIndex == null)
//       return const SizedBox.shrink();
//     return Positioned(
//       bottom: 88,
//       right: 16,
//       child: FloatingActionButton(
//         mini: true,
//         backgroundColor: Colors.blueAccent,
//         onPressed: _jumpToBottom,
//         child: const Icon(Icons.arrow_downward, color: Colors.white),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xffe5ebee),
//       appBar: AppBar(
//         backgroundColor: const Color(0xff63aee1),
//         elevation: 1.5,
//         title: Row(
//           children: [
//             const CircleAvatar(
//               backgroundImage: NetworkImage(
//                 "https://i.ibb.co/9tBv1z9/telegram-avatar.png",
//               ),
//               radius: 18,
//             ),
//             const SizedBox(width: 12),
//             const Text("Alice", style: TextStyle(fontSize: 18)),
//           ],
//         ),
//         actions: [
//           IconButton(icon: const Icon(Icons.call), onPressed: () {}),
//           IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
//         ],
//       ),
//       body: SafeArea(
//         child: AnimatedBuilder(
//           animation: dataSource,
//           builder: (context, _) {
//             if (_firstLoad) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             return Stack(
//               children: [
//                 Column(
//                   children: [
//                     Expanded(
//                       child: NotificationListener<ScrollNotification>(
//                         onNotification: (n) {
//                           if (n is ScrollEndNotification) _onScroll();
//                           return false;
//                         },
//                         child: ListView.builder(
//                           controller: _scrollController,
//                           reverse: true,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           itemCount: dataSource.messages.length,
//                           itemBuilder: (ctx, idx) {
//                             final msg =
//                                 dataSource.messages[dataSource.messages.length -
//                                     1 -
//                                     idx];
//                             final prev =
//                                 idx < dataSource.messages.length - 1
//                                     ? dataSource.messages[dataSource
//                                             .messages
//                                             .length -
//                                         idx -
//                                         2]
//                                     : null;
//                             final next =
//                                 idx > 0
//                                     ? dataSource.messages[dataSource
//                                             .messages
//                                             .length -
//                                         idx]
//                                     : null;
//                             return _buildMessageBubble(
//                               msg,
//                               prev,
//                               next,
//                               dataSource.messages.length - 1 - idx,
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     _buildInputBar(),
//                   ],
//                 ),
//                 _buildJumpToBottomBtn(),
//                 // شارة "رسالة جديدة"
//                 if (dataSource.newMessageIndex != null && _showJumpToBottom)
//                   Positioned(
//                     top: 40,
//                     right: 20,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.redAccent,
//                         borderRadius: BorderRadius.circular(18),
//                         boxShadow: [
//                           BoxShadow(color: Colors.black12, blurRadius: 4),
//                         ],
//                       ),
//                       child: const Text(
//                         "رسالة جديدة",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:english_mentor_ai2/presentation/widgets/chat_grouped_images.dart';
import 'package:english_mentor_ai2/presentation/widgets/chat_input_bar.dart';
import 'package:english_mentor_ai2/presentation/widgets/chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:english_mentor_ai2/data/local_data_source.dart';

class TelegramChatScreen extends StatefulWidget {
  const TelegramChatScreen({Key? key}) : super(key: key);

  @override
  State<TelegramChatScreen> createState() => _TelegramChatScreenState();
}

class _TelegramChatScreenState extends State<TelegramChatScreen> {
  final LocalChatDataSource dataSource = LocalChatDataSource();
  final ScrollController _scrollController = ScrollController();
  bool _firstLoad = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    dataSource.loadInitialMessages().then((_) {
      setState(() => _firstLoad = false);
      // بعد أول تحميل، انتقل للأسفل مباشرة (آخر رسالة)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() async {
    // إذا وصل المستخدم إلى الأعلى وحالة التحميل متاحة
    if (_scrollController.position.pixels <= 120 &&
        dataSource.hasMore &&
        !_loadingMore) {
      setState(() => _loadingMore = true);

      // قبل التحميل: احتفظ بارتفاع القائمة
      final beforeMax = _scrollController.position.maxScrollExtent;
      final beforeOffset = _scrollController.offset;

      await dataSource.loadMoreMessages();
      await Future.delayed(const Duration(milliseconds: 20)); // لإكمال البناء

      // بعد التحميل: احسب الفرق وعوضه
      final afterMax = _scrollController.position.maxScrollExtent;
      if (_scrollController.hasClients) {
        final delta = afterMax - beforeMax;
        _scrollController.jumpTo(beforeOffset + delta);
      }
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe5ebee),
      appBar: AppBar(
        backgroundColor: const Color(0xff63aee1),
        elevation: 1.5,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                "https://i.ibb.co/9tBv1z9/telegram-avatar.png",
              ),
              radius: 18,
            ),
            const SizedBox(width: 12),
            const Text("Alice", style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: dataSource,
          builder: (context, _) {
            if (_firstLoad) {
              return const Center(child: CircularProgressIndicator());
            }
            final messages = dataSource.messages;
            return Column(
              children: [
                // شريط تحميل صغير يظهر أعلى الرسائل عند التحميل
                if (_loadingMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: Center(
                        child: SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: false, // ترتيب: الأقدم في الأعلى، الأحدث في الأسفل
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (ctx, idx) {
                      final msg = messages[idx];
                      return ChatMessageBubble(msg: msg);
                    },
                  ),
                ),
                ChatInputBar(
                  onSend: (text) {
                    dataSource.addMessage(
                      ChatMessage(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        text: text as String,
                        isMe: true,
                        createdAt: DateTime.now(),
                        type: MessageType.text,
                      ),
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
