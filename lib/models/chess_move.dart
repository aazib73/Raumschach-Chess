import 'chess_piece.dart';
import 'position_3d.dart';

/// A move request. The engine will validate legality and promotion choices.
class ChessMove {
  const ChessMove({required this.from, required this.to, this.promotion});

  final Position3D from;
  final Position3D to;
  final PieceType? promotion;

  @override
  bool operator ==(Object other) =>
      other is ChessMove &&
      from == other.from &&
      to == other.to &&
      promotion == other.promotion;

  @override
  int get hashCode => Object.hash(from, to, promotion);
}
