// import 'package:flutter/material.dart';
// import 'package:english_mentor_ai2/data/local_data_source.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../widgets/chat_message_bubble.dart';
// import '../widgets/chat_status_bar.dart';

// class ModernChatScreen extends StatelessWidget {
//   final LocalChatDataSource dataSource = LocalChatDataSource.demo();

//   ModernChatScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // خلفية متدرجة مع عناصر جمالية
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xffe0c3fc), Color(0xff8ec5fc)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           // دوائر شفافة جمالية
//           Positioned(
//             top: -80,
//             left: -40,
//             child: Container(
//               width: 180,
//               height: 180,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.11),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -100,
//             right: -60,
//             child: Container(
//               width: 220,
//               height: 220,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.12),
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 // AppBar عصري
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 2,
//                   ),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         backgroundImage: const NetworkImage(
//                           'https://i.ibb.co/9tBv1z9/telegram-avatar.png',
//                         ),
//                         radius: 23,
//                         backgroundColor: Colors.white,
//                       ),
//                       const SizedBox(width: 10),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Alice',
//                             style: GoogleFonts.poppins(
//                               fontSize: 19,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blueGrey[900],
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Container(
//                                 width: 8,
//                                 height: 8,
//                                 decoration: BoxDecoration(
//                                   color: Colors.greenAccent,
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                               const SizedBox(width: 5),
//                               Text(
//                                 'متصل الآن',
//                                 style: GoogleFonts.poppins(
//                                   color: Colors.green[700],
//                                   fontSize: 12.5,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       IconButton(
//                         icon: const Icon(Icons.call, color: Color(0xff63aee1)),
//                         onPressed: () {},
//                         splashRadius: 22,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.more_vert, color: Colors.grey),
//                         onPressed: () {},
//                         splashRadius: 22,
//                       ),
//                     ],
//                   ),
//                 ),
//                 // شريط الحالة
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     bottom: 7.0,
//                     left: 16,
//                     right: 16,
//                   ),
//                   child: ChatStatusBar(dataSource: dataSource),
//                 ),
//                 // قائمة الرسائل
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.only(bottom: 12, top: 2),
//                     itemCount: dataSource.messages.length,
//                     itemBuilder: (ctx, idx) {
//                       final msg = dataSource.messages[idx];
//                       final replyMsg =
//                           dataSource.messages
//                                   .where((m) => m.id == msg.replyTo)
//                                   .isNotEmpty
//                               ? dataSource.messages.firstWhere(
//                                 (m) => m.id == msg.replyTo,
//                               )
//                               : null;

//                       return ChatMessageBubble(msg: msg, replyTo: replyMsg);
//                     },
//                   ),
//                 ),
//                 // شريط إدخال أنيق
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 6,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.88),
//                             borderRadius: BorderRadius.circular(30),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 blurRadius: 9,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: "اكتب رسالة...",
//                               hintStyle: GoogleFonts.poppins(
//                                 color: Colors.grey[500],
//                                 fontSize: 15.5,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 10,
//                                 horizontal: 18,
//                               ),
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 11),
//                       CircleAvatar(
//                         backgroundColor: const Color(0xff63aee1),
//                         radius: 24,
//                         child: IconButton(
//                           icon: const Icon(Icons.send, color: Colors.white),
//                           onPressed: () {},
//                           splashRadius: 23,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
