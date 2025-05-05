import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduverse/constant.dart';
import 'package:eduverse/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
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
    "Games"
  ];

  void _generateStory() async {
    if (_topicController.text.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _generatedStory =
          'Once upon a time in a $_selectedGenre world, a story began with the topic "${_topicController.text}".';
      _isLoading = false;
      _topicController.clear();
    });
  }

  void _showGenrePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
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
                          child: CircularProgressIndicator(color: kprimarycolor),
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
            child: Container(
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
