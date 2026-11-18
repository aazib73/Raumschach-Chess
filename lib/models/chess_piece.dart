enum PieceColor {
  white,
  black;

  PieceColor get opposite =>
      this == PieceColor.white ? PieceColor.black : PieceColor.white;
}

enum PieceType {
  king('K'),
  queen('Q'),
  rook('R'),
  bishop('B'),
  knight('N'),
  unicorn('U'),
  pawn('P');

  const PieceType(this.letter);

  final String letter;
}

/// The piece's position belongs to GameState, so moving never mutates a piece.
class ChessPiece {
  const ChessPiece({required this.type, required this.color});

  final PieceType type;
  final PieceColor color;

  @override
  bool operator ==(Object other) =>
      other is ChessPiece && type == other.type && color == other.color;

  @override
  int get hashCode => Object.hash(type, color);

  @override
  String toString() => '${color.name} ${type.name}';
}
