import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/animation/confetti_animation.dart';
import 'package:memory_game/components/replay_popup.dart';
import 'package:memory_game/components/word_tile.dart';
import 'package:memory_game/main.dart';
import 'package:memory_game/managers/game_manager.dart';
import 'package:memory_game/models/word.dart';
import 'package:memory_game/pages/error_page.dart';
import 'package:memory_game/pages/loading_page.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  final int level;

  const GamePage({super.key, required this.level});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // ignore: prefer_typing_uninitialized_variables
  late final _futureCachedImages;
  final List<Word> _gridWords = [];
  late int _currentLevel;
  late int _totalPairs; // Variable to track total number of pairs

  @override
  void initState() {
    _futureCachedImages = _cacheImages();
    _currentLevel = widget.level;
    _totalPairs = _getLevelSettings().rows *
        _getLevelSettings().columns; // Calculate total pairs
    final gameManager = Provider.of<GameManager>(context, listen: false);
    gameManager.totalPairs = _totalPairs;
    _setUp(_getLevelSettings()); // Set up based on selected level
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthPadding = size.width * 0.10;
    return FutureBuilder(
      future: _futureCachedImages,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ErrorPage();
        }
        if (snapshot.hasData) {
          return Selector<GameManager, bool>(
            selector: (_, gameManager) =>
                gameManager.roundCompleted ||
                gameManager.answeredWords.length == _totalPairs,
            builder: (_, __, ___) {
              final gameManager = Provider.of<GameManager>(context);
              final roundCompleted = gameManager.roundCompleted ||
                  gameManager.answeredWords.length == _totalPairs;

              WidgetsBinding.instance.addPostFrameCallback(
                (timeStamp) async {
                  if (roundCompleted ||
                      gameManager.answeredWords.length == _totalPairs) {
                    await showDialog(
                      barrierColor: Colors.transparent,
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const ReplayPopUp(),
                    );
                  }
                },
              );

              return Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/Cloud.png'),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          left: widthPadding,
                          right: widthPadding,
                        ),
                        itemCount: _gridWords.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getLevelSettings().columns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: size.height * 0.38,
                        ),
                        itemBuilder: (context, index) => WordTile(
                          index: index,
                          word: _gridWords[index],
                        ),
                      ),
                    ),
                  ),
                  ConfettiAnimation(animate: roundCompleted),
                ],
              );
            },
          );
        } else {
          return const LoadingPage();
        }
      },
    );
  }

  void _setUp(LevelSettings levelSettings) {
    // Create a set to track unique text and image combinations
    Set<String> uniqueTextImageCombos = {};

    // Create a list to store unique words
    List<Word> uniqueWords = [];

    // Iterate through each word in sourceWords
    for (var word in sourceWords) {
      // Create a string representing the combination of text and image properties
      String textImageCombo = '${word.text}_${word.url}';

      // Check if the combination is unique
      if (!uniqueTextImageCombos.contains(textImageCombo)) {
        // Add the combination to the set to mark it as seen
        uniqueTextImageCombos.add(textImageCombo);

        // Add the word to the uniqueWords list
        uniqueWords.add(word);
      }
    }
    uniqueWords.shuffle();
    _gridWords.clear(); // Clear existing grid words

    int totalWords = levelSettings.rows * levelSettings.columns;

    for (int i = 0; i < totalWords ~/ 2; i++) {
      // Add word with text only
      _gridWords.add(Word(
        text: uniqueWords[i].text,
        displayText: true,
      ));

      // Add word with encoded image
      _gridWords.add(Word(
        text: uniqueWords[i].text,
        url: uniqueWords[i].url, // Store the encoded image data
        displayText: false,
      ));
    }

    _gridWords.shuffle();
  }

  Future<int> _cacheImages() async {
    for (var w in _gridWords) {
      if (!w.displayText && w.url != null) {
        try {
          String base64Image = w.url!;
          Uint8List bytes = base64Decode(base64Image);

          // Update the Word object with the decoded image bytes
          w.imageBytes = bytes;
        } catch (e) {
          if (kDebugMode) {
            print('Error decoding image: $e');
          }
        }
      }
    }

    // After decoding all images, return a completed future
    return Future.value(1);
  }

  LevelSettings _getLevelSettings() {
    switch (_currentLevel) {
      case 1:
        return LevelSettings(rows: 2, columns: 3);
      case 2:
        return LevelSettings(rows: 2, columns: 4);
      case 3:
        return LevelSettings(rows: 2, columns: 5);
      default:
        return LevelSettings(rows: 2, columns: 3); // Default to level 1
    }
  }
}
