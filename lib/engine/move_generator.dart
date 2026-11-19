import '../models/chess_move.dart';
import '../models/chess_piece.dart';
import '../models/game_state.dart';
import '../models/position_3d.dart';

class MoveGenerator {
  /// Generates moves for the piece at [from].
  /// The engine checks afterward whether a move exposes its own king.
  List<ChessMove> candidateMoves(GameState state, Position3D from) {
    final piece = state.board[from];
    if (piece == null) return [];

    final moves = <ChessMove>[];
    final isPawn = piece.type == PieceType.pawn;
    final isWhite = piece.color == PieceColor.white;
    final promotionIndex = isWhite ? Position3D.boardSize - 1 : 0;

    void addMove(Position3D to) {
      // A pawn promotes only when it reaches both the far rank and far level.
      // Each choice is a separate move so the player can pick a piece.
      if (isPawn && to.rank == promotionIndex && to.level == promotionIndex) {
        for (final choice in const [
          PieceType.queen,
          PieceType.rook,
          PieceType.bishop,
          PieceType.knight,
          PieceType.unicorn,
        ]) {
          moves.add(ChessMove(from: from, to: to, promotion: choice));
        }
      } else {
        moves.add(ChessMove(from: from, to: to));
      }
    }

    if (isPawn) {
      final step = isWhite ? 1 : -1;

      // A pawn can advance one rank or one level into an empty square.
      // Check each direction separately because one path may be blocked.
      for (final to in [
        from.offset(rank: step),
        from.offset(level: step),
      ]) {
        if (to.isInBounds && state.board[to] == null) {
          addMove(to);
        }
      }
    }

    for (final to in attackedSquares(state, from)) {
      final occupant = state.board[to];

      if (occupant?.color == piece.color) continue;
      if (occupant?.type == PieceType.king) continue;

      // A pawn can land on an attacked square only by capturing a piece.
      if (isPawn && occupant == null) continue;

      addMove(to);
    }

    return moves;
  }

  /// Returns the squares threatened by the piece at [from].
  /// This includes friendly-occupied squares that the piece defends.
  Set<Position3D> attackedSquares(GameState state, Position3D from) {
    final piece = state.board[from];
    if (piece == null) return <Position3D>{};

    switch (piece.type) {
      case PieceType.rook:
        return _lineAttacks(state, from, requiredAxes: 1);
      case PieceType.bishop:
        return _lineAttacks(state, from, requiredAxes: 2);
      case PieceType.unicorn:
        return _lineAttacks(state, from, requiredAxes: 3);
      case PieceType.queen:
        return _lineAttacks(state, from);
      case PieceType.king:
        return _lineAttacks(state, from, oneStep: true);
      case PieceType.knight:
        return _knightAttacks(from);
      case PieceType.pawn:
        return _pawnAttacks(from, piece.color);
    }
  }

  /// Follows each line that changes [requiredAxes] coordinates per step.
  /// The queen and king omit [requiredAxes] to allow every direction.
  Set<Position3D> _lineAttacks(
      GameState state,
      Position3D from, {
        int? requiredAxes,
        bool oneStep = false,
      }) {
    final targets = <Position3D>{};

    // Start next to the piece and keep stepping in the same direction.
    void scan(int fileStep, int rankStep, int levelStep) {
      var square = from.offset(
        file: fileStep,
        rank: rankStep,
        level: levelStep,
      );

      while (square.isInBounds) {
        targets.add(square);

        // Include the first occupied square, then stop. A piece there is
        // either threatened or defended, and it blocks everything behind it.
        if (oneStep || state.board.containsKey(square)) {
          break;
        }

        square = square.offset(
          file: fileStep,
          rank: rankStep,
          level: levelStep,
        );
      }
    }

    for (var fileStep = -1; fileStep <= 1; fileStep++) {
      for (var rankStep = -1; rankStep <= 1; rankStep++) {
        for (var levelStep = -1; levelStep <= 1; levelStep++) {
          // Each nonzero step changes one axis. For example, (-1, 0, 1)
          // changes two axes, so it is a bishop direction.
          final axisCount =
              fileStep.abs() + rankStep.abs() + levelStep.abs();

          if (axisCount == 0) continue; // (0, 0, 0) stays on the same square.
          if (requiredAxes != null && axisCount != requiredAxes) continue;

          scan(fileStep, rankStep, levelStep);
        }
      }
    }

    return targets;
  }

  /// A knight jumps two squares along one axis and one along another.
  Set<Position3D> _knightAttacks(Position3D from) {
    final targets = <Position3D>{};

    for (final longStep in [-2, 2]) {
      for (final shortStep in [-1, 1]) {
        // Choose which axis gets the long step and which gets the short step.
        // Only the landing square matters because the knight jumps.
        targets.addAll([
          from.offset(file: longStep, rank: shortStep),
          from.offset(file: longStep, level: shortStep),
          from.offset(rank: longStep, file: shortStep),
          from.offset(rank: longStep, level: shortStep),
          from.offset(level: longStep, file: shortStep),
          from.offset(level: longStep, rank: shortStep),
        ]);
      }
    }

    return targets.where((square) => square.isInBounds).toSet();
  }

  /// A pawn threatens up to five diagonal squares, even when they are empty.
  Set<Position3D> _pawnAttacks(Position3D from, PieceColor color) {
    // White advances toward higher ranks and levels. Black advances toward lower ones.
    final step = color == PieceColor.white ? 1 : -1;

    final targets = {
      // Advance one rank and move sideways one file.
      from.offset(file: -1, rank: step),
      from.offset(file: 1, rank: step),

      // Advance one level and move sideways one file.
      from.offset(file: -1, level: step),
      from.offset(file: 1, level: step),

      // Advance one rank and one level together, staying on the same file.
      from.offset(rank: step, level: step),
    };

    return targets.where((square) => square.isInBounds).toSet();
  }
}