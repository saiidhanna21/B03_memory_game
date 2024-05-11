import 'package:flutter/material.dart';
import 'package:memory_game/pages/game_page.dart';

class LevelSelectionPage extends StatelessWidget {
  const LevelSelectionPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend background behind app bar
      appBar: AppBar(
        title: const Text(
          'B03 - Memory Game',
          style: TextStyle(
            fontSize: 40, // Increase font size
            fontWeight: FontWeight.bold, // Make it bold
          ),
        ),
        centerTitle: true, // Center the title
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove app bar shadow
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Cloud.png',
            fit: BoxFit.cover, // Cover the entire screen
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                    height: 50), // Add space between title and select level
                const Text(
                  'Select a level',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(level: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      // Set equal width for all buttons
                    ),
                    child: const Text('Easy'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(level: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      // Set equal width for all buttons
                    ),
                    child: const Text('Medium'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(level: 3),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      // Set equal width for all buttons
                    ),
                    child: const Text('Hard'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
