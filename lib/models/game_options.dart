/// Settings chosen on the Game Options screen before a session starts.
///
/// Only local pass-and-play is available for now. The chaos modifiers are
/// stored here for the UI, but the engine does not apply them yet.
enum PlayMode { passAndPlay }

class GameOptions {
  const GameOptions({
    this.playMode = PlayMode.passAndPlay,
    this.wraparound = false,
    this.gravity = false,
    this.rubiksSlice = false,
    this.portals = false,
  });

  /// How the game is played. Online play is not offered yet.
  final PlayMode playMode;

  /// Leave a face of the cube and re-enter on the opposite face.
  final bool wraparound;

  /// Pieces with nothing under them fall a level after each turn.
  final bool gravity;

  /// A turn may rotate a whole slice of the cube instead of moving a piece.
  final bool rubiksSlice;

  /// Linked cells teleport anything that enters them.
  final bool portals;

  GameOptions copyWith({
    PlayMode? playMode,
    bool? wraparound,
    bool? gravity,
    bool? rubiksSlice,
    bool? portals,
  }) {
    return GameOptions(
      playMode: playMode ?? this.playMode,
      wraparound: wraparound ?? this.wraparound,
      gravity: gravity ?? this.gravity,
      rubiksSlice: rubiksSlice ?? this.rubiksSlice,
      portals: portals ?? this.portals,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GameOptions &&
      playMode == other.playMode &&
      wraparound == other.wraparound &&
      gravity == other.gravity &&
      rubiksSlice == other.rubiksSlice &&
      portals == other.portals;

  @override
  int get hashCode =>
      Object.hash(playMode, wraparound, gravity, rubiksSlice, portals);

  @override
  String toString() =>
      'GameOptions(playMode: ${playMode.name}, wraparound: $wraparound, '
      'gravity: $gravity, rubiksSlice: $rubiksSlice, portals: $portals)';
}
