import 'package:english_mentor_ai2/data/local_data_source.dart';
import 'package:flutter/material.dart';

/// ويدجت بسيط لعرض الريأكشنات وإضافة/إزالتها
class ReactionBar extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onAddReaction;
  final Function(String) onRemoveReaction;
  static const List<String> availableReactions = ["👍", "❤️", "😂", "😮", "😢"];

  const ReactionBar({
    super.key,
    required this.message,
    required this.onAddReaction,
    required this.onRemoveReaction,
  });

  @override
  Widget build(BuildContext context) {
    final myUserId = "me"; // استبدلها بمعرف المستخدم الحقيقي لديك

    return RepaintBoundary(
      key: ValueKey('reactions_${message.id}'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عرض الريأكشنات الموجودة
          ...message.reactions.entries.map((entry) {
            final emoji = entry.key;
            final count = entry.value.length;
            final reacted = entry.value.contains(myUserId);
            return RepaintBoundary(
              key: ValueKey('reaction_${emoji}_${message.id}'),
              child: GestureDetector(
                onTap: () {
                  if (reacted) {
                    onRemoveReaction(emoji);
                  } else {
                    onAddReaction(emoji);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: reacted ? Colors.orange[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    border:
                        reacted
                            ? Border.all(color: Colors.orange)
                            : Border.all(color: Colors.transparent),
                  ),
                  child: Text('$emoji $count'),
                ),
              ),
            );
          }),
          // زر لإضافة ريأكشن جديد من القائمة
          PopupMenuButton<String>(
            icon: const Icon(Icons.add_reaction, size: 22),
            onSelected: (reaction) => onAddReaction(reaction),
            itemBuilder:
                (_) => [
                  for (final r in availableReactions)
                    PopupMenuItem(
                      value: r,
                      child: Text(r, style: const TextStyle(fontSize: 22)),
                    ),
                ],
          ),
        ],
      ),
    );
  }
}
