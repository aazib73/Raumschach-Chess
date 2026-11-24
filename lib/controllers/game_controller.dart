import 'package:flutter/foundation.dart';

import '../engine/raumschach_engine.dart';
import '../models/chess_move.dart';
import '../models/game_state.dart';
import '../models/position_3d.dart';

/// One controller per game. Both board views should listen to this instance.
class GameController extends ChangeNotifier {
  GameController({RaumschachEngine engine = const RaumschachEngine()})
    : _engine = engine,
      _state = engine.newGame();

  final RaumschachEngine _engine;
  GameState _state;

  Position3D? _selectedPosition;
  List<ChessMove> _selectedMoves = const [];

  GameState get state => _state;
  Position3D? get selectedPosition => _selectedPosition;
  Set<Position3D> get legalTargets => {
    for (final move in _selectedMoves) move.to,
  };

  void startNewGame() {
    _state = _engine.newGame();
    _clearSelection();
    notifyListeners();
  }

  void selectPosition(Position3D position) {
    final piece = _state.board[position];
    if (_state.isOver ||
        position == _selectedPosition ||
        piece?.color != _state.turn) {
      _clearSelection();
    } else {
      _selectedPosition = position;
      _selectedMoves = _engine.legalMovesFor(_state, position);
    }
    notifyListeners();
  }

  List<ChessMove> movesTo(Position3D position) {
    return _selectedMoves.where((move) => move.to == position).toList();
  }

  void playMove(ChessMove move) {
    _state = _engine.applyMove(_state, move);
    _clearSelection();
    notifyListeners();
  }

  void _clearSelection() {
    _selectedPosition = null;
    _selectedMoves = const [];
  }
}
