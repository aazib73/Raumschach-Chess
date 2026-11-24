import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/chess_move.dart';
import '../models/position_3d.dart';
import 'game_screen.dart';
import 'results_screen.dart';

class GameOptionsScreen extends StatelessWidget {
  const GameOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Options')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Local pass-and-play'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const _LocalMatch()),
              ),
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalMatch extends StatefulWidget {
  const _LocalMatch();

  @override
  State<_LocalMatch> createState() => _LocalMatchState();
}

class _LocalMatchState extends State<_LocalMatch> {
  final _controller = GameController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onCellTap(Position3D position) async {
    final moves = _controller.movesTo(position);
    if (moves.isEmpty) {
      _controller.selectPosition(position);
      return;
    }

    if (moves.length == 1) {
      _controller.playMove(moves.single);
      return;
    }

    // A promotion square has a separate legal move for each piece choice.
    final move = await showDialog<ChessMove>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Promote pawn'),
        children: [
          for (final option in moves)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(option),
              child: Text(option.promotion!.name),
            ),
        ],
      ),
    );
    if (mounted && move != null) {
      _controller.playMove(move);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final state = _controller.state;
        if (state.isOver) {
          return ResultsScreen(
            state: state,
            onNewGame: _controller.startNewGame,
            onHome: () => Navigator.of(context).popUntil((route) => route.isFirst),
          );
        }

        return GameScreen(
          state: state,
          selectedPosition: _controller.selectedPosition,
          legalTargets: _controller.legalTargets,
          onCellTap: _onCellTap,
        );
      },
    );
  }
}
