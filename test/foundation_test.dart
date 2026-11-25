import 'package:flutter_test/flutter_test.dart';
import 'package:raumschach/controllers/game_controller.dart';
import 'package:raumschach/engine/raumschach_engine.dart';
import 'package:raumschach/models/chess_move.dart';
import 'package:raumschach/models/chess_piece.dart';
import 'package:raumschach/models/game_state.dart';
import 'package:raumschach/models/position_3d.dart';

void main() {
  const engine = RaumschachEngine();

  test(
    'all 125 cells have unique display coordinates and value-based lookup',
    () {
      final positions = <Position3D>{};
      final labels = <String>{};
      for (var level = 0; level < 5; level++) {
        for (var rank = 0; rank < 5; rank++) {
          for (var file = 0; file < 5; file++) {
            final position = Position3D(file: file, rank: rank, level: level);
            positions.add(position);
            labels.add(position.notation);
          }
        }
      }
      expect(positions, hasLength(125));
      expect(labels, hasLength(125));
      expect(labels, containsAll(['Aa1', 'Cc3', 'Ee5']));
      expect(
        positions.contains(const Position3D(file: 2, rank: 2, level: 2)),
        isTrue,
      );
    },
  );

  test('candidate offsets leave bounds without becoming valid board cells', () {
    const corner = Position3D(file: 0, rank: 0, level: 0);
    final outside = corner.offset(level: -1);
    expect(outside.isInBounds, isFalse);
    expect(() => outside.notation, throwsStateError);
    expect(() => engine.newGame().pieceAt(outside), throwsArgumentError);
    expect(corner.offset(file: 4, rank: 4, level: 4).notation, 'Ee5');
    expect(corner.offset(file: 5).isInBounds, isFalse);
  });

  test('starting armies each have the required 20 pieces', () {
    final state = engine.newGame();
    expect(state.board, hasLength(40));
    const expected = {
      PieceType.king: 1,
      PieceType.queen: 1,
      PieceType.rook: 2,
      PieceType.bishop: 2,
      PieceType.knight: 2,
      PieceType.unicorn: 2,
      PieceType.pawn: 10,
    };
    for (final color in PieceColor.values) {
      final army = state.board.values.where((piece) => piece.color == color);
      expect(army, hasLength(20));
      for (final entry in expected.entries) {
        expect(
          army.where((piece) => piece.type == entry.key),
          hasLength(entry.value),
        );
      }
    }
    expect(state.board.keys.any((position) => position.level == 2), isFalse);
    expect(state.turn, PieceColor.white);
    expect(state.status, GameStatus.playing);
    expect(state.history, isEmpty);
    expect(state.winner, isNull);
  });

  test('kings, queens, and asymmetric unicorn rows use the standard cells', () {
    final state = engine.newGame();
    ChessPiece? at(int file, int rank, int level) =>
        state.pieceAt(Position3D(file: file, rank: rank, level: level));
    expect(at(2, 0, 0)?.type, PieceType.king);
    expect(at(2, 4, 4)?.type, PieceType.king);
    expect(at(2, 0, 1)?.type, PieceType.queen);
    expect(at(2, 4, 3)?.type, PieceType.queen);
    expect(at(1, 0, 1)?.type, PieceType.unicorn);
    expect(at(4, 0, 1)?.type, PieceType.unicorn);
    expect(at(0, 4, 3)?.type, PieceType.unicorn);
    expect(at(3, 4, 3)?.type, PieceType.unicorn);
  });

  test('snapshots cannot be changed by mutating their source collections', () {
    const position = Position3D(file: 0, rank: 0, level: 0);
    const piece = ChessPiece(type: PieceType.rook, color: PieceColor.white);
    final board = <Position3D, ChessPiece>{position: piece};
    final history = <ChessMove>[];
    final state = GameState(board: board, history: history);
    board.clear();
    history.add(ChessMove(from: position, to: position.offset(rank: 1)));
    expect(state.pieceAt(position), piece);
    expect(state.history, isEmpty);
    expect(() => state.board.clear(), throwsUnsupportedError);
    expect(() => state.history.clear(), throwsUnsupportedError);
  });

  test('restarting publishes a fresh shared state', () {
    final controller = GameController();
    addTearDown(controller.dispose);
    final firstState = controller.state;
    var updates = 0;
    controller.addListener(() => updates++);
    controller.startNewGame();
    expect(identical(controller.state, firstState), isFalse);
    expect(controller.state.board, firstState.board);
    expect(updates, 1);
  });
}
