import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/chess_piece.dart';
import '../models/game_state.dart';
import '../models/position_3d.dart';

/// A rotatable view of the same board shown in Layers.
class CubeBoard extends StatefulWidget {
  const CubeBoard({
    super.key,
    required this.state,
    required this.selectedPosition,
    required this.legalTargets,
  });

  final GameState state;
  final Position3D? selectedPosition;
  final Set<Position3D> legalTargets;

  @override
  State<CubeBoard> createState() => _CubeBoardState();
}

class _CubeBoardState extends State<CubeBoard> {
  static const _initialYaw = -0.55;
  static const _initialPitch = 0.36;
  double _yaw = _initialYaw;
  double _pitch = _initialPitch;
  double _zoom = 1;
  double _gestureZoom = 1;

  void _setZoom(double zoom) {
    _zoom = zoom.clamp(0.7, 1.45).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Drag to rotate. Pinch or use the buttons to zoom.'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Zoom out',
              onPressed: () => setState(() => _setZoom(_zoom - 0.15)),
              icon: const Icon(Icons.remove),
            ),
            TextButton(
              onPressed: () => setState(() {
                _yaw = _initialYaw;
                _pitch = _initialPitch;
                _zoom = 1;
              }),
              child: const Text('Reset view'),
            ),
            IconButton(
              tooltip: 'Zoom in',
              onPressed: () => setState(() => _setZoom(_zoom + 0.15)),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        AspectRatio(
          aspectRatio: 1,
          child: Semantics(
            label: '3D Raumschach board, levels A through E',
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: (_) => _gestureZoom = _zoom,
                onScaleUpdate: (details) => setState(() {
                  if (details.pointerCount > 1) {
                    _setZoom(_gestureZoom * details.scale);
                  } else {
                    _yaw += details.focalPointDelta.dx * 0.012;
                    _pitch = (_pitch - details.focalPointDelta.dy * 0.008)
                        .clamp(0.18, 0.65)
                        .toDouble();
                  }
                }),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [Color(0xFF293359), Color(0xFF13182D)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF39446E)),
                  ),
                  child: CustomPaint(
                    painter: _CubePainter(
                      board: widget.state.board,
                      selected: widget.selectedPosition,
                      legalTargets: widget.legalTargets,
                      yaw: _yaw,
                      pitch: _pitch,
                      zoom: _zoom,
                      labelColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CubePainter extends CustomPainter {
  const _CubePainter({
    required this.board,
    required this.selected,
    required this.legalTargets,
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.labelColor,
  });

  final Map<Position3D, ChessPiece> board;
  final Position3D? selected;
  final Set<Position3D> legalTargets;
  final double yaw;
  final double pitch;
  final double zoom;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    const count = Position3D.boardSize;
    const center = (count - 1) / 2;
    // Reserve a rail for the labels. Zoom only changes the board geometry.
    final origin = Offset(size.width * 0.56, size.height / 2);
    final scale = size.shortestSide * zoom / 15;
    final labelX = size.width * 0.075;
    final labelSize = math.min(size.shortestSide * 0.04, 16.0);
    final yawCos = math.cos(yaw);
    final yawSin = math.sin(yaw);
    final pitchCos = math.cos(pitch);
    final pitchSin = math.sin(pitch);
    final fill = Paint();
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF343D68);

    double depth(double x, double z) => (x - center) * yawSin +
        (z - center) * yawCos;

    // Rotate the board around its vertical axis, then tilt it toward the viewer.
    // Extra spacing between levels keeps the interior boards visible.
    Offset project(double file, double rank, int level) {
      final x = (file - center) * yawCos - (rank - center) * yawSin;
      final y = (center - level) * 1.7 * pitchCos -
          depth(file, rank) * pitchSin;
      return origin + Offset(x * scale, y * scale);
    }

    for (var level = 0; level < count; level++) {
      final cells = [
        for (var rank = 0; rank < count; rank++)
          for (var file = 0; file < count; file++)
            Position3D(file: file, rank: rank, level: level),
      ]..sort((a, b) => depth(a.file.toDouble(), a.rank.toDouble())
          .compareTo(depth(b.file.toDouble(), b.rank.toDouble())));

      for (final cell in cells) {
        final x = cell.file.toDouble();
        final z = cell.rank.toDouble();
        final square = Path()
          ..addPolygon([
            project(x - 0.5, z - 0.5, level),
            project(x + 0.5, z - 0.5, level),
            project(x + 0.5, z + 0.5, level),
            project(x - 0.5, z + 0.5, level),
          ], true);
        final light = (cell.file + cell.rank + level).isOdd;
        fill.color = cell == selected
            ? const Color(0xFFFFC678)
            : legalTargets.contains(cell)
            ? const Color(0xFF64E2DC)
            : light
            ? const Color(0xFFC4C9EB)
            : const Color(0xFF6571AB);
        canvas.drawPath(square, fill);
        canvas.drawPath(square, outline);
      }

      // Draw piece labels after the grid so every selected square remains clear.
      for (final cell in cells) {
        final piece = board[cell];
        if (piece == null) continue;
        final point = project(cell.file.toDouble(), cell.rank.toDouble(), level);
        final isWhite = piece.color == PieceColor.white;
        final radius = scale * 0.31;
        fill.color = isWhite ? Colors.white : const Color(0xFF171C36);
        canvas.drawCircle(point, radius, fill);
        canvas.drawCircle(point, radius, outline);
        _drawLabel(
          canvas,
          piece.type.letter,
          point,
          scale * 0.4,
          isWhite ? const Color(0xFF171C36) : Colors.white,
        );
      }
    }

    // Paint the labels last so the board cannot cover them during rotation.
    for (var level = 0; level < count; level++) {
      final point = Offset(labelX, project(center, center, level).dy);
      fill.color = const Color(0xFF2B335D);
      canvas.drawCircle(point, labelSize * 0.82, fill);
      _drawLabel(
        canvas,
        String.fromCharCode(65 + level),
        point,
        labelSize,
        labelColor,
      );
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset center, double size, Color color) {
    final label = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, center - Offset(label.width / 2, label.height / 2));
    label.dispose();
  }

  @override
  bool shouldRepaint(covariant _CubePainter oldDelegate) {
    return board != oldDelegate.board ||
        selected != oldDelegate.selected ||
        legalTargets != oldDelegate.legalTargets ||
        yaw != oldDelegate.yaw ||
        pitch != oldDelegate.pitch ||
        zoom != oldDelegate.zoom ||
        labelColor != oldDelegate.labelColor;
  }
}
