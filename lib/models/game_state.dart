import 'chess_move.dart';
import 'chess_piece.dart';
import 'position_3d.dart';

enum GameStatus { playing, check, checkmate, stalemate, draw, resigned }

/// An immutable snapshot shared by the rules engine and both board views.
///
/// The board map stores occupied cells only. An absent key is an empty cell.
/// This constructor validates coordinates; the engine validates game rules.
class GameState {
  GameState({
    required Map<Position3D, ChessPiece> board,
    this.turn = PieceColor.white,
    this.status = GameStatus.playing,
    List<ChessMove> history = const [],
    this.winner,
  }) : board = Map<Position3D, ChessPiece>.unmodifiable(board),
       history = List<ChessMove>.unmodifiable(history) {
    if (this.board.keys.any((position) => !position.isInBounds)) {
      throw ArgumentError('Every occupied cell must be inside the 5x5x5 board.');
    }
  }

  final Map<Position3D, ChessPiece> board;
  final PieceColor turn;
  final GameStatus status;
  final List<ChessMove> history;
  final PieceColor? winner;

  ChessPiece? pieceAt(Position3D position) {
    if (!position.isInBounds) {
      throw ArgumentError.value(position, 'position', 'Cell is outside the board');
    }
    return board[position];
  }

  bool get isOver =>
      status == GameStatus.checkmate ||
      status == GameStatus.stalemate ||
      status == GameStatus.draw ||
      status == GameStatus.resigned;
}
