import 'package:eduverse/components/bottom_sheet.dart';
import 'package:eduverse/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:eduverse/constant.dart';
import 'package:eduverse/components/genre_picker.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController topicController;
  final String selectedGenre;
  final ValueChanged<String> onGenreChanged;
  final VoidCallback onSend;
  final List<String> genres;

  const MessageInputField({
    Key? key,
    required this.topicController,
    required this.selectedGenre,
    required this.onSend,
    required this.onGenreChanged,
    required this.genres,
  }) : super(key: key);

  Future<void> _showGenrePicker(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return GenrePickerBottomSheet(
          genres: genres,
          selectedGenre: selectedGenre,
          onGenreSelected: (genre) {
            onGenreChanged(genre);
            Future.microtask(() => NavigationService.instance.goBack());
          },
        );
      },
    );
  }

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
          GenrePickerButton(
            selectedGenre: selectedGenre,
            genres: genres,
            onGenreChanged: onGenreChanged,
            backgroundColor: kprimarycolor,
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

  const GenreButton({Key? key, required this.genre, required this.onPressed})
    : super(key: key);

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
