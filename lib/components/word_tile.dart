import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/animation/flip_animation.dart';
import 'package:memory_game/animation/matched_animation.dart';
import 'package:memory_game/managers/game_manager.dart';
import 'package:memory_game/models/word.dart';
import 'package:provider/provider.dart';

class WordTile extends StatelessWidget {
  const WordTile({
    required this.index,
    required this.word,
    super.key,
  });

  final int index;
  final Word word;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (_, notifier, __) {
        bool animate = checkAnimationRun(notifier);

        return GestureDetector(
          onTap: () {
            if (!notifier.ignoreTaps &&
                !notifier.answeredWords.contains(index) &&
                !notifier.tappedWords.containsKey(index)) {
              notifier.tileTapped(index: index, word: word);
            }
          },
          child: FlipAnimation(
            delay: notifier.reverseFlip ? 1500 : 0,
            reverse: notifier.reverseFlip,
            animationCompleted: (isForward) {
              notifier.onAnimationCompleted(isForward: isForward);
            },
            animate: animate,
            word: MatchedAnimation(
              numberOfWordsAnswered: notifier.answeredWords.length,
              animate: notifier.answeredWords.contains(index),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _buildContent(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    if (word.displayText) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(pi),
          child: Text(
          word.text,
          style: const TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none, // Remove underline
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500, // Set font weight to lighter
          ))
          ,
        ),
      );
    } else {
      // Check if imageBytes is already decoded and available
      if (word.imageBytes != null) {
        // Display the cached image
        return Image.memory(
          word.imageBytes!,
          width: 100, // Set width and height as needed
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              print('Error loading image: $error');
            }
            return const Icon(Icons.error);
          },
        );
      } else {
        // Load and decode the image asynchronously
        return FutureBuilder<Uint8List>(
          future: _loadImage(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              // Cache the decoded image bytes
              word.imageBytes = snapshot.data!;
              // Display the image
              return Image.memory(
                snapshot.data!,
                width: 100, // Set width and height as needed
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  if (kDebugMode) {
                    print('Error loading image: $error');
                  }
                  return const Icon(Icons.error);
                },
              );
            } else {
              // Display a loading indicator while loading the image
              return const CircularProgressIndicator();
            }
          },
        );
      }
    }
  }

  Future<Uint8List> _loadImage(BuildContext context) async {
    try {
      String base64Image = word.url!;
      return base64Decode(base64Image);
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding image: $e');
      }
      rethrow; // Rethrow the error for proper error handling
    }
  }

  bool checkAnimationRun(GameManager notifier) {
    bool animate = false;

    if (notifier.canFlip) {
      if (notifier.tappedWords.isNotEmpty &&
          notifier.tappedWords.keys.last == index) {
        animate = true;
      }
      if (notifier.reverseFlip && !notifier.answeredWords.contains(index)) {
        animate = true;
      }
    }
    return animate;
  }
}
