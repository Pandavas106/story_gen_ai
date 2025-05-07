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
// Import the new structured content model
import 'package:eduverse/models/story_response.dart';

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

  // Variable to store structured response
  // ignore: unused_field
  StoryResponse? _storyResponse;

  Future<void> _generateStory() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a topic.'),
          duration: Duration(milliseconds: 300),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _chatMessages.add(Message.user(topic));
    });

    _scrollToBottom();

    final prompt = """
You are a storyteller bot that teaches technical concepts in a fun and engaging way. For the topic $topic, generate a structured response in the following JSON-like key-value format:
1. "story" → A fun, fictional story related to the concept (150–250 words).
2. "concept" → A real explanation of the technical concept (150–250 words), using metaphors from the story.
3. Depending on the topic:
   - If it's a **coding-related topic** (like LeetCode problems, DSA, data structures, algorithms, programming languages, or databases), include:
     "codes": {
       "Python": "💡 Python Example\\n```python\\n# complete program with all operations\\n```",
       "Java": "💡 Java Example\\n```java\\n// complete program with all operations\\n```",
       "C++": "💡 C++ Example\\n```c++\\n// complete program with all operations\\n```",
       "SQL": "💡 SQL Example\\n```sql\\n-- query\\n```",
       "MongoDB": "💡 MongoDB Example\\n```javascript\\n// All related Mongo query or aggregation\\n```",
       "Firebase": "💡 Firebase Example\\n```javascript\\n// All related Firebase Realtime or Firestore code\\n```"
     }
   - If it's a **non-coding technical topic** (like UI/UX, networking, IoT systems, OS, etc.), include:
     "usecases": "💼 Use Cases\\n• Bullet 1\\n• Bullet 2\\n• Bullet 3"
Strictly respond in this JSON-like key-value structure:
{
  "story": "📘 Story in $_selectedGenre style\\n...",
  "concept": "🧠 Explanation\\n...",
  "codes" or "usecases": {...}
}
Use markdown headings and code blocks appropriately. Do NOT add extra explanation or formatting outside this structure.
""";

    try {
      final responseText = await _fetchGeneratedContent(prompt);

      // Parse the response into the structured model
      final storyResponse = StoryResponse.fromRawResponse(responseText);

      // Store the response in the class variable
      setState(() {
        _storyResponse = storyResponse;

        // Add formatted message to chat
        _chatMessages.add(Message.ai(storyResponse.formatFullResponse()));
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

  // These functions are now handled by the StoryResponse model

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
      final candidates = data['candidates'];
      if (candidates != null &&
          candidates.isNotEmpty &&
          candidates[0]['content'] != null &&
          candidates[0]['content']['parts'] != null &&
          candidates[0]['content']['parts'].isNotEmpty) {
        return candidates[0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Invalid response format from API.');
      }
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
              child:
                  _chatMessages.isEmpty
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
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
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
