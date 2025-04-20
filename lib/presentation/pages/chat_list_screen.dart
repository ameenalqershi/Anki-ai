import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/chat_model.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  final List<ChatModel> chats = [
    ChatModel(
      name: 'محمد علي',
      lastMessage: 'مرحبا! كيف الحال؟',
      imageUrl: 'https://placehold.co/150',
      unreadCount: 2,
      isOnline: true,
    ),
    // إضافة المزيد من الدردشات هنا
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدردشات'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildChatItem(context,chats[index]),
              childCount: chats.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {},
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatModel chat) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: CachedNetworkImageProvider(chat.imageUrl),
          ),
          if (chat.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(chat.name,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('10:30 AM',
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12)),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                  color: Colors.blue, shape: BoxShape.circle),
              child: Text(chat.unreadCount.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12)),
            ),
        ],
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ChatDetailScreen(chat))),
    );
  }
}

