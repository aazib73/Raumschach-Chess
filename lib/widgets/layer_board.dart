import 'package:flutter/material.dart';

import '../models/chess_piece.dart';
import '../models/game_state.dart';
import '../models/position_3d.dart';

/// One level of the shared Raumschach board.
class LayerBoard extends StatelessWidget {
  const LayerBoard({
    super.key,
    required this.level,
    required this.state,
    required this.selectedPosition,
    required this.legalTargets,
    required this.onCellTap,
  }) : assert(level >= 0 && level < Position3D.boardSize);

  final int level;
  final GameState state;
  final Position3D? selectedPosition;
  final Set<Position3D> legalTargets;
  final ValueChanged<Position3D>? onCellTap;

  static const _size = Position3D.boardSize;
  static const _axisLabelSize = 22.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Level ${String.fromCharCode(65 + level)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(width: _axisLabelSize),
            for (var file = 0; file < _size; file++)
              Expanded(
                child: Center(child: Text(String.fromCharCode(97 + file))),
              ),
          ],
        ),
        // Display higher ranks first, so a1 is at the bottom left.
        for (var rank = _size - 1; rank >= 0; rank--)
          Row(
            children: [
              SizedBox(
                width: _axisLabelSize,
                child: Center(child: Text('${rank + 1}')),
              ),
              for (var file = 0; file < _size; file++)
                Expanded(
                  child: _buildCell(
                    Position3D(file: file, rank: rank, level: level),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(Position3D position) {
    final piece = state.pieceAt(position);
    final selected = position == selectedPosition;
    final legal = legalTargets.contains(position);
    final light = (position.file + position.rank + level).isOdd;
    final tap = onCellTap;
    final details = [
      position.notation,
      if (piece != null) piece.toString(),
      if (legal) 'legal destination',
    ].join(', ');

    return AspectRatio(
      aspectRatio: 1,
      child: Semantics(
        label: details,
        selected: selected,
        child: Material(
          color: selected
              ? const Color(0xFFFFC678)
              : legal
              ? const Color(0xFF64E2DC)
              : light
              ? const Color(0xFFC4C9EB)
              : const Color(0xFF6571AB),
          child: InkWell(
            onTap: tap == null ? null : () => tap(position),
            child: ExcludeSemantics(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (piece != null) Center(child: _buildPiece(piece)),
                  if (legal && piece == null)
                    const Center(
                      child: Icon(
                        Icons.circle,
                        size: 12,
                        color: Color(0xFF063E48),
                      ),
                    ),
                  // A border leaves a capturable piece visible.
                  if (selected || (legal && piece != null))
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF5C2D00)
                              : const Color(0xFF063E48),
                          width: 3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPiece(ChessPiece piece) {
    final isWhite = piece.color == PieceColor.white;
    return FractionallySizedBox(
      widthFactor: 0.72,
      heightFactor: 0.72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isWhite ? Colors.white : const Color(0xFF171C36),
          border: Border.all(
            color: isWhite ? const Color(0xFF39446E) : const Color(0xFFAAB4E0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x440A1028),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            piece.type.letter,
            style: TextStyle(
              color: isWhite ? const Color(0xFF171C36) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
