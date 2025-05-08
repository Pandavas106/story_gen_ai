import 'package:flutter/material.dart';
import 'package:eduverse/components/genre_picker.dart';

class GenrePickerButton extends StatelessWidget {
  final String selectedGenre;
  final List<String> genres;
  final ValueChanged<String> onGenreChanged;
  final Color backgroundColor;

  const GenrePickerButton({
    Key? key,
    required this.selectedGenre,
    required this.genres,
    required this.onGenreChanged,
    required this.backgroundColor,
  }) : super(key: key);

  void _showGenrePicker(BuildContext context) async {
    await Future.delayed(Duration.zero); // Prevent navigator lock issue
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GenrePickerBottomSheet(
          genres: genres,
          selectedGenre: selectedGenre,
          onGenreSelected: (genre) {
            onGenreChanged(genre);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: SizedBox(
        height: 55,
        child: ElevatedButton(
          onPressed: () => _showGenrePicker(context),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(
            selectedGenre.replaceAll(' ', '\n'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
