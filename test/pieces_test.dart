import 'package:flutter_test/flutter_test.dart';
import 'package:raumschach/engine/move_generator.dart';
import 'package:raumschach/models/chess_piece.dart';
import 'package:raumschach/models/game_state.dart';
import 'package:raumschach/models/position_3d.dart';

const corner = Position3D(file: 0, rank: 0, level: 0); // Aa1
const center = Position3D(file: 2, rank: 2, level: 2); // Cc3
const ally = ChessPiece(type: PieceType.pawn, color: PieceColor.white);
const enemy = ChessPiece(type: PieceType.pawn, color: PieceColor.black);

// From Aa1 a sliding piece can follow up to seven different lines.
const straight = [
  'Ab1', 'Ac1', 'Ad1', 'Ae1',
  'Aa2', 'Aa3', 'Aa4', 'Aa5',
  'Ba1', 'Ca1', 'Da1', 'Ea1',
];
const faceDiagonals = [
  'Ab2', 'Ac3', 'Ad4', 'Ae5',
  'Bb1', 'Cc1', 'Dd1', 'Ee1',
  'Ba2', 'Ca3', 'Da4', 'Ea5',
];
const spaceDiagonal = ['Bb2', 'Cc3', 'Dd4', 'Ee5'];

void expectMoves(
  PieceType type,
  List<String> expected, {
  Position3D from = corner,
  PieceColor color = PieceColor.white,
  Map<Position3D, ChessPiece> occupants = const {},
}) {
  final state = GameState(board: {
    ...occupants,
    from: ChessPiece(type: type, color: color),
  }, turn: color);
  final moves = MoveGenerator().candidateMoves(state, from);
  expect(moves.map((move) => move.to.notation), unorderedEquals(expected),
      reason: '${color.name} ${type.name} from ${from.notation}');
}

void main() {
  test('rook travels along a file, rank or level and stops at blockers', () {
    expectMoves(PieceType.rook, straight);
    expectMoves(PieceType.rook, [
      'Ab1',
      'Aa2', 'Aa3', 'Aa4', 'Aa5',
      'Ba1', 'Ca1',
    ], occupants: {
      corner.offset(file: 2): ally,
      corner.offset(level: 2): enemy,
    });
  });

  test('bishop follows two-axis diagonals in all three planes', () {
    expectMoves(PieceType.bishop, faceDiagonals);
    expectMoves(PieceType.bishop, [
      'Ab2',
      'Bb1', 'Cc1', 'Dd1', 'Ee1',
      'Ba2', 'Ca3', 'Da4', 'Ea5',
    ], occupants: {corner.offset(file: 1, rank: 1): enemy});
  });

  test('unicorn follows three-axis diagonals until a piece blocks it', () {
    expectMoves(PieceType.unicorn, spaceDiagonal);
    expectMoves(PieceType.unicorn, ['Bb2'],
        occupants: {center: ally});
    expectMoves(PieceType.unicorn, ['Bb2', 'Cc3'],
        occupants: {center: enemy});
  });

  test('queen combines straight, face-diagonal and space-diagonal moves', () {
    expectMoves(PieceType.queen, [...straight, ...faceDiagonals, ...spaceDiagonal]);
    expectMoves(PieceType.queen, [...straight, ...faceDiagonals, 'Bb2'],
        occupants: {center: ally});
  });

  test('king can take one step in each available direction', () {
    expectMoves(PieceType.king, ['Ab1', 'Aa2', 'Ba1', 'Ab2', 'Bb1', 'Ba2', 'Bb2']);
    expectMoves(PieceType.king, ['Aa2', 'Ba1', 'Ab2', 'Bb1', 'Ba2', 'Bb2'],
        occupants: {
          corner.offset(file: 1): ally,
          corner.offset(file: 1, rank: 1, level: 1): enemy,
        });
  });

  test('knight jumps in every plane, even when adjacent squares are blocked', () {
    expectMoves(PieceType.knight, ['Ac2', 'Ab3', 'Bc1', 'Cb1', 'Ba3', 'Ca2']);
    expectMoves(PieceType.knight, ['Ab3', 'Bc1', 'Cb1', 'Ba3', 'Ca2'],
        occupants: {
          corner.offset(file: 1): ally,
          corner.offset(rank: 1): ally,
          corner.offset(level: 1): ally,
          corner.offset(file: 2, rank: 1): ally,
          corner.offset(file: 1, rank: 2): enemy,
        });
  });

  for (final color in PieceColor.values) {
    test('${color.name} pawn advances into empty squares and captures diagonally', () {
      final white = color == PieceColor.white;
      final step = white ? 1 : -1;
      final opponent = white ? enemy : ally;
      expectMoves(PieceType.pawn, white ? ['Cc4', 'Dc3'] : ['Cc2', 'Bc3'],
          from: center, color: color);
      expectMoves(
        PieceType.pawn,
        white ? ['Cb4', 'Cd4', 'Db3', 'Dd3', 'Dc4']
              : ['Cb2', 'Cd2', 'Bb3', 'Bd3', 'Bc2'],
        from: center,
        color: color,
        occupants: {
          center.offset(rank: step): opponent,
          center.offset(level: step): opponent,
          center.offset(file: -1, rank: step): opponent,
          center.offset(file: 1, rank: step): opponent,
          center.offset(file: -1, level: step): opponent,
          center.offset(file: 1, level: step): opponent,
          center.offset(rank: step, level: step): opponent,
        },
      );
    });
  }
}
