import 'package:flutter/material.dart';

import '../models/chess_piece.dart';
import '../models/game_state.dart';
import '../models/position_3d.dart';
import '../widgets/cube_board.dart';
import '../widgets/layer_board.dart';

/// Presents the current match. The caller supplies selection and handles moves.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.state,
    required this.selectedPosition,
    required this.legalTargets,
    required this.onCellTap,
  });

  final GameState state;
  final Position3D? selectedPosition;
  final Set<Position3D> legalTargets;
  final ValueChanged<Position3D> onCellTap;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showCube = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final player = state.turn == PieceColor.white ? 'White' : 'Black';
    final status = switch (state.status) {
      GameStatus.playing => '$player to move',
      GameStatus.check => '$player to move · Check',
      GameStatus.checkmate => 'Checkmate',
      GameStatus.stalemate => 'Stalemate',
      GameStatus.draw => 'Draw',
      GameStatus.resigned => 'Game ended by resignation',
    };

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B9AFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101529),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Raumschach'),
          backgroundColor: const Color(0xFF1B2340),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Keep squares large enough to tap on phones and group levels on
              // wider screens. The whole group scrolls together.
              final boardWidth = (constraints.maxWidth - 32).clamp(0.0, 280.0)
                  .toDouble();
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          status,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Layers')),
                          ButtonSegment(value: true, label: Text('3D')),
                        ],
                        selected: {_showCube},
                        onSelectionChanged: (selection) =>
                            setState(() => _showCube = selection.single),
                      ),
                      const SizedBox(height: 16),
                      if (_showCube)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: CubeBoard(
                            state: state,
                            selectedPosition: widget.selectedPosition,
                            legalTargets: widget.legalTargets,
                          ),
                        )
                      else
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            for (var level = 0;
                            level < Position3D.boardSize;
                            level++)
                              SizedBox(
                                width: boardWidth,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: const Color(0xFF202747),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: LayerBoard(
                                      level: level,
                                      state: state,
                                      selectedPosition: widget.selectedPosition,
                                      legalTargets: widget.legalTargets,
                                      onCellTap: state.isOver
                                          ? null
                                          : widget.onCellTap,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
