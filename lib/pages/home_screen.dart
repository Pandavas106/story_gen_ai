import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:eduverse/providers/auth_provider.dart';
import 'package:eduverse/constant.dart';
import 'package:eduverse/secret.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // 👈 ADD THIS
  String _selectedGenre = 'Fantasy';
  bool _isLoading = false;

  final List<String> _genres = [
    'Fantasy',
    'Science Fiction',
    'Horror',
    'Adventure',
    'Mystery',
    'Romance',
    'Games',
  ];

  final List<Map<String, dynamic>> _chatMessages = [];

  Future<void> _generateStory() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isLoading = true;
      _chatMessages.add({'sender': 'user', 'message': topic});
    });

    _scrollToBottom(); // 👈 SCROLL AFTER USER MESSAGE

    final prompt = """
You are a storyteller bot that teaches technical concepts in a fun and engaging way. For the topic '$topic', write a response in the following structure:

## 📘 Story (in $_selectedGenre style)
- Tell a short and creative story between 150–250 words related to the concept.

## 🧠 Explanation
- Clearly explain the real technical concept (150–250 words).
- Reference the story metaphor (e.g., if two people break their handshake, that represents a broken link in a linked list).
- Use analogies from the story to clarify terms like "node", "link", "head", etc.
- If relevant, use bullet points for clarity.

## 💡 Example (with code)
- Provide complete and idiomatic examples in the following formats:
  - Python: A fully working example using proper Python syntax and conventions. Use triple backticks ```python
  - Java: A complete class with a main method, using Java syntax and conventions. Use triple backticks ```java
  - C++: A complete `main()` function with proper includes and syntax. Use triple backticks ```c++
- Avoid referencing or copying the Python output in the Java and C++ examples. All three should be independently correct and idiomatic.
""";

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY',
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawText = data['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _chatMessages.add({'sender': 'ai', 'message': rawText});
          _isLoading = false;
          _topicController.clear();
        });

        _scrollToBottom(); // 👈 SCROLL AFTER AI MESSAGE
      } else {
        setState(() {
          _chatMessages.add({
            'sender': 'ai',
            'message': 'Error: ${response.reasonPhrase} ${response.body}',
          });
          _isLoading = false;
        });

        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _chatMessages.add({
          'sender': 'ai',
          'message': 'Failed to generate story. Error: $e',
        });
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // 👇 Add this safe scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showGenrePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: _genres.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_genres[index]),
                onTap: () {
                  setState(() {
                    _selectedGenre = _genres[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isUser ? kprimarycolor.withOpacity(0.9) : Color(0xFFF1F0F0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
        ),
        child: isUser
            ? Text(
                message['message'],
                style: TextStyle(color: Colors.white, fontSize: 16),
              )
            : _buildMarkdownWithCodeToggle(message['message']),
      ),
    );
  }

  Widget _buildMarkdownWithCodeToggle(String markdownText) {
    final codeRegExp = RegExp(r'```(\w+)\s([\s\S]*?)```');
    final matches = codeRegExp.allMatches(markdownText);

    String explanation = markdownText.replaceAll(codeRegExp, '');
    Map<String, String> codeSnippets = {};

    for (final match in matches) {
      final lang = match.group(1)?.toLowerCase() ?? 'text';
      final code = match.group(2)?.trim() ?? '';
      codeSnippets[lang] = code;
    }

    final List<String> languages = codeSnippets.keys.toList();
    String selectedLanguage = languages.isNotEmpty ? languages.first : '';

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: explanation,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(
                Theme.of(context),
              ).copyWith(
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
                items: languages.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(lang.toUpperCase()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  codeSnippets[selectedLanguage] ?? 'No code available',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Story Generator',
          style: TextStyle(
            color: kprimarycolor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return IconButton(
                onPressed: () {
                  auth.logout(() async {});
                },
                icon: Icon(Icons.logout, color: kprimarycolor),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.5,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _chatMessages.isEmpty
                  ? Center(child: Text("Enter a topic and select a genre."))
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      controller: _scrollController, // 👈 ADD THIS
                      itemCount: _chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = _chatMessages[index];
                        return _buildMessage(message);
                      },
                    ),
            ),
            if (_isLoading)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircularProgressIndicator(color: kprimarycolor),
                    SizedBox(width: 10),
                    Text("Generating Story", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            _messageField(),
          ],
        ),
      ),
    );
  }

  Widget _messageField() {
    return Container(
      height: 55,
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IntrinsicWidth(
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _showGenrePicker,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: kprimarycolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  _selectedGenre.replaceAll(' ', '\n'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: _topicController,
                decoration: InputDecoration(
                  hintText: "Enter topic",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _generateStory,
            icon: Icon(Icons.send, color: kprimarycolor),
          ),
        ],
      ),
    );
  }
}
