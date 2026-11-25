import 'package:flutter/material.dart';

import 'game_options_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raumschach')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => const GameOptionsScreen()),
          ),
          child: const Text('New Game'),
        ),
      ),
    );
  }
}
