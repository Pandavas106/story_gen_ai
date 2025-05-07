import 'dart:convert';
import 'package:eduverse/components/chat_message.dart';
import 'package:eduverse/components/genre_picker.dart';
import 'package:eduverse/components/message_input_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:eduverse/providers/auth_provider.dart';
import 'package:eduverse/constant.dart';
import 'package:eduverse/secret.dart';
import 'package:eduverse/models/message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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

  final List<Message> _chatMessages = [];

  Future<void> _generateStory() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isLoading = true;
      _chatMessages.add(Message.user(topic));
    });

    _scrollToBottom();

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

    try {
      final response = await _fetchGeneratedContent(prompt);
      setState(() {
        _chatMessages.add(Message.ai(response));
        _isLoading = false;
        _topicController.clear();
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _chatMessages.add(Message.ai('Failed to generate story. Error: $e'));
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  Future<String> _fetchGeneratedContent(String prompt) async {
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

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Error: ${response.reasonPhrase} ${response.body}');
    }
  }

  void _scrollToBottom() {
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
        return GenrePickerBottomSheet(
          genres: _genres,
          selectedGenre: _selectedGenre,
          onGenreSelected: (genre) {
            setState(() {
              _selectedGenre = genre;
            });
            Navigator.pop(context);
          },
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
                      controller: _scrollController,
                      itemCount: _chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = _chatMessages[index];
                        return ChatMessageWidget(message: message);
                      },
                    ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircularProgressIndicator(color: kprimarycolor),
                    SizedBox(width: 10),
                    Text("Generating Story", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            MessageInputField(
              topicController: _topicController,
              selectedGenre: _selectedGenre,
              onSend: _generateStory,
              onGenrePressed: _showGenrePicker,
            ),
          ],
        ),
      ),
    );
  }
}