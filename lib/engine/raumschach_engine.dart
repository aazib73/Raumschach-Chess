import '../models/chess_piece.dart';
import '../models/game_state.dart';
import '../models/position_3d.dart';

/// Pure Dart rules code: keep Flutter widgets and screen state out of this file.
class RaumschachEngine {
  const RaumschachEngine();

  /// Standard 20-piece-per-side starting position. Level C starts empty.
  GameState newGame() {
    final board = <Position3D, ChessPiece>{};

    void placeRow({
      required int level,
      required int rank,
      required PieceColor color,
      required List<PieceType> pieces,
    }) {
      for (var file = 0; file < Position3D.boardSize; file++) {
        board[Position3D(file: file, rank: rank, level: level)] = ChessPiece(
          type: pieces[file],
          color: color,
        );
      }
    }

    const outerRow = [
      PieceType.rook,
      PieceType.knight,
      PieceType.king,
      PieceType.knight,
      PieceType.rook,
    ];
    const whiteInnerRow = [
      PieceType.bishop,
      PieceType.unicorn,
      PieceType.queen,
      PieceType.bishop,
      PieceType.unicorn,
    ];
    const blackInnerRow = [
      PieceType.unicorn,
      PieceType.bishop,
      PieceType.queen,
      PieceType.unicorn,
      PieceType.bishop,
    ];
    final pawns = List<PieceType>.filled(Position3D.boardSize, PieceType.pawn);

    placeRow(level: 0, rank: 0, color: PieceColor.white, pieces: outerRow);
    placeRow(level: 1, rank: 0, color: PieceColor.white, pieces: whiteInnerRow);
    placeRow(level: 3, rank: 4, color: PieceColor.black, pieces: blackInnerRow);
    placeRow(level: 4, rank: 4, color: PieceColor.black, pieces: outerRow);
    for (final level in [0, 1]) {
      placeRow(level: level, rank: 1, color: PieceColor.white, pieces: pawns);
    }
    for (final level in [3, 4]) {
      placeRow(level: level, rank: 3, color: PieceColor.black, pieces: pawns);
    }

    return GameState(board: board);
  }

  // TODO(legal rules): Use the MoveGenerator contract in move_generator.dart.
  // Movement and attacked-square generation belong to the movement owner.
  // Implement these shared legal-rule entry points in this engine:
  // List<ChessMove> legalMovesFor(GameState state, Position3D from)
  // bool isInCheck(GameState state, PieceColor color)
  // GameState applyMove(GameState state, ChessMove move)
  // applyMove must reject illegal moves and return a NEW immutable snapshot.
  // Detect checks from attackedSquares, not from legalMovesFor (no recursion).
  // Checkmate = in check with no legal move for ANY piece; stalemate = no legal
  // move for any piece while not in check. Kings are never captured as a move.
}
