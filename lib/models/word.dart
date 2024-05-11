import 'dart:typed_data';

class Word {
  final String text;
  final String? url; // Store base64-encoded image data
  final bool displayText;
  Uint8List? imageBytes; // Store decoded image bytes

  Word({
    required this.text,
    this.url,
    required this.displayText,
  });
}
