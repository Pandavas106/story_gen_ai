import 'package:flutter/material.dart';

class GenrePickerBottomSheet extends StatelessWidget {
  final List<String> genres;
  final String selectedGenre;
  final Function(String) onGenreSelected;

  const GenrePickerBottomSheet({
    Key? key,
    required this.genres,
    required this.selectedGenre,
    required this.onGenreSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.0,
                ),
              ),
            ),
            child: Text(
              "Select Genre",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = genre == selectedGenre;
                
                return ListTile(
                  title: Text(
                    genre,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? Icon(Icons.check, color: Colors.green) : null,
                  onTap: () => onGenreSelected(genre),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}