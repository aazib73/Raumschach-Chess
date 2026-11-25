// Run with: flutter run -d chrome -t tool/board_preview.dart
import 'package:flutter/material.dart';

import 'package:raumschach/engine/raumschach_engine.dart';
import 'package:raumschach/models/game_state.dart';
import 'package:raumschach/models/position_3d.dart';
import 'package:raumschach/screens/game_screen.dart';

void main() {
  runApp(const MaterialApp(home: _BoardPreview()));
}

class _BoardPreview extends StatefulWidget {
  const _BoardPreview();

  @override
  State<_BoardPreview> createState() => _BoardPreviewState();
}

class _BoardPreviewState extends State<_BoardPreview> {
  final GameState _state = const RaumschachEngine().newGame();
  Position3D? _selected;

  // These destinations demonstrate highlights on two different levels.
  static const _pawn = Position3D(file: 0, rank: 1, level: 1);
  static final _previewTargets = <Position3D>{
    const Position3D(file: 0, rank: 2, level: 1),
    const Position3D(file: 0, rank: 1, level: 2),
  };

  void _selectCell(Position3D position) {
    setState(() => _selected = position);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Tapped ${position.notation}')));
  }

  @override
  Widget build(BuildContext context) {
    return GameScreen(
      state: _state,
      selectedPosition: _selected,
      legalTargets: _selected == _pawn ? _previewTargets : const {},
      onCellTap: _selectCell,
    );
  }
}
