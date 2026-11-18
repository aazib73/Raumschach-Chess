# Raumschach Chess

CS 4750 team project: a local, pass-and-play game on five 5x5 levels.

## Current starting point

The Flutter entry point still runs the original starter app. This setup adds
shared position, piece, move, and immutable game-state models; the standard
40-piece starting arrangement; and a ChangeNotifier game controller.

The four screen files and LayerBoard file are documented implementation slots.
MoveGenerator is an interface for the movement owner to implement.
Movement, check detection, and the game UI are not implemented yet. Do not treat
this branch as a playable game.

## Shared contracts

- `Position3D(file: x, rank: y, level: z)` uses zero-based coordinates 0 through 4.
  User labels use levels A-E, files a-e, and ranks 1-5. The origin is Aa1.
- Candidate moves may temporarily have out-of-bounds positions. Check
  `isInBounds` before accessing the board or requesting notation.
- `GameState.board` is an immutable map of occupied cells. Use `pieceAt` to look
  up a cell; null means empty. Never store another authoritative board in a view.
- `ChessMove` is a request containing `from`, `to`, and an optional promotion.
  The engine must validate the request before applying it.
- `RaumschachEngine.newGame()` creates the initial state. Next engine APIs are
  `legalMovesFor(state, from)`, `isInCheck(state, color)`, and `applyMove(state, move)`.
  Applying a move should return a new GameState and update turn/history/status.
- `MoveGenerator.candidateMoves(state, from)` checks movement and occupancy,
  without filtering self-check. `attackedSquares(state, from)` supplies attacks
  for check detection. It must not call the legal-move filter. Pawns have
  different attack and non-capture directions. The engine never captures kings.
- `GameController` owns the current snapshot and notifies its listeners. Both
  board views receive the SAME controller. Save snapshots here for future undo.
- Keep the models and engine free of Flutter imports. Drawing, gestures, and
  navigation belong in widgets/screens.

The standard starting rows are A1/E5 = R N K N R, B1 = B U Q B U,
and D5 = U B Q U B. White pawns occupy rank 2 on A/B; Black pawns occupy
rank 4 on D/E. Level C starts empty.

## Core source files

| Area | Files under lib/ |
| --- | --- |
| Entry | main.dart |
| Models | models/position_3d.dart, chess_piece.dart, chess_move.dart, game_state.dart |
| Rules | engine/raumschach_engine.dart, move_generator.dart |
| Shared state | controllers/game_controller.dart |
| Screens | screens/home_screen.dart, game_options_screen.dart, game_screen.dart, results_screen.dart |
| Layer board | widgets/layer_board.dart |

There are 13 core source files, including main.dart. The extra move_generator
file separates the two engine jobs so two people can work without editing the
same engine file.

## Four-person workload

| Owner | File ownership and completed behavior |
| --- | --- |
| 1: Movement | engine/move_generator.dart, models/position_3d.dart, models/chess_piece.dart, test/move_generator_test.dart. Generate rook/bishop/unicorn/queen slides, king steps, knight jumps, pawn moves/captures, and promotion candidates. Test boundaries, blockers, captures, and all three axes. |
| 2: Legal rules | engine/raumschach_engine.dart, models/chess_move.dart, models/game_state.dart, test/game_rules_test.dart. Reject self-check and king captures; apply moves, captures, turn changes, promotion, and history; detect check, checkmate, and stalemate. |
| 3: Playable board | controllers/game_controller.dart, screens/game_screen.dart, widgets/layer_board.dart. Display five levels, select pieces, highlight legal moves across levels, submit moves, show turns/check, and update every board together. |
| 4: App flow and delivery | main.dart, screens/home_screen.dart, screens/game_options_screen.dart, screens/results_screen.dart, test/app_flow_test.dart. Connect menus/new game/results/restart, add concise movement help, test complete Android journeys, and prepare the Android release build and app icon. |

The two engine owners review each other's edge cases. The two UI owners review
the phone layout and navigation together. Owner 4 starts build/device checks on
day 1 rather than waiting until the final day. Anyone who finishes early helps
with the other owners' acceptance tests before adding optional features.

Agree on shared contracts before changing them. Use branches such as
feature/movement, feature/legal-rules, feature/board-ui, and feature/app-flow.
Integrate a working version at least daily; push early interface changes before
building a whole feature in isolation.

## Playable-core acceptance checklist

- New Game opens a standard position with 20 pieces per color on five levels.
- Selecting an own piece highlights its legal destinations on every level.
- Only legal moves/captures are accepted, and the turn changes after each move.
- A player cannot leave their king in check; a king is never captured.
- Pawns promote with a choice of queen, rook, bishop, knight, or unicorn.
- Check is visible. Checkmate and stalemate lead to the correct result screen.
- Restart creates a fresh game, and the full flow runs on an Android device.

## Three-day priorities

1. Day 1: share working interfaces early; implement piece movement, initial
   boards, and navigation in parallel. Everyone runs the project on Android.
2. Day 2: integrate check/checkmate/stalemate, promotion, move highlights, and
   captures. Target a full pass-and-play game by the end of the day.
3. Day 3: freeze optional work; play complete games, fix failures, add the app
   icon, configure release signing, and produce the Android release build.

The rotatable 3D view, practice mode, undo, and modifiers follow a working core.
Online play, AI, and replay remain stretch work. Store publication is a separate
step after a tested, signed release; this schedule does not guarantee publication.

## Local checks

Use the Flutter SDK already installed on the team's development machines:

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter devices
```

Run on a detected Android emulator/phone from Android Studio, or use
`flutter run -d YOUR_ANDROID_DEVICE_ID` with the ID shown by `flutter devices`.

The foundation tests check coordinate lookup, board bounds, the starting armies,
immutable snapshots, and controller reset notifications. Add legal-movement and
check-detection tests as those features are implemented.
