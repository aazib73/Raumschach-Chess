// TODO(layer view): Implement ONE reusable 5x5 LayerBoard widget.
// Suggested inputs: int level, GameState state, Position3D? selectedPosition,
// Set<Position3D> legalTargets, and ValueChanged<Position3D> onCellTap.
// Display ranks 5 to 1 from top to bottom and files a to e left to right.
// Convert each tapped cell to Position3D(file: column, rank: 4-row, level: level).
// Read pieces with state.pieceAt(position); never keep a second board in a widget.
// Use PieceType.letter for labels, with clear visual differences between colors.
