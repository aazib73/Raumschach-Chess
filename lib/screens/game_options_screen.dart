// TODO(app shell): Implement GameOptionsScreen for local pass-and-play.
// Start Game should call controller.startNewGame() and open GameScreen.
// Modifier toggles belong here after the standard game works.

import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';

/// Placeholder so [HomeScreen] can open a new-game session.
/// The full options UI (pass-and-play and modifier toggles) comes later.
class GameOptionsScreen extends StatelessWidget {
  const GameOptionsScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Options')),
      body: const Center(
        child: Text('Game options will go here.'),
      ),
    );
  }
}
