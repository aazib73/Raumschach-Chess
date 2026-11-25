import 'package:flutter_test/flutter_test.dart';
import 'package:raumschach/engine/raumschach_engine.dart';
import 'package:raumschach/models/chess_move.dart';
import 'package:raumschach/models/chess_piece.dart';
import 'package:raumschach/models/game_state.dart';
import 'package:raumschach/models/position_3d.dart';

const whiteKing = ChessPiece(type: PieceType.king, color: PieceColor.white);
const blackKing = ChessPiece(type: PieceType.king, color: PieceColor.black);
const whiteQueen = ChessPiece(type: PieceType.queen, color: PieceColor.white);
const whiteRook = ChessPiece(type: PieceType.rook, color: PieceColor.white);
const blackRook = ChessPiece(type: PieceType.rook, color: PieceColor.black);

Position3D square(int file, int rank, int level) =>
    Position3D(file: file, rank: rank, level: level);

void main() {
  const engine = RaumschachEngine();

  test('Ba2 to Ca2 updates the board, turn and history together', () {
    final before = engine.newGame();
    final from = square(0, 1, 1);
    final to = square(0, 1, 2);
    final move = ChessMove(from: from, to: to);

    expect(engine.legalMovesFor(before, from), contains(move));
    final after = engine.applyMove(before, move);
    expect(after.pieceAt(from), isNull);
    expect(after.pieceAt(to), before.pieceAt(from));
    expect(after.turn, PieceColor.black);
    expect(after.history, [move]);
    expect(before.pieceAt(from)?.type, PieceType.pawn);
    expect(before.pieceAt(to), isNull);
    expect(before.history, isEmpty);
    expect(engine.legalMovesFor(after, to), isEmpty);
  });

  test('a pinned rook can capture the attacker but cannot expose its king', () {
    final from = square(0, 0, 1);
    final attacker = square(0, 0, 4);
    final before = GameState(board: {
      square(0, 0, 0): whiteKing,
      from: whiteRook,
      attacker: blackRook,
      square(4, 4, 4): blackKing,
    });
    final exposesKing = ChessMove(from: from, to: square(1, 0, 1));
    final capture = ChessMove(from: from, to: attacker);

    final moves = engine.legalMovesFor(before, from);
    expect(moves, isNot(contains(exposesKing)));
    expect(() => engine.applyMove(before, exposesKing), throwsArgumentError);
    expect(moves, contains(capture));
    final after = engine.applyMove(before, capture);
    expect(after.pieceAt(attacker), whiteRook);
    expect(after.board, hasLength(3));
    expect(before.pieceAt(attacker), blackRook);
  });

  test('promotion requires a choice and applies the selected unicorn', () {
    final from = square(2, 3, 4);
    final to = square(2, 4, 4);
    final before = GameState(board: {
      square(0, 0, 0): whiteKing,
      square(4, 0, 0): blackKing,
      from: const ChessPiece(type: PieceType.pawn, color: PieceColor.white),
    });
    expect(
      () => engine.applyMove(before, ChessMove(from: from, to: to)),
      throwsArgumentError,
    );
    final move = ChessMove(from: from, to: to, promotion: PieceType.unicorn);
    final after = engine.applyMove(before, move);
    expect(after.pieceAt(to),
        const ChessPiece(type: PieceType.unicorn, color: PieceColor.white));
    expect(after.history.last.promotion, PieceType.unicorn);
  });

  test('check with an escape square keeps the match playable', () {
    final from = square(1, 1, 4);
    final blackKingSquare = square(1, 0, 0);
    final before = GameState(board: {
      square(4, 4, 4): whiteKing,
      blackKingSquare: blackKing,
      from: whiteRook,
    });
    final move = ChessMove(from: from, to: square(1, 1, 0));
    final after = engine.applyMove(before, move);
    expect(after.status, GameStatus.check);
    expect(after.isOver, isFalse);
    expect(engine.legalMovesFor(after, blackKingSquare), isNotEmpty);
  });

  test('a protected queen on Bb2 checkmates a black king on Aa1', () {
    final from = square(0, 1, 2);
    final before = GameState(board: {
      square(0, 0, 0): blackKing,
      square(2, 2, 2): whiteKing,
      from: whiteQueen,
    });
    final after = engine.applyMove(
      before, ChessMove(from: from, to: square(1, 1, 1)),
    );
    expect(engine.isInCheck(after, PieceColor.black), isTrue);
    expect(after.status, GameStatus.checkmate);
    expect(after.winner, PieceColor.white);
    expect(after.isOver, isTrue);
  });

  test('covering every exit without attacking Aa1 gives stalemate', () {
    final from = square(0, 1, 3);
    final before = GameState(board: {
      square(0, 0, 0): blackKing,
      square(2, 0, 0): whiteKing,
      from: whiteQueen,
    });
    final after = engine.applyMove(
      before, ChessMove(from: from, to: square(0, 1, 2)),
    );
    expect(engine.isInCheck(after, PieceColor.black), isFalse);
    expect(after.status, GameStatus.stalemate);
    expect(after.winner, isNull);
    expect(after.isOver, isTrue);
  });
}
