import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/chess_piece.dart';
import '../models/game_state.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final headline = switch (state.winner) {
      PieceColor.white => 'White wins',
      PieceColor.black => 'Black wins',
      null => 'Draw',
    };

    final reason = switch (state.status) {
      GameStatus.checkmate => 'by checkmate',
      GameStatus.stalemate => 'by stalemate',
      GameStatus.resigned => 'by resignation',
      _ => null,
    };

    final moveCount = state.history.length;
    final moveLabel = moveCount == 1 ? '1 move played' : '$moveCount moves played';
    final resultIcon = state.winner == null ? Icons.handshake : Icons.emoji_events;

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            resultIcon,
                            size: 80,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            headline,
                            textAlign: TextAlign.center,
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (reason != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              reason,
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            moveLabel,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 48),
                          FilledButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('New Game'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () => Navigator.of(context).popUntil(
                              (route) => route.isFirst,
                            ),
                            icon: const Icon(Icons.home_outlined),
                            label: const Text('Home'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.replay),
                            label: const Text('Replay (coming later)'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}