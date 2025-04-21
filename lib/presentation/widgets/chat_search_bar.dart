import 'package:flutter/material.dart';
import 'package:english_mentor_ai2/data/local_data_source.dart';

class ChatSearchBar extends StatelessWidget {
  final LocalChatDataSource dataSource;
  const ChatSearchBar({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: dataSource.searchController,
              decoration: const InputDecoration(
                hintText: "ابحث في الدردشة...",
                border: InputBorder.none,
              ),
              onChanged: dataSource.onSearchTextChanged,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: dataSource.onSearchPressed,
          ),
        ],
      ),
    );
  }
}
