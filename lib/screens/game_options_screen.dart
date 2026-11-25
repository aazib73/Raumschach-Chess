import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/game_options.dart';

/// Lets the players pick a local pass-and-play game and optional modifiers.
///
/// Modifier choices are kept in [GameOptions] on this screen. They are not
/// sent to [GameController] yet, because the engine does not apply them.
class GameOptionsScreen extends StatefulWidget {
  const GameOptionsScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<GameOptionsScreen> createState() => _GameOptionsScreenState();
}

class _GameOptionsScreenState extends State<GameOptionsScreen> {
  GameOptions _options = const GameOptions();

  Future<void> _startGame() async {
    widget.controller.startNewGame();
    // TODO(app shell): Push GameScreen(controller: widget.controller) once
    // the board-ui teammate implements that widget. Pass [GameOptions] into
    // the controller or game screen when the engine supports modifiers.
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _PendingGameScreen(
          controller: widget.controller,
          options: _options,
        ),
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

/// Temporary stand-in until the board-ui teammate implements GameScreen.
///
/// [GameScreen] in lib/screens/game_screen.dart is still only a TODO comment
/// and cannot be constructed. This page keeps the game session on the stack
/// so Home disposes [GameController] only after the player returns home.
class _PendingGameScreen extends StatelessWidget {
  const _PendingGameScreen({
    required this.controller,
    required this.options,
  });

  final GameController controller;
  final GameOptions options;

  String get _modifierSummary {
    final enabled = <String>[
      if (options.wraparound) 'Wraparound',
      if (options.gravity) 'Gravity',
      if (options.rubiksSlice) "Rubik's slice",
      if (options.portals) 'Portals',
    ];
    if (enabled.isEmpty) {
      return 'Standard rules (no modifiers)';
    }
    return 'Selected modifiers: ${enabled.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final turnName = controller.state.turn.name;

    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        size: 56,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'The board screen is still being built.',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A new pass-and-play game has started. '
                        '${turnName[0].toUpperCase()}${turnName.substring(1)} to move.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _modifierSummary,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
