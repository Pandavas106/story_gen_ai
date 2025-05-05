import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduverse/constant.dart';
import 'package:eduverse/providers/auth_provider.dart';
import 'package:eduverse/pages/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduverse/secret.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _selectedGenre = 'Fantasy';
  String _generatedStory = '';
  bool _isLoading = false;

  final List<String> _genres = [
    'Fantasy',
    'Science Fiction',
    'Horror',
    'Adventure',
    'Mystery',
    'Romance',
    "Games",
  ];

  Future<void> _generateStory() async {
  if (_topicController.text.trim().isEmpty) return;

  setState(() {
    _isLoading = true;
    _generatedStory = '';
  });

  final String topic = _topicController.text.trim();
  final String genre = _selectedGenre;

  final prompt =
      "Write a creative story based on the genre '$genre' explaining the topic '$topic'. and give an explaination for the story to understand the topic";

  final url = Uri.parse(
  'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY');



  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': prompt}
        ]
      }
    ]
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final story = data['candidates'][0]['content']['parts'][0]['text'];

      setState(() {
        _generatedStory = story;
        _isLoading = false;
        _topicController.clear();
      });
    } else {
      setState(() {
        _generatedStory = 'Error: ${response.reasonPhrase} ${response.body}';
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _generatedStory = 'Failed to generate story. Error: $e';
      _isLoading = false;
    });
  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Story Generator',
          style: TextStyle(
            color: kprimarycolor,
            fontWeight: FontWeight.bold,
            fontSize: 27,
          ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return Center(
                child: IconButton(
                  onPressed: () {
                    auth.logout(() async {});
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ), // Replace with your actual Sign In widget
                    );
                  },
                  icon: Icon(Icons.logout, color: kprimarycolor),
                  iconSize: 28,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  splashRadius: 24,
                  tooltip: 'Logout',
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: kprimarycolor,
                          ),
                        )
                        : _generatedStory.isEmpty
                        ? Center(
                          child: Text(
                            "Enter a topic and select a genre to generate a story.",
                          ),
                        )
                        : SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: kprimarycolor,
                                width: 1.2,
                              ),
                            ),
                            child: SelectableText(
                              _generatedStory,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
              ),
              _messageField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageField() {
    return Container(
      height: 55,
      width: double.infinity,
      margin: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Genre Button
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

          // Text field
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

          // Send Button
          IconButton(
            onPressed: _generateStory,
            icon: Icon(Icons.send, color: kprimarycolor),
          ),
        ],
      ),
    );
  }
}
