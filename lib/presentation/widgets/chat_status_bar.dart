import 'package:flutter/material.dart';
import 'package:english_mentor_ai2/data/local_data_source.dart';

class ChatStatusBar extends StatelessWidget {
  final LocalChatDataSource dataSource;
  const ChatStatusBar({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    // مثال: يمكنك إظهار "متصل" أو "يكتب..." حسب حالة المستخدم
    return Container(
      color: Colors.blue.shade50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      child: Text(
        dataSource.statusText,
        style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
      ),
    );
  }
}
