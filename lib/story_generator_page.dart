import 'package:flutter/material.dart';

class StoryGeneratorPage extends StatefulWidget {
  @override
  _StoryGeneratorPageState createState() => _StoryGeneratorPageState();
}

class _StoryGeneratorPageState extends State<StoryGeneratorPage> {
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
    'Romance'
  ];

  void _generateStory() async {
    setState(() {
      _isLoading = true;
    });

    // Simulated story generation (replace with API call later)
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _generatedStory =
          'Once upon a time in a $_selectedGenre world, a story began with the topic "${_topicController.text}".';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Story Generator'),
        backgroundColor: Colors.orange[700],
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: 'Enter Topic',
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              decoration: InputDecoration(
                labelText: 'Select Genre',
              ),
              items: _genres.map((genre) {
                return DropdownMenuItem(
                  value: genre,
                  child: Text(genre),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGenre = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateStory,
              child: Text('Generate Story'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator(
                    color: Colors.orange,
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange, width: 1.2),
                        ),
                        child: Text(
                          _generatedStory,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
