import 'package:flutter/material.dart';
import 'package:english_mentor_ai2/data/local_data_source.dart';

class PinnedMessageBar extends StatelessWidget {
  final LocalChatDataSource dataSource;
  const PinnedMessageBar({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    final pinned = dataSource.pinnedMessage;
    if (pinned == null) return const SizedBox.shrink();
    return Container(
      color: Colors.yellow.shade100,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Icon(Icons.push_pin, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pinned.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => dataSource.unpinMessage(),
          ),
        ],
      ),
    );
  }
}
