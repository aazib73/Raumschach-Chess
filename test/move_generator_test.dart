import 'package:flutter_test/flutter_test.dart';
import 'package:raumschach/engine/move_generator.dart';
import 'package:raumschach/models/chess_piece.dart';
import 'package:raumschach/models/game_state.dart';
import 'package:raumschach/models/position_3d.dart';

void main() {
  final generator = MoveGenerator();
  const center = Position3D(file: 2, rank: 2, level: 2);
  ChessPiece piece(PieceType type, [PieceColor color = PieceColor.white]) =>
      ChessPiece(type: type, color: color);

  test('empty board mobility from Cc3', () {
    for (final entry in {
      PieceType.rook: 12,
      PieceType.bishop: 24,
      PieceType.unicorn: 16,
      PieceType.queen: 52,
      PieceType.king: 26,
      PieceType.knight: 24,
      PieceType.pawn: 2,
    }.entries) {
      final state = GameState(board: {center: piece(entry.key)});
      final moves = generator.candidateMoves(state, center);
      expect(moves.map((move) => move.to).toSet(), hasLength(entry.value),
          reason: entry.key.name);
    }
  });

  test('sliders defend allies, stop at blockers and threaten enemy kings', () {
    final ally = center.offset(file: 1);
    final king = center.offset(level: 1);
    final enemy = center.offset(rank: -1);
    final state = GameState(board: {
      center: piece(PieceType.rook),
      ally: piece(PieceType.pawn),
      king: piece(PieceType.king, PieceColor.black),
      enemy: piece(PieceType.pawn, PieceColor.black),
    });
    final attacks = generator.attackedSquares(state, center);
    final moves = generator.candidateMoves(state, center).map((m) => m.to);
    expect(attacks, containsAll([ally, king, enemy]));
    expect(attacks, isNot(contains(center.offset(file: 2))));
    expect(attacks, isNot(contains(center.offset(rank: -2))));
    expect(moves, contains(enemy));
    expect(moves, isNot(contains(ally)));
    expect(moves, isNot(contains(king)));
  });

  for (final color in PieceColor.values) {
    final step = color == PieceColor.white ? 1 : -1;
    test('${color.name} pawn separates attacks from quiet moves', () {
      final enemy = center.offset(rank: step, level: step);
      final state = GameState(board: {
        center: piece(PieceType.pawn, color),
        center.offset(rank: step): piece(PieceType.rook, color.opposite),
        enemy: piece(PieceType.bishop, color.opposite),
      });
      expect(generator.attackedSquares(state, center), {
        enemy,
        center.offset(file: 1, rank: step),
        center.offset(file: -1, rank: step),
        center.offset(file: 1, level: step),
        center.offset(file: -1, level: step),
      });
      expect(generator.candidateMoves(state, center).map((m) => m.to).toSet(),
          {center.offset(level: step), enemy});
    });

    test('${color.name} promotes on the far rank and level together', () {
      final edge = step == 1 ? 4 : 0;
      final from = Position3D(file: 2, rank: edge - step, level: edge);
      final state = GameState(board: {from: piece(PieceType.pawn, color)});
      final moves = generator.candidateMoves(state, from);
      expect(moves, hasLength(5));
      expect(moves.every((m) => m.to == from.offset(rank: step)), isTrue);
      expect(moves.map((m) => m.promotion).toSet(), {
        PieceType.queen, PieceType.rook, PieceType.bishop,
        PieceType.knight, PieceType.unicorn,
      });
    });
  }
}
