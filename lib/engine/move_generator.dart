import '../models/chess_move.dart';
import '../models/game_state.dart';
import '../models/position_3d.dart';

/// Contract between the movement owner and the legal-rules owner.
/// Implement this interface in this file, keeping it free of Flutter imports.
abstract class MoveGenerator {
  /// Piece movement and occupancy only; does NOT filter moves for self-check.
  /// Return an empty list for an empty origin. Do not change [state].
  ///
  /// Sliding pieces stop at blockers. Knights jump. Pawns have distinct movement
  /// and capture directions. Promotion candidates must carry the chosen type.
  List<ChessMove> candidateMoves(GameState state, Position3D from);

  /// Cells attacked by this piece, without filtering for self-check.
  ///
  /// Pawn attacks differ from pawn movement. Sliding attacks include the first
  /// occupied cell, even when it is friendly, and stop there. Kings attack the
  /// surrounding cells. This method must NOT call the legal-move filter.
  Set<Position3D> attackedSquares(GameState state, Position3D from);
}
