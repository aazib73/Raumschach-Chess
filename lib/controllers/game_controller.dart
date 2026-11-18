import 'package:flutter/foundation.dart';

import '../engine/raumschach_engine.dart';
import '../models/game_state.dart';

/// One controller per game. Both board views should listen to this instance.
class GameController extends ChangeNotifier {
  GameController({RaumschachEngine engine = const RaumschachEngine()})
    : _engine = engine,
      _state = engine.newGame();

  final RaumschachEngine _engine;
  GameState _state;

  GameState get state => _state;

  void startNewGame() {
    _state = _engine.newGame();
    notifyListeners();
  }

  // TODO(controller): Add selection, legal destinations, and move submission
  // once the engine's legalMovesFor/applyMove methods are implemented.
  // Save previous GameState snapshots here when adding undo.
  // Screens and board widgets must submit changes through this controller.
}
