import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_game/managers/game_manager.dart';
import 'package:memory_game/pages/error_page.dart';
import 'package:memory_game/pages/loading_page.dart';
import 'package:memory_game/pages/level_selection_page.dart';
import 'package:memory_game/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import 'models/word.dart';

List<Word> sourceWords = [];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: populateSourceWords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        } else if (snapshot.hasError) {
          return const ErrorPage();
        } else {
          // Determine the total pairs based on the number of sourceWords
          return ChangeNotifierProvider(
            create: (_) => GameManager(), // Pass totalPairs here
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Memory Game',
              theme: appTheme,
              home: const LevelSelectionPage(),
            ),
          );
        }
      },
    );
  }
}

class LevelSettings {
  final int rows;
  final int columns;

  LevelSettings({required this.rows, required this.columns});
}

Future<int> populateSourceWords() async {
  var url =
      'http://192.168.1.107/D/getData.php'; // Update with your server details

  try {
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      for (var item in jsonData) {
        sourceWords.add(Word(
          text: item['title'],
          url: item['image'],
          displayText: false,
        ));
      }
      return 1;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching data: $e');
    }
    throw Exception('Failed to load data');
  }
}
