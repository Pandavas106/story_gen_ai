import 'dart:convert';

class StoryResponse {
  final String story;
  final String concept;
  final Map<String, String>? codes;
  final String? usecases;

  StoryResponse({
    required this.story, 
    required this.concept, 
    this.codes,
    this.usecases,
  });

  // Create from parsed JSON map
  factory StoryResponse.fromJson(Map<String, dynamic> json) {
    // Handle codes field which might be a Map
    Map<String, String>? parsedCodes;
    if (json.containsKey('codes')) {
      parsedCodes = {};
      Map<String, dynamic> codesMap = json['codes'];
      codesMap.forEach((key, value) {
        if (value is String) {
          parsedCodes![key] = value;
        }
      });
    }

    return StoryResponse(
      story: json['story'] ?? 'No story content available',
      concept: json['concept'] ?? 'No explanation available',
      codes: parsedCodes,
      usecases: json['usecases'] is String ? json['usecases'] : null,
    );
  }

  // Create from raw API response text
  factory StoryResponse.fromRawResponse(String response) {
    try {
      // Try direct JSON parsing
      Map<String, dynamic> json = jsonDecode(response);
      return StoryResponse.fromJson(json);
    } catch (e) {
      // If direct parsing fails, try to extract JSON from text
      final jsonPattern = RegExp(r'\{[\s\S]*\}');
      final match = jsonPattern.firstMatch(response);
      
      if (match != null) {
        try {
          Map<String, dynamic> json = jsonDecode(match.group(0)!);
          return StoryResponse.fromJson(json);
        } catch (e) {
          // If extraction fails too, return default response
          print('Error parsing extracted JSON: $e');
        }
      }
      
      // Default empty response
      return StoryResponse(
        story: '📘 Story\nUnable to generate a story at this time.',
        concept: '🧠 Explanation\nThere was an error processing your request.',
        usecases: '💼 Use Cases\n• Please try again with a different topic or check your connection.',
      );
    }
  }

  // Format the entire response for display
  String formatFullResponse() {
    StringBuffer formatted = StringBuffer();
    
    formatted.writeln(story);
    formatted.writeln();
    
    formatted.writeln(concept);
    formatted.writeln();
    
    if (codes != null && codes!.isNotEmpty) {
      codes!.forEach((language, code) {
        formatted.writeln(code);
        formatted.writeln();
      });
    } else if (usecases != null) {
      formatted.writeln(usecases);
    }
    
    return formatted.toString().trim();
  }
}