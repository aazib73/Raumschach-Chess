import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/chess_piece.dart';
import '../models/game_state.dart';

/// End-of-game screen: who won or whether it was a draw, plus next actions.
///
/// Reads the finished snapshot from [controller]. Optional preview fields are
/// for the temporary board placeholder only, so this screen can be opened
/// before a real game has ended.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.controller,
    this.previewWinner,
    this.previewStatus,
    this.previewMoveCount,
  });

  final GameController controller;

  /// Used only by the dev preview when [controller] still holds a new game.
  final PieceColor? previewWinner;
  final GameStatus? previewStatus;
  final int? previewMoveCount;

  bool get _usingPreview =>
      previewWinner != null || previewStatus != null || previewMoveCount != null;

  PieceColor? get _winner =>
      _usingPreview ? previewWinner : controller.state.winner;

  GameStatus get _status => previewStatus ?? controller.state.status;

  int get _moveCount => previewMoveCount ?? controller.state.history.length;

  String get _headline {
    switch (_winner) {
      case PieceColor.white:
        return 'White wins';
      case PieceColor.black:
        return 'Black wins';
      case null:
        return 'Draw';
    }
  }

  String? get _reason {
    switch (_status) {
      case GameStatus.checkmate:
        return 'by checkmate';
      case GameStatus.stalemate:
        return 'by stalemate';
      case GameStatus.resigned:
        return 'by resignation';
      case GameStatus.draw:
        return null;
      case GameStatus.playing:
      case GameStatus.check:
        return null;
    }
  }

  bool get _isWin => _winner != null;

  void _onNewGame(BuildContext context) {
    controller.startNewGame();
    // Must match GameOptionsScreen.routeName; avoided a circular import.
    Navigator.of(context).popUntil((route) {
      return route.settings.name == 'gameOptions' || route.isFirst;
    });
  }

  void _onHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reason = _reason;
    final moveLabel = _moveCount == 1 ? '1 move played' : '$_moveCount moves played';

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
                            _isWin ? Icons.emoji_events : Icons.handshake,
                            size: 80,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _headline,
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
                            onPressed: () => _onNewGame(context),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('New Game'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: () => _onHome(context),
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
