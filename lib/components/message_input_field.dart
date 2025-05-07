import 'package:flutter/material.dart';
import 'package:eduverse/constant.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController topicController;
  final String selectedGenre;
  final VoidCallback onSend;
  final VoidCallback onGenrePressed;

  const MessageInputField({
    Key? key,
    required this.topicController,
    required this.selectedGenre,
    required this.onSend,
    required this.onGenrePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GenreButton(
            genre: selectedGenre,
            onPressed: onGenrePressed,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: topicController,
                decoration: InputDecoration(
                  hintText: "Enter topic",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSend,
            icon: Icon(Icons.send, color: kprimarycolor),
          ),
        ],
      ),
    );
  }
}

class GenreButton extends StatelessWidget {
  final String genre;
  final VoidCallback onPressed;

  const GenreButton({
    Key? key,
    required this.genre,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: SizedBox(
        height: 55,
        child: ElevatedButton(
          onPressed: onPressed,
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
            genre.replaceAll(' ', '\n'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}