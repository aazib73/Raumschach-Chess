import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/chess_move.dart';
import '../models/game_options.dart';
import '../models/position_3d.dart';
import 'game_screen.dart';
import 'results_screen.dart';

/// Lets the players pick a local pass-and-play game and optional modifiers.
///
/// Modifier choices are kept in [GameOptions] on this screen. They are not
/// sent to [GameController] yet, because the engine does not apply them.
class GameOptionsScreen extends StatefulWidget {
  const GameOptionsScreen({super.key, required this.controller});

  static const routeName = 'gameOptions';

  final GameController controller;

  @override
  State<GameOptionsScreen> createState() => _GameOptionsScreenState();
}

class _GameOptionsScreenState extends State<GameOptionsScreen> {
  GameOptions _options = const GameOptions();

  Future<void> _startGame() async {
    final controller = widget.controller;
    controller.startNewGame();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _LocalMatch(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Game Options')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Mode',
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      Icons.check_circle,
                                      color: colorScheme.primary,
                                    ),
                                    title: const Text('Pass-and-play'),
                                    subtitle: const Text(
                                      'Two players taking turns on this device',
                                    ),
                                    selected: true,
                                  ),
                                  const ListTile(
                                    leading: Icon(Icons.circle_outlined),
                                    title: Text('Online'),
                                    subtitle: Text('Coming later'),
                                    enabled: false,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Modifiers',
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    title: const Text('Wraparound'),
                                    subtitle: const Text(
                                      'Leave the top, come back at the bottom; the cube becomes a 3D donut.',
                                    ),
                                    value: _options.wraparound,
                                    onChanged: (value) {
                                      setState(() {
                                        _options = _options.copyWith(
                                          wraparound: value,
                                        );
                                      });
                                    },
                                  ),
                                  SwitchListTile(
                                    title: const Text('Gravity'),
                                    subtitle: const Text(
                                      'Pieces with nothing under them fall a level after each turn.',
                                    ),
                                    value: _options.gravity,
                                    onChanged: (value) {
                                      setState(() {
                                        _options = _options.copyWith(
                                          gravity: value,
                                        );
                                      });
                                    },
                                  ),
                                  SwitchListTile(
                                    title: const Text("Rubik's slice"),
                                    subtitle: const Text(
                                      'Instead of moving a piece, rotate a whole slice of the cube.',
                                    ),
                                    value: _options.rubiksSlice,
                                    onChanged: (value) {
                                      setState(() {
                                        _options = _options.copyWith(
                                          rubiksSlice: value,
                                        );
                                      });
                                    },
                                  ),
                                  SwitchListTile(
                                    title: const Text('Portals'),
                                    subtitle: const Text(
                                      'Linked cells teleport anything that enters them.',
                                    ),
                                    value: _options.portals,
                                    onChanged: (value) {
                                      setState(() {
                                        _options = _options.copyWith(
                                          portals: value,
                                        );
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      16,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Modifiers are experimental and are not applied to the rules yet.',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: FilledButton.icon(
                        onPressed: _startGame,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Game'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LocalMatch extends StatefulWidget {
  const _LocalMatch({required this.controller});

  final GameController controller;

  @override
  State<_LocalMatch> createState() => _LocalMatchState();
}

class _LocalMatchState extends State<_LocalMatch> {
  GameController get _controller => widget.controller;

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
          return ResultsScreen(controller: _controller);
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
