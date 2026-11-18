/// A board coordinate. File (x), rank (y), and level (z) use indexes 0 through 4.
///
/// Off-board coordinates are allowed while generating candidate moves. Check
/// [isInBounds] before looking up a cell or displaying its [notation].
class Position3D {
  const Position3D({
    required this.file,
    required this.rank,
    required this.level,
  });

  static const boardSize = 5;

  final int file;
  final int rank;
  final int level;

  bool get isInBounds =>
      file >= 0 && file < boardSize &&
      rank >= 0 && rank < boardSize &&
      level >= 0 && level < boardSize;

  Position3D offset({int file = 0, int rank = 0, int level = 0}) {
    return Position3D(
      file: this.file + file,
      rank: this.rank + rank,
      level: this.level + level,
    );
  }

  /// Level + file + rank: (0, 0, 0) is Aa1 and (2, 2, 2) is Cc3.
  String get notation {
    if (!isInBounds) {
      throw StateError('An off-board position has no board notation.');
    }
    final levelName = String.fromCharCode(65 + level);
    final fileName = String.fromCharCode(97 + file);
    return '$levelName$fileName${rank + 1}';
  }

  @override
  bool operator ==(Object other) =>
      other is Position3D &&
      file == other.file &&
      rank == other.rank &&
      level == other.level;

  @override
  int get hashCode => Object.hash(file, rank, level);

  @override
  String toString() => isInBounds
      ? notation
      : 'Position3D(file: $file, rank: $rank, level: $level)';
}
