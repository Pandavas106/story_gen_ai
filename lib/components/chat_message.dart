import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:eduverse/constant.dart';
import 'package:eduverse/models/message.dart';

class ChatMessageWidget extends StatelessWidget {
  final Message message;

  const ChatMessageWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color:
              message.isUser
                  ? kprimarycolor.withOpacity(0.9)
                  : Color(0xFFF1F0F0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(message.isUser ? 12 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 12),
          ),
        ),
        child:
            message.isUser
                ? Text(
                  message.content,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )
                : CodeSnippetMarkdown(markdownText: message.content),
      ),
    );
  }
}

class CodeSnippetMarkdown extends StatefulWidget {
  final String markdownText;

  const CodeSnippetMarkdown({Key? key, required this.markdownText})
    : super(key: key);

  @override
  _CodeSnippetMarkdownState createState() => _CodeSnippetMarkdownState();
}

class _CodeSnippetMarkdownState extends State<CodeSnippetMarkdown> {
  late String explanation;
  late Map<String, String> codeSnippets;
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();
    _processMarkdown();
  }

  void _processMarkdown() {
    final codeRegExp = RegExp(r'```(\w+)\s([\s\S]*?)```');
    final matches = codeRegExp.allMatches(widget.markdownText);

    explanation = widget.markdownText.replaceAll(codeRegExp, '');
    codeSnippets = {};

    for (final match in matches) {
      final lang = match.group(1)?.toLowerCase() ?? 'text';
      final code = match.group(2)?.trim() ?? '';
      codeSnippets[lang] = code;
    }

    final List<String> languages = codeSnippets.keys.toList();
    selectedLanguage = languages.isNotEmpty ? languages.first : '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
          data: explanation,
          selectable: true,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        if (codeSnippets.isNotEmpty) ...[
          DropdownButton<String>(
            value: selectedLanguage,
            onChanged: (newLang) {
              if (newLang != null) {
                setState(() => selectedLanguage = newLang);
              }
            },
            items:
                codeSnippets.keys.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(lang.toUpperCase()),
                  );
                }).toList(),
          ),
          const SizedBox(height: 8),
          CodeBlock(
            code: codeSnippets[selectedLanguage] ?? 'No code available',
          ),
        ],
      ],
    );
  }
}

class CodeBlock extends StatelessWidget {
  final String code;

  const CodeBlock({Key? key, required this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
