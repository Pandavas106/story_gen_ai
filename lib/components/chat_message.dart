import 'package:eduverse/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:eduverse/constant.dart';

class ChatMessageWidget extends StatelessWidget {
  final Message message;

  const ChatMessageWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar or Icon
          CircleAvatar(
            backgroundColor: message.isUser ? Colors.blue[100] : kprimarycolor.withOpacity(0.2),
            child: Icon(
              message.isUser ? Icons.person : Icons.auto_stories,
              color: message.isUser ? Colors.blue[700] : kprimarycolor,
            ),
          ),
          const SizedBox(width: 12),
          // Message Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender name
                Text(
                  message.isUser ? 'You' : 'StoryBot',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: message.isUser ? Colors.blue[700] : kprimarycolor,
                  ),
                ),
                const SizedBox(height: 4),
                // Message content with Markdown support
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: message.isUser ? Colors.blue[50] : Colors.grey[100],
                    child: message.isUser
                        ? Text(message.content)
                        : MarkdownBody(
                            data: message.content,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              h1: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kprimarycolor,
                              ),
                              h2: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kprimarycolor,
                              ),
                              h3: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kprimarycolor,
                              ),
                              p: TextStyle(fontSize: 15),
                              code: TextStyle(
                                backgroundColor: Colors.grey[200],
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}