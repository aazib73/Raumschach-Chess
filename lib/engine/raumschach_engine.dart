import '../models/chess_piece.dart';
import '../models/game_state.dart';
import '../models/position_3d.dart';
import '../models/chess_move.dart';
import 'move_generator.dart';

/// Pure Dart rules code: keep Flutter widgets and screen state out of this file.
class RaumschachEngine {
  const RaumschachEngine();
  static final MoveGenerator _moveGenerator = MoveGenerator();

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
  bool isInCheck(GameState state, PieceColor color) {
    Position3D? kingPosition;
    // Each board entry maps a square (key) to the piece on it (value).
    for (final entry in state.board.entries) {
      final piece = entry.value;

      if (piece.color == color && piece.type == PieceType.king) {
        kingPosition = entry.key;
        break;
      }
    }
    if (kingPosition == null) {
      throw StateError("The board is missing the ${color.name} king.");
    }

    // One opposing piece attacking the king is enough to establish check.
    for (final entry in state.board.entries) {
      if (entry.value.color == color) {
        continue;
      }

      final attacks = _moveGenerator.attackedSquares(state, entry.key);
      if (attacks.contains(kingPosition)) return true;
    }

    return false;
  }

  List<ChessMove> legalMovesFor(GameState state, Position3D from) {
    final piece = state.board[from];
    if (state.isOver || piece == null || piece.color != state.turn) {
      return [];
    }

    final legalMoves = <ChessMove>[];
    
    for (final move in _moveGenerator.candidateMoves(state, from)) {
      final copyBoard = _boardAfterMove(state, move);
      final copyState = GameState(board: copyBoard, turn: state.turn);

      if (!isInCheck(copyState, piece.color)) {
        legalMoves.add(move);
      }
    }

    return legalMoves;
  }

  /// Builds the board that would result from a generated move.
  Map<Position3D, ChessPiece> _boardAfterMove(GameState state, ChessMove move) {
    final board = Map<Position3D, ChessPiece>.of(state.board);

    // A generated move always starts on an occupied square.
    final piece = board.remove(move.from)!;
    final promotion = move.promotion;

    // Writing to the destination also handles captures by replacing its occupant.
    if (promotion == null) {
      board[move.to] = piece;
    } else {
      board[move.to] = ChessPiece(type: promotion, color: piece.color);
    }

    return board;
  }

  /// Applies a legal move and returns the updated game state.
  GameState applyMove(GameState state, ChessMove move) {
    final legalMoves = legalMovesFor(state, move.from);
    if (!legalMoves.contains(move)) {
      throw ArgumentError('Illegal move from ${move.from} to ${move.to}.');
    }

    final board = _boardAfterMove(state, move);
    final nextPlayer = state.turn.opposite;

    final nextState = GameState(board: board, turn: nextPlayer);
    final inCheck = isInCheck(nextState, nextPlayer);

    var hasLegalMove = false;
    for (final entry in board.entries) {
      if (entry.value.color != nextPlayer) continue;

      if (legalMovesFor(nextState, entry.key).isNotEmpty) {
        hasLegalMove = true;
        break;
      }
    }

    var status = GameStatus.playing;
    PieceColor? winner;

    if (hasLegalMove) {
      if (inCheck) {
        status = GameStatus.check;
      }
    } else if (inCheck) {
      status = GameStatus.checkmate;
      winner = state.turn;
    } else {
      status = GameStatus.stalemate;
    }

    return GameState(
      board: board,
      turn: nextPlayer,
      status: status,
      history: [...state.history, move],
      winner: winner,
    );
  }
}
