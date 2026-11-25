import 'package:flutter/material.dart';

import '../models/chess_piece.dart';
import '../models/game_state.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.state,
    required this.onNewGame,
    required this.onHome,
  });

  final GameState state;
  final VoidCallback onNewGame;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final result = switch (state.status) {
      GameStatus.checkmate => 'Checkmate',
      GameStatus.stalemate => 'Stalemate',
      GameStatus.resigned => 'Resignation',
      _ => 'Game Over',
    };
    final outcome = switch (state.winner) {
      PieceColor.white => 'White wins',
      PieceColor.black => 'Black wins',
      null => 'Draw',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result, style: Theme.of(context).textTheme.headlineMedium),
            Text(outcome, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: onNewGame, child: const Text('New Game')),
            TextButton(onPressed: onHome, child: const Text('Home')),
          ],
        ),
      ),
    );
  }
}
